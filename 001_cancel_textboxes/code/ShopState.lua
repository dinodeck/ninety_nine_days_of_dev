
ShopState = {}
ShopState.__index = ShopState
function ShopState:Create(stack, world, def)

    def = def or {}

    local this
    this =
    {
        mStack = stack,
        mWorld = world,
        mDef = def,
        mPanels = {},
        mName = def.name or "Shop",
        mActors = {},
        mActorCharMap = {},

        mState = "choose", -- "choose", "buy", "sell"
        mTabs =
        {
            ["buy"] = 1,
            ["sell"] = 2,
            ["exit"] = 3,
        },
        mChooseSelection = Selection:Create
        {
            data =
            {
                "Buy",
                "Sell",
                "Exit",
            },
            rows = 1,
            columns = 3,
            OnSelection = function(...) this:ChooseClick(...) end,
        },
        mStock = Selection:Create
        {
            data = def.stock,
            displayRows = 5,
            RenderItem = function(...) this:RenderStock(...) end,
            OnSelection = function(...) this:OnBuy(...) end,

        },
        mInventory = nil,
        mScrollbar = Scrollbar:Create(Texture.Find("scrollbar.png"), 145),
        mFilterList =
        {
            ['all'] = function(def) return true end,
            ['arms'] = function(def)
                return def.type == 'armor' or def.type == 'weapon'
            end,
            ['support'] = function(def)
                return def.type == 'useable'
            end
        },
        mCanUseSprite = Sprite.Create(),
        -- Used every frame
        mItemInvCount = 0,
        mItemEquipCount,
        mItemDescription = 0,
    }

    for _, v in pairs(this.mWorld.mParty.mMembers) do
        table.insert(this.mActors, v)
        local def = gCharacters[v.mId]
        local char = Character:Create(def, {})
        this.mActorCharMap[v] = char
    end


    local layout = Layout:Create()
    layout:Contract('screen', 118, 40)
    layout:SplitHorz('screen', 'top', 'bottom', 0.12, 1)
    layout:SplitVert('top', 'title', 'choose', 0.75, 1)
    layout:SplitHorz('bottom', 'top', 'char', 0.55, 1)
    layout:SplitHorz('char', 'desc', 'char', 0.25, 1)
    layout:SplitVert('top', 'inv', 'status', 0.35, 1)

    this.mPanels =
    {
        layout:CreatePanel("title"),
        layout:CreatePanel("choose"),
        layout:CreatePanel("desc"),
        layout:CreatePanel("char"),
        layout:CreatePanel("inv"),
        layout:CreatePanel("status")
    }

    this.mLayout = layout

    this.mCanUseSprite:SetTexture(Texture.Find("up_caret.png"))
    -- default to all
    local filterId = def.sell_filter or 'all'
    this.InvFilter = this.mFilterList[filterId]

    local cX = layout:Left("choose") + 24
    local cY = layout:MidY("choose")
    this.mChooseSelection:SetPosition(cX, cY)

    local sX = layout:Left("inv") - 16
    local sY = layout:Top("inv") - 18
    this.mPriceX = layout:Right("inv") - 56
    this.mStock:SetPosition(sX, sY)


    local scrollX = layout:Right("inv") - 14
    local scrollY = layout:MidY("inv")
    this.mScrollbar:SetPosition(scrollX, scrollY)

    setmetatable(this, self)
    this.mInventory = this:CreateInvSelection()
    this.mStock:HideCursor()
    this.mInventory:HideCursor()
    return this
end

function ShopState:Enter() end
function ShopState:Exit() end
function ShopState:Update(dt) end

function ShopState:CreateInvSelection()

    local stock = self.mWorld:FilterItems(self.InvFilter)

    local inv = Selection:Create
    {
        data = stock or {},
        displayRows = self.mStock.mDisplayRows,
        RenderItem = function(...) self:RenderInventory(...) end,
        OnSelection = function(...) self:OnSell(...) end,
        spacingX = 225,
    }
    local x = self.mStock.mX
    local y = self.mStock.mY

    inv:SetPosition(x, y)
    inv:HideCursor() -- hidden by default
    return inv
end

function ShopState:OnBuy(index, item)

    local gold = self.mWorld.mGold

    if gold < item.price then
        return -- can't afford
    end

    gold = gold - item.price
    self.mWorld.mGold = gold
    self.mWorld:AddItem(item.id)

    local name = ItemDB[item.id].name
    local message = string.format("Bought %s", name)
    self.mStack:PushFit(gRenderer, 0, 0, message)
end

function ShopState:OnSell(index, item)

    local gold = self.mWorld.mGold
    local def = ItemDB[item.id]
    self.mWorld:RemoveItem(item.id)
    gold = gold + def.price
    self.mWorld.mGold = gold

    -- Refresh inventory disaply
    self.mInventory = self:CreateInvSelection()
    self.mInventory:ShowCursor()

    -- Attempt to restore the index
    for i = 1, index - 1 do
        self.mInventory:MoveDown()
    end

    local message = string.format("Sold %s", def.name)
    self.mStack:PushFit(gRenderer, 0, 0, message)
end

function ShopState:RenderStock(menu, renderer, x, y, item)
    if item == nil then
        return
    end

    local color = nil
    if self.mWorld.mGold < item.price then
        color = Vector.Create(0.6, 0.6, 0.6, 1)
    end

    self.mWorld:DrawItem(menu, renderer, x, y, item, color)

    renderer:AlignTextX("right")
    local priceStr = string.format(": %d", item.price)
    renderer:DrawText2d(self.mPriceX, y, priceStr, color)
end

function ShopState:RenderInventory(menu, renderer, x, y, item)

    if not item then
        return
    end

    self.mWorld:DrawItem(menu, renderer, x, y, item)

    local def = ItemDB[item.id]
    renderer:AlignTextX("right")
    local priceStr = string.format(": %d", def.price)
    renderer:DrawText2d(self.mPriceX, y, priceStr)
end

function ShopState:BackToChooseState()
    self.mState = "choose"
    self.mChooseSelection:ShowCursor()
    self.mInventory:HideCursor()
    self.mStock:HideCursor()
end


function ShopState:ChooseClick(index, item)

    if index == self.mTabs.buy then
        self.mChooseSelection:HideCursor()
        self.mStock:ShowCursor()
        self.mState = "buy"
    elseif index == self.mTabs.sell then
        self.mChooseSelection:HideCursor()
        self.mInventory:ShowCursor()
        self.mState = "sell"
    else
        self.mStack:Pop() -- Remove self off the stack
    end
end


function ShopState:RenderChooseFocus(renderer)
    renderer:AlignText("left", "center")
    self.mChooseSelection:Render(renderer)

    local focus = self.mChooseSelection:GetIndex()

    if focus == self.mTabs.buy then
        self.mStock:Render(renderer)
        self:UpdateScrollbar(renderer, self.mStock)
    elseif focus == self.mTabs.sell then
        self.mInventory:Render(renderer)
        self:UpdateScrollbar(renderer, self.mInventory)
    else

    end
end

function ShopState:IsEquipmentBetter(actor, itemDef)

    -- Only compare weapons or armor
    if itemDef.type == "weapon" then
        -- compare attack power
        local diff = actor:PredictStats("weapon", itemDef)
        return diff.attack > 0
    elseif itemDef.type == "armor" then
        -- compare defense power
        local diff = actor:PredictStats("armor", itemDef)
        return diff.defense > 0
    end

    return false

end


function ShopState:SetItemData(item)
    if item then
        local party = self.mWorld.mParty
        self.mItemInvCount = self.mWorld:ItemCount(item.id)
        self.mItemEquipCount = party:EquipCount(item.id)
        local def = ItemDB[item.id]
        self.mItemDef = def
        self.mItemDescription = def.description
    else
        self.mItemInvCount = 0
        self.mItemEquipCount = 0
        self.mItemDescription = ""
        self.mItemDef = nil
    end
end

function ShopState:UpdateScrollbar(renderer, selection)

    if selection:PercentageShown() <= 1 then
        local scrolled = selection:PercentageScrolled()
        local caretScale = selection:PercentageShown()
        self.mScrollbar:SetScrollCaretScale(caretScale)
        self.mScrollbar:SetNormalValue(scrolled)
        self.mScrollbar:Render(renderer)
    end

end


function ShopState:HandleInput()
    if self.mState == "choose" then
        self.mChooseSelection:HandleInput()
    elseif self.mState == "buy" then
        self.mStock:HandleInput()

        if Keyboard.JustPressed(KEY_BACKSPACE) then
            self:BackToChooseState()
        end

    elseif self.mState == "sell" then
        self.mInventory:HandleInput()

        if Keyboard.JustPressed(KEY_BACKSPACE) then
            self:BackToChooseState()
        end
    end

end

function ShopState:DrawCharacters(renderer, itemDef)

    local x = self.mLayout:Left("char") + 64
    local y = self.mLayout:MidY("char")

    local selectColor = Vector.Create(1, 1, 1, 1)
    local powerColor = Vector.Create(0, 1, 1, 1)
    local shadowColor = Vector.Create(0, 0, 0, 1)

    for _, actor in ipairs(self.mActors) do

        local char = self.mActorCharMap[actor]
        local entity = char.mEntity
        entity.mSprite:SetPosition(x, y)
        entity:Render(renderer)

        local canUse = false
        local greaterPower = false
        local equipped = false

        if itemDef then
            canUse = actor:CanUse(itemDef)
            equipped = actor:EquipCount(itemDef.id) > 0
            greaterPower = self:IsEquipmentBetter(actor, itemDef)
        end

        if canUse then
            local selectY = y - (entity.mHeight / 2)
            selectY = selectY - 6 -- add space
            self.mCanUseSprite:SetPosition(x, selectY)
            self.mCanUseSprite:SetColor(selectColor)
            renderer:DrawSprite(self.mCanUseSprite)
        end

        if greaterPower then
            local selectY = y + (entity.mHeight / 2)
            local selectX = x - (entity.mWidth / 2)
            selectX = selectX - 6 -- spacing
            self.mCanUseSprite:SetPosition(selectX, selectY)
            self.mCanUseSprite:SetColor(powerColor)
            renderer:DrawSprite(self.mCanUseSprite)
        end

        if equipped then
            local equipX = x - (entity.mWidth / 2)
            local equipY = y  - (entity.mWidth / 2)
            equipX = equipX - 3

            renderer:AlignText("right", "center")
            renderer:DrawText2d(equipX + 2, equipY - 2, "E", shadowColor)
            renderer:DrawText2d(equipX, equipY, "E")
        end

        x = x + 64
    end
end

function ShopState:Render(renderer)
    for k, v in ipairs(self.mPanels)do
        v:Render(renderer)
    end

    -- Let's write the title
    renderer:AlignText("center", "center")
    renderer:ScaleText(1.25, 1.25)
    local tX = self.mLayout:MidX("title")
    local tY = self.mLayout:MidY("title")
    renderer:DrawText2d(tX, tY, self.mName)

    local x = self.mLayout:MidX("choose")
    local y = self.mLayout:MidY("choose")

    if self.mState == "choose" then

        self:RenderChooseFocus(renderer)
        self:SetItemData(nil)

    elseif self.mState == "buy" then

        local buyMessage = "What would you like?"
        renderer:AlignText("center", "center")
        renderer:DrawText2d(x, y, buyMessage)
        renderer:AlignText("left", "center")
        self.mStock:Render(renderer)
        local item = self.mStock:SelectedItem()
        self:SetItemData(item)
        self:UpdateScrollbar(renderer, self.mStock)

    elseif self.mState == "sell" then
        local sellMessage = "Show me what you have."
        renderer:AlignText("center", "center")
        renderer:DrawText2d(x, y, sellMessage)
        renderer:AlignText("left", "center")
        self.mInventory:Render(renderer)
        local item = self.mInventory:SelectedItem()
        self:SetItemData(item)
        self:UpdateScrollbar(renderer, self.mInventory)
    end

    -- Let's write the status bar
    renderer:AlignText("right", "center")
    renderer:ScaleText(1.1, 1.1)
    local statusX = self.mLayout:MidX("status") - 4
    local statusY = self.mLayout:Top("status") - 18
    local valueX = statusX + 8

    local gpText = "GP:"
    local invText = "Inventory:"
    local equipText = "Equipped:"

    local gpValue = string.format("%d", self.mWorld.mGold)
    local invValue = string.format("%d", self.mItemInvCount)
    local equipValue = string.format("%d", self.mItemEquipCount)

    renderer:DrawText2d(statusX, statusY, gpText)
    renderer:DrawText2d(statusX, statusY - 32, invText)
    renderer:DrawText2d(statusX, statusY - 50, equipText)

    renderer:AlignText("left", "center")
    renderer:DrawText2d(valueX, statusY, gpValue)
    renderer:DrawText2d(valueX, statusY - 32, invValue)
    renderer:DrawText2d(valueX, statusY - 50, equipValue)

    renderer:AlignText("left", "center")
    renderer:ScaleText(1,1)
    local descX = self.mLayout:Left("desc") + 8
    local descY = self.mLayout:MidY("desc")
    renderer:DrawText2d(descX, descY, self.mItemDescription)

    self:DrawCharacters(renderer, self.mItemDef)
end




