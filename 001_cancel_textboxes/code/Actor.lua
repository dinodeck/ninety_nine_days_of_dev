Actor =
{
    EquipSlotLabels =
    {
        "Weapon:",
        "Armor:",
        "Accessory:",
        "Accessory:"
    },
    EquipSlotId =
    {
        "weapon",
        "armor",
        "acces1",
        "acces2"
    },
    ActorStats =
    {
        "strength",
        "speed",
        "intelligence"
    },
    ItemStats =
    {
        "attack",
        "defense",
        "magic",
        "resist"
    },
    ActorStatLabels =
    {
        "Strength",
        "Speed",
        "Intelligence"
    },
    ItemStatLabels =
    {
        "Attack",
        "Defense",
        "Magic",
        "Resist"
    },
    ActionLabels =
    {
        ["attack"] = "Attack",
        ["item"] = "Item",
        ["flee"] = "Flee",
        ["magic"] = "Magic",
        ["special"] = "Special"
    },
}
Actor.__index = Actor
function Actor:Create(def)

    local growth = ShallowClone(def.statGrowth or {})

    local this =
    {
        mName = def.name,
        mId = def.id,

        mActions = def.actions,
        mPortrait = Sprite.Create(),
        mStats = Stats:Create(def.stats),
        mStatGrowth = growth,
        mXP = def.xp or 0,
        mLevel = def.level or 1,
        mEquipment =
        {
            weapon = def.weapon,
            armor = def.armor,
            acces1 = def.acces1,
            acces2 = def.acces2,
        },
        mActiveEquipSlots = def.equipslots or { 1, 2, 3 },
        mSlotTypes =
        {
            "weapon",
            "armor",
            "accessory",
            "accessory"
        },
        mMagic = ShallowClone(def.magic or {}),
        mSpecial = ShallowClone(def.special or {}),
        mStealItem = def.steal_item,
    }

    if def.portrait then
        this.mPortraitTexture = Texture.Find(def.portrait)
        this.mPortrait:SetTexture(this.mPortraitTexture)
    end

    if def.drop then
        local drop = def.drop
        local goldRange = drop.gold or {}
        local gold  = math.random(goldRange[0] or 0, goldRange[1] or 0)

        this.mDrop =
        {
            mXP = drop.xp or 0,
            mGold = gold,
            mAlways = drop.always or {},
            mChance = OddmentTable:Create(drop.chance)
        }

    end

    self.mNextLevelXP = NextLevel(this.mLevel)
    setmetatable(this, self)
    this:DoInitialLeveling()
    return this
end

function Actor:DoInitialLeveling()

    -- Only for party members
    if not gPartyMemberDefs[self.mId] then
        return
    end

    -- Get total XP current level represents
    for i = 1, self.mLevel do
        self.mXP = self.mXP + NextLevel(i - 1)
    end
    -- Set level back to 0
    self.mLevel = 0
    self.mNextLevelXP = NextLevel(self.mLevel)

    -- unlock all abilities / add stats
    while(self:ReadyToLevelUp()) do
        local levelup = self:CreateLevelUp()
        self:ApplyLevel(levelup)
    end
end

function Actor:RenderEquipment(menu, renderer, x, y, index)

    x = x + 100
    local label = self.EquipSlotLabels[index]
    renderer:AlignText("right", "center")
    renderer:DrawText2d(x, y, label)

    local slotId = self.EquipSlotId[index]
    local text = "none"
    if self.mEquipment[slotId] then
        local itemId = self.mEquipment[slotId]
        local item = ItemDB[itemId]
        text = item.name
    end

    renderer:AlignText("left", "center")
    renderer:DrawText2d(x + 10, y, text)
end

function Actor:ReadyToLevelUp()
    return self.mXP >= self.mNextLevelXP
end

function Actor:AddXP(xp)
    self.mXP = self.mXP + xp
    return self:ReadyToLevelUp()
end

function Actor:CreateLevelUp()

    local levelup =
    {
        xp = - self.mNextLevelXP,
        level = 1,
        stats = {},
        actions = {}
    }


    for id, dice in pairs(self.mStatGrowth) do
        levelup.stats[id] = dice:Roll()
    end

    local level = self.mLevel + levelup.level
    local def = gPartyMemberDefs[self.mId]
    levelup.actions = def.actionGrowth[level] or {}

    return levelup
end

-- To unlock a category of actions, such as 'magic', 'special' etc
function Actor:UnlockMenuAction(id)

    print('menu action', tostring(id))

    for _, v in ipairs(self.mActions) do
        if v == id then
            return
        end
    end
    table.insert(self.mActions, id)
end

function Actor:AddAction(action, entry)

    local t = self.mSpecial
    if action == 'magic' then
        t = self.mMagic
    end

    for _, v in ipairs(entry) do
        table.insert(t, v)
    end
end

function Actor:ApplyLevel(levelup)

    self.mXP = self.mXP + levelup.xp
    self.mLevel = self.mLevel + levelup.level
    self.mNextLevelXP = NextLevel(self.mLevel)

    assert(self.mXP >= 0)

    for k, v in pairs(levelup.stats) do
        self.mStats.mBase[k] = self.mStats.mBase[k] + v
    end

    for action, v in pairs(levelup.actions) do
        self:UnlockMenuAction(action)
        self:AddAction(action, v)
    end

    -- Restore HP and MP on level up
    local maxHP = self.mStats:Get("hp_max")
    local maxMP = self.mStats:Get("mp_max")
    self.mStats:Set("mp_now", maxMP)
    self.mStats:Set("hp_now", maxHP)

end

function Actor:Equip(slot, item)

    -- 1. Remove any item current in the slot
    --    Put that item back in the inventory
    local prevItem = self.mEquipment[slot]
    self.mEquipment[slot] = nil
    if prevItem then
        -- Remove modifier
        self.mStats:RemoveModifier(slot)
        gWorld:AddItem(prevItem)
    end

    -- 2. If there's a replacement item move it to the slot
    if not item then
        return
    end
    assert(item.count > 0) -- This should never be allowed to happen!
    gWorld:RemoveItem(item.id)
    self.mEquipment[slot] = item.id
    local modifier = ItemDB[item.id].stats or {}
    self.mStats:AddModifier(slot, modifier)
end

function Actor:Unequip(slot)
    self:Equip(slot, nil)
end

function Actor:EquipCount(itemId)

    local count = 0

    for _, v in pairs(self.mEquipment) do
        if v == itemId then
            count = count + 1
        end
    end

    return count
end

function Actor:CreateStatNameList()

    local list = {}

    for _, v in ipairs(Actor.ActorStats) do
        table.insert(list, v)
    end

    for _, v in ipairs(Actor.ItemStats) do
        table.insert(list, v)
    end


    table.insert(list, "hp_max")
    table.insert(list, "mp_max")

    return list

end

function Actor:CreateStatLabelList()
    local list = {}

    for _, v in ipairs(Actor.ActorStatLabels) do
        table.insert(list, v)
    end

    for _, v in ipairs(Actor.ItemStatLabels) do
        table.insert(list, v)
    end


    table.insert(list, "HP:")
    table.insert(list, "MP:")

    return list
end

function Actor:PredictStats(slot, item)

    -- List of all stats
    local statsId = self:CreateStatNameList()

    -- Get values for all the current stats
    local current = {}
    for _, v in ipairs(statsId) do
        current[v] = self.mStats:Get(v)
    end

    -- Replace item
    local prevItemId = self.mEquipment[slot]
    self.mStats:RemoveModifier(slot)
    self.mStats:AddModifier(slot, item.stats)

    -- Get values for modified stats
    local modified = {}
    for _, v in ipairs(statsId) do
        modified[v] = self.mStats:Get(v)
    end

    local diff = {}
    for _, v in ipairs(statsId) do
        diff[v] = modified[v] - current[v]
    end

    -- -- Undo replace item
    self.mStats:RemoveModifier(slot)
    if prevItemId then
        self.mStats:AddModifier(slot, ItemDB[prevItemId].stats)
    end

    return diff
end

function Actor:CanUse(item)
    if item.restriction == nil then
        return true
    end

    for _, v in pairs(item.restriction) do
        if v == self.mId then
            return true
        end
    end

    return false
end