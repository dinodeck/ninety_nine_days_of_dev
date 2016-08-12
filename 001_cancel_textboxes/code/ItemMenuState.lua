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
                data = gWorld.mItems,
                spacingX = 256,
                columns = 2,
                displayRows = 8,
                spacingY = 28,
                rows = 20,
                RenderItem = function(self, renderer, x, y, item)
                    gWorld:DrawItem(self, renderer, x, y, item)
                end
            },
            Selection:Create
            {
                data = gWorld.mKeyItems,
                spacingX = 256,
                columns = 2,
                displayRows = 8,
                spacingY = 28,
                rows = 20,
                RenderItem = function(self, renderer, x, y, item)
                    gWorld:DrawKey(self, renderer, x, y, item)
                end
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

function ItemMenuState:Enter() end
function ItemMenuState:Exit() end

function ItemMenuState:OnCategorySelect(index, value)
    self.mCategoryMenu:HideCursor()
    self.mInCategoryMenu = false
    local menu = self.mItemMenus[index]
    menu:ShowCursor()
end

function ItemMenuState:Render(renderer)
    for k,v in ipairs(self.mPanels) do
        v:Render(renderer)
    end

    local titleX = self.mLayout:MidX("title")
    local titleY = self.mLayout:MidY("title")
    renderer:ScaleText(self.mParent.mTitleSize, self. mParent.mTitleSize)
    renderer:AlignText("center", "center")
    renderer:DrawText2d(titleX, titleY, "Items")

    renderer:AlignText("left", "center")
    local categoryX = self.mLayout:Left("category") + 5
    local categoryY = self.mLayout:MidY("category")
    renderer:ScaleText(self.mParent.mTitleSize, self. mParent.mTitleSize)
    self.mCategoryMenu:Render(renderer)
    self.mCategoryMenu:SetPosition(categoryX, categoryY)

    local descX = self.mLayout:Left("mid") + 10
    local descY = self.mLayout:MidY("mid")
    renderer:ScaleText(self.mParent.mTextSize, self. mParent.mTextSize)

    local menu = self.mItemMenus[self.mCategoryMenu:GetIndex()]

    if not self.mInCategoryMenu then
        local description = ""
        local selectedItem = menu:SelectedItem()
        if selectedItem then
            local itemDef = ItemDB[selectedItem.id]
            description = itemDef.description
        end
        renderer:DrawText2d(descX, descY, description)
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