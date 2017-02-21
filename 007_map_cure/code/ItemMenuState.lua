ItemMenuState = {}
ItemMenuState.__index = ItemMenuState
function ItemMenuState:Create(parent)

    local layout = Layout:Create()
    layout:Contract('screen', 118, 40)
    layout:SplitHorz('screen', "top", "bottom", 0.12, 2)
    layout:SplitVert('top', "title", "category", 0.6, 2)
    layout:SplitHorz('bottom', "mid", "inv", 0.14, 2)

    local this
    this =
    {
        mParent = parent,
        mStack = parent.mStack,
        mStateMachine = parent.mStateMachine,

        mLayout = layout,
        mPanels =
        {
            layout:CreatePanel("title"),
            layout:CreatePanel("category"),
            layout:CreatePanel("mid"),
            layout:CreatePanel("inv"),
        },

        mScrollbar = Scrollbar:Create(Texture.Find("scrollbar.png"), 228),
        mItemMenus =
        {
            Selection:Create
            {
                data = gGame.World.mItems,
                spacingX = 256,
                columns = 2,
                displayRows = 8,
                spacingY = 28,
                rows = 20,
                RenderItem = function(self, renderer, x, y, item)
                    gGame.World:DrawItem(self, renderer, x, y, item)
                end,
                OnSelection = function(...) this:OnUseItem(...) end,
            },
            Selection:Create
            {
                data = gGame.World.mKeyItems,
                spacingX = 256,
                columns = 2,
                displayRows = 8,
                spacingY = 28,
                rows = 20,
                RenderItem = function(self, renderer, x, y, item)
                    gGame.World:DrawKey(self, renderer, x, y, item)
                end,
            },
        },

        mCategoryMenu = Selection:Create
        {
            data = {"Use", "Key Items"},
            OnSelection = function(...) this:OnCategorySelect(...) end,
            spacingX = 150,
            columns = 2,
            rows = 1,
        },
        mInCategoryMenu = true
    }

    for k, v in ipairs(this.mItemMenus) do
        v:HideCursor()
    end

    setmetatable(this, self)
    return this
end

function ItemMenuState:CanUseItem(itemDef)
    local useDef = itemDef.use or {}
    return useDef.can_use_on_map == true
end

function ItemMenuState:OnUseItem(index, item)
    local itemDef = ItemDB[item.id]
    if not self:CanUseItem(itemDef) then
        return
    end

    local selectId = itemDef.use.target.selector

    local targetState = MenuTargetState:Create
    {
        originState = self,
        stack = gGame.Stack,
        stateMachine = self.mStateMachine,
        targetType = itemDef.use.target.type,
        selector = MenuActorSelector[selectId],
        OnCancel = function(target) print("Cancelled") end,
        OnSelect = function(targets) self:OnItemTargetsSelected(itemDef, targets) end
    }
    gGame.Stack:Push(targetState)
end

function ItemMenuState:OnItemTargetsSelected(itemDef, targets)

    local action = itemDef.use.action
    CombatActions[action](self,
                       nil, -- the person using the item
                       targets,
                       itemDef,
                       "item")

    gGame.World:RemoveItem(itemDef.id)
end

function ItemMenuState:Enter()
    self:FocusOnCategoryMenu()
end

function ItemMenuState:Exit() end

function ItemMenuState:OnCategorySelect(index, value)
    self.mCategoryMenu:HideCursor()
    self.mInCategoryMenu = false
    local menu = self.mItemMenus[index]
    menu:ShowCursor()
end

function ItemMenuState:Render(renderer)

    local font = gGame.Font.default

    for k,v in ipairs(self.mPanels) do
        v:Render(renderer)
    end

    local titleX = self.mLayout:MidX("title")
    local titleY = self.mLayout:MidY("title")
    font:AlignText("center", "center")
    font:DrawText2d(renderer, titleX, titleY, "Items")

    font:AlignText("left", "center")
    local categoryX = self.mLayout:Left("category") + 5
    local categoryY = self.mLayout:MidY("category")
    self.mCategoryMenu:SetPosition(categoryX, categoryY)
    self.mCategoryMenu:Render(renderer)


    local descX = self.mLayout:Left("mid") + 10
    local descY = self.mLayout:MidY("mid")

    local menu = self.mItemMenus[self.mCategoryMenu:GetIndex()]

    if not self.mInCategoryMenu then
        local description = ""
        local selectedItem = menu:SelectedItem()
        if selectedItem then
            local itemDef = ItemDB[selectedItem.id]
            description = itemDef.description
        end
        font:DrawText2d(renderer, descX, descY, description)
    end

    local itemX = self.mLayout:Left("inv") - 6
    local itemY = self.mLayout:Top("inv") - 20

    menu:SetPosition(itemX, itemY)
    menu:Render(renderer)

    local scrollX = self.mLayout:Right("inv") - 14
    local scrollY = self.mLayout:MidY("inv")
    self.mScrollbar:SetPosition(scrollX, scrollY)
    self.mScrollbar:Render(renderer)
end

function ItemMenuState:Update(dt)

    local menu = self.mItemMenus[self.mCategoryMenu:GetIndex()]

    if self.mInCategoryMenu then
        if  Keyboard.JustReleased(KEY_BACKSPACE) or
            Keyboard.JustReleased(KEY_ESCAPE) then
            self.mStateMachine:Change("frontmenu")
        end
        self.mCategoryMenu:HandleInput()
    else

        if  Keyboard.JustReleased(KEY_BACKSPACE) or
            Keyboard.JustReleased(KEY_ESCAPE) then
            self:FocusOnCategoryMenu()
        end

        menu:HandleInput()
    end

    local scrolled = menu:PercentageScrolled()
    self.mScrollbar:SetScrollCaretScale(menu:PercentageShown())
    self.mScrollbar:SetNormalValue(scrolled)
end

function ItemMenuState:FocusOnCategoryMenu()
    self.mInCategoryMenu = true
    local menu = self.mItemMenus[self.mCategoryMenu:GetIndex()]
    menu:HideCursor()
    self.mCategoryMenu:ShowCursor()
end