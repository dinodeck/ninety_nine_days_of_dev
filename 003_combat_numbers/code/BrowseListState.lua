
BrowseListState = {}
BrowseListState.__index = BrowseListState
function BrowseListState:Create(params)

    params = params or {}


    local this =
    {
        mStack = params.stack,
        mX = params.x or 0,
        mY = params.y or 0,
        mWidth = params.width or 264,
        mHeight = params.height or 75,
        mTitle = params.title or "LIST",

        mOnExit = params.OnExit or function() end,
        mOnFocus = params.OnFocus or function() end,
        mUpArrow = gWorld.mIcons:Get('uparrow'),
        mDownArrow = gWorld.mIcons:Get('downarrow'),
        mHide = false
    }

    local data = params.data or {}
    local columns = params.columns or 2
    local displayRows = params.rows or 3
    local itemCount = math.max(columns, #data)
    local maxRows = math.max(displayRows, itemCount / columns)
    local selectCallback = params.OnSelection or function() end
    this.mSelection = Selection:Create
    {
        data = data,
        columns = columns,
        displayRows = displayRows,
        rows = maxRows,
        spacingX = 132,
        spacingY = 19,
        OnSelection = function(...) selectCallback(this, ...) end,
        RenderItem = params.OnRenderItem
    }

    setmetatable(this, self)

    this.mBox = this:CreatePanel(this.mX, this.mY, this.mWidth, this.mHeight)
    this:SetArrowPosition()
    this.mSelection:SetPosition(this.mX - 24, this.mY - 24)

    return this
end

function BrowseListState:SetArrowPosition()
    local arrowPad = 9
    local arrowX = self.mX + self.mWidth - arrowPad
    self.mUpArrow:SetPosition(arrowX, self.mY - arrowPad)
    self.mDownArrow:SetPosition(arrowX, self.mY - self.mHeight + arrowPad)
end

function BrowseListState:CreatePanel(x, y, width, height)

    local panel  = Panel:Create
    {
        texture = Texture.Find("gradient_panel.png"),
        size = 3,
    }
    panel:Position(x, y, x + width, y - height)

    -- local arrowPad = 9
    -- local arrowX = x + width - arrowPad
    -- self.mUpArrow:SetPosition(arrowX, y - arrowPad)
    -- self.mDownArrow:SetPosition(arrowX, y - height + arrowPad)
    return panel
end

function BrowseListState:Enter()
    self.mOnFocus(self.mSelection:SelectedItem())
end

function BrowseListState:Exit()
    self.mOnExit()
end

function BrowseListState:Update(dt)
end

function BrowseListState:Hide()
    self.mHide = true
end

function BrowseListState:Show()
    self.mHide = false
    self.mOnFocus(self.mSelection:SelectedItem())
end

function BrowseListState:Render(renderer)

    if self.mHide then
        return
    end

    self.mBox:Render(renderer)

    if self.mSelection:CanScrollUp() then
        renderer:DrawSprite(self.mUpArrow)
    end
    if self.mSelection:CanScrollDown() then
        renderer:DrawSprite(self.mDownArrow)
    end

    renderer:ScaleText(1.1, 1.1)
    renderer:AlignText("left", "top")
    local shadow = Vector.Create(0,0,0,1)
    renderer:DrawText2d(self.mX + 6, self.mY - 3, self.mTitle, shadow)
    renderer:DrawText2d(self.mX + 5, self.mY - 2, self.mTitle)

    renderer:AlignText("left", "center")
    renderer:ScaleText(1.0, 1.0)
    self.mSelection:Render(renderer)

end

function BrowseListState:HandleInput()
    if Keyboard.JustPressed(KEY_BACKSPACE) then
        self.mStack:Pop()
        return
    end
    local prevIndex = self.mSelection:GetIndex()

    self.mSelection:HandleInput()

    if prevIndex ~= self.mSelection:GetIndex() then
        self.mOnFocus(self.mSelection:SelectedItem())
    end
end