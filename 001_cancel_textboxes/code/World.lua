World = {}
World.__index = World
function World:Create()
    local this =
    {
        mTime = 0,
        mGold = 0,
        mItems = {},
        mKeyItems = {},
        mParty = Party:Create(),
        mIcons = Icons:Create(Texture.Find("inventory_icons.png")),
        mLockInput = false,
        mGameState = GetDefaultGameState()
    }
    setmetatable(this, self)
    return this
end

function World:IsInputLocked()
    return self.mLockInput
end

function World:LockInput()
    self.mLockInput = true
end

function World:UnlockInput()
    self.mLockInput = false
end

function World:Update(dt)
    self.mTime = self.mTime + dt
end

function World:TimeAsString()

    local time = self.mTime
    local hours = math.floor(time / 3600)
    local minutes = math.floor((time % 3600) / 60)
    local seconds = time % 60

    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function World:GoldAsString()
    return string.format("%d", self.mGold)
end

function World:AddItem(itemId, count)

    count = count or 1

    assert(ItemDB[itemId].type ~= "key")

    -- 1. Does it already exist?
    for k, v in ipairs(self.mItems) do
        if v.id == itemId then
            -- 2. Yes, it does. Increment and exit.
            v.count = v.count + count
            return
        end
    end

    -- 3. No it does not exist.
    --    Add it as a new item.
    table.insert(self.mItems,
    {
        id = itemId,
        count = count
    })
end

function World:ItemCount(itemId)

    for _, v in ipairs(self.mItems) do
        if itemId == v.id then
            return v.count
        end
    end

    return 0
end

function World:RemoveItem(itemId, amount)

    print(itemId, ItemDB[itemId])
    assert(ItemDB[itemId].type ~= "key")
    amount = amount or 1

    for i = #self.mItems, 1, -1 do
        local v = self.mItems[i]
        if v.id == itemId then
            v.count = v.count - amount
            assert(v.count >= 0) -- this should never happen
            if v.count == 0 then
                table.remove(self.mItems, i)
            end
            return
        end
    end

    assert(false) -- shouldn't ever get here!
end

function World:FilterItems(Predicate)
    local list  = {}
    for k, v in ipairs(self.mItems) do
        local def = ItemDB[v.id]

        if Predicate(def) then
            table.insert(list, v)
        end
    end
    return list
end

function World:AddLoot(loot)
    for k, v in ipairs(loot) do
        self:AddItem(v.id, v.count)
    end
end


function World:HasKey(itemId)
    for k, v in ipairs(self.mKeyItems) do
        if v.id == itemId then
            return true
        end
    end
    return false
end

function World:AddKey(itemId)
    assert(not self:HasKey(itemId))
    table.insert(self.mKeyItems, {id = itemId})
end

function World:RemoveKey(itemId)
    for i = #self.mKeyItems, 1, -1 do
        local v = self.mKeyItems[i]

        if v.id == itemId then
            table.remove(self.mKeyItems, i)
            return
        end
    end
    assert(false) -- should never get here.
end

function World:DrawKey(menu, renderer, x, y, item)
    if item then
        local itemDef = ItemDB[item.id]
        renderer:AlignText("left", "center")
        renderer:DrawText2d(x, y, itemDef.name)
    else
        renderer:AlignText("center", "center")
        renderer:DrawText2d(x + menu.mSpacingX/2, y, " - ")
    end
end

function World:DrawItem(menu, renderer, x, y, item, color)

    color = color or Vector.Create(1, 1, 1, 1)

    if item then
        local itemDef = ItemDB[item.id]
        local iconSprite = self.mIcons:Get(itemDef.icon or itemDef.type)
        if iconSprite then
            iconSprite:SetColor(color)
            iconSprite:SetPosition(x + 6, y)
            renderer:DrawSprite(iconSprite)
        end
        renderer:AlignText("left", "center")
        renderer:DrawText2d(x + 18, y, itemDef.name, color)

        if item.count then
            local right = x + menu.mSpacingX - 64
            renderer:AlignText("right", "center")
            local countStr = string.format("%02d", item.count)
            renderer:DrawText2d(right, y, countStr, color)
        end
    else
        renderer:AlignText("center", "center")
        renderer:DrawText2d(x + menu.mSpacingX/2, y, " - ", color)
    end
end