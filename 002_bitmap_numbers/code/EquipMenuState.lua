EquipMenuState = {}
EquipMenuState.__index = EquipMenuState
function EquipMenuState:Create(parent)

    local this =
    {
        mParent = parent,
        mStack = parent.mStack,
        mStateMachine = parent.mStateMachine,
        mScrollbar = Scrollbar:Create(Texture.Find('scrollbar.png'), 135),
        mBetterSprite = gWorld.mIcons:Get('uparrow'),
        mWorseSprite = gWorld.mIcons:Get('downarrow'),
        mInList = false
    }

    this.mBetterSprite:SetColor(Vector.Create(0,1,0,1))
    this.mWorseSprite:SetColor(Vector.Create(1,0,0,1))

    -- Create panel layout
    local layout = Layout:Create()
    layout:Contract('screen', 118, 40)
    layout:SplitHorz('screen', 'top', 'bottom', 0.12, 2)
    layout:SplitVert('top', 'title', 'category', 0.75, 2)
    local titlePanel = layout.mPanels['title']

    layout = Layout:Create()
    layout:Contract('screen', 118, 40)
    layout:SplitHorz('screen', 'top', 'bottom', 0.42, 2)
    layout:SplitHorz('bottom', 'desc', 'bottom', 0.2, 2)
    layout:SplitVert('bottom', 'stats', 'list', 0.6, 2)
    layout.mPanels['title'] = titlePanel

    self.mPanels =
    {
        layout:CreatePanel('top'),
        layout:CreatePanel('desc'),
        layout:CreatePanel('stats'),
        layout:CreatePanel('list'),
        layout:CreatePanel('title'),
    }
    self.mLayout = layout

    setmetatable(this, self)
    return this
end

function EquipMenuState:RefreshFilteredMenus()

    -- Get a list of filters by slot type
    -- Items will be sorted into these lists
    local filterList = {}
    local slotCount = #self.mActor.mActiveEquipSlots

    for i = 1, slotCount do
        local slotType = self.mActor.mSlotTypes[i]
        filterList[i] = { type = slotType, list = {} }
    end


    -- Actually sort inventory items into lists.
    for k, v in ipairs(gWorld.mItems) do

        local item = ItemDB[v.id]

        for i, filter in ipairs(filterList) do

            if  item.type == filter.type
                and self.mActor:CanUse(item) then
                table.insert(filter.list, v)
            end

        end
    end

    self.mFilterMenus = {}
    for k, v in ipairs(filterList) do
        local menu = Selection:Create
        {
            data = v.list,
            columns = 1,
            spacingX = 256,
            displayRows = 5,
            spacingY = 26,
            rows = 20,
            RenderItem = function(self, renderer, x, y, item)
                gWorld:DrawItem(self, renderer, x, y, item)
            end,
            OnSelection = function(...) self:OnDoEquip(...) end
        }
        table.insert(self.mFilterMenus, menu)
    end
end

function EquipMenuState:OnSelectMenu(index, item)
    self.mInList = true
    self.mSlotMenu:HideCursor()
    self.mMenuIndex = self.mSlotMenu:GetIndex()
    self.mFilterMenus[self.mMenuIndex]:ShowCursor()
end

function EquipMenuState:Enter(actor)
    self.mActor = actor
    self.mActorSummary = ActorSummary:Create(actor)
    self.mEquipment = actor.mEquipment

    self:RefreshFilteredMenus()

    self.mMenuIndex = 1
    self.mFilterMenus[self.mMenuIndex]:HideCursor()

    self.mSlotMenu = Selection:Create
    {
        data = self.mActor.mActiveEquipSlots,
        OnSelection = function(...) self:OnSelectMenu(...)  end,
        columns = 1,
        rows = #self.mActor.mActiveEquipSlots,
        spacingY = 26,
        RenderItem = function(...) self.mActor:RenderEquipment(...) end
    }
end

function EquipMenuState:Exit()
end

function EquipMenuState:Update(dt)

    local menu = self.mFilterMenus[self.mMenuIndex]

    if self.mInList then
        menu:HandleInput()
        if  Keyboard.JustReleased(KEY_BACKSPACE) or
            Keyboard.JustReleased(KEY_ESCAPE) then
            self:FocusSlotMenu()
        end
    else
        local prevEquipIndex = self.mSlotMenu:GetIndex()
        self.mSlotMenu:HandleInput()
        if prevEquipIndex ~= self.mSlotMenu:GetIndex() then
            self:OnEquipMenuChanged()
        end
        if  Keyboard.JustReleased(KEY_BACKSPACE) or
            Keyboard.JustReleased(KEY_ESCAPE) then
            self.mStateMachine:Change("frontmenu")
        end
    end

    local scrolled = menu:PercentageScrolled()
    self.mScrollbar:SetNormalValue(scrolled)
end

function EquipMenuState:GetSelectedSlot()
    local i = self.mSlotMenu:GetIndex()
    return Actor.EquipSlotId[i]
end

function EquipMenuState:Render(renderer)
    for _, v in ipairs(self.mPanels) do
        v:Render(renderer)
    end

        -- Title
    renderer:ScaleText(1.5, 1.5)
    renderer:AlignText("center", "center")
    local titleX = self.mLayout:MidX("title")
    local titleY = self.mLayout:MidY("title")
    renderer:DrawText2d(titleX, titleY, "Equip")

    -- Char summary
    local titleHeight = self.mLayout.mPanels["title"].height
    local avatarX = self.mLayout:Left("top")
    local avatarY = self.mLayout:Top("top")
    avatarX = avatarX + 10
    avatarY = avatarY - titleHeight - 10
    self.mActorSummary:SetPosition(avatarX, avatarY)
    self.mActorSummary:Render(renderer)

    -- Slots selection
    local equipX = self.mLayout:MidX("top") - 20
    local equipY = self.mLayout:Top("top") - titleHeight - 10
    self.mSlotMenu:SetPosition(equipX, equipY)
    renderer:ScaleText(1.25,1.25)
    self.mSlotMenu:Render(renderer)

    -- Inventory list
    local listX = self.mLayout:Left("list") + 6
    local listY = self.mLayout:Top("list") - 20
    local menu = self.mFilterMenus[self.mMenuIndex]
    menu:SetPosition(listX, listY)
    menu:Render(renderer)

    -- Scroll bar
    local scrollX = self.mLayout:Right("list") - 14
    local scrollY = self.mLayout:MidY("list")
    self.mScrollbar:SetPosition(scrollX, scrollY)
    self.mScrollbar:Render(renderer)

    -- Char stat panel
    local slot = self:GetSelectedSlot()
    local itemId = self:GetSelectedItem() or -1

    local diffs = self.mActor:PredictStats(slot, ItemDB[itemId])
    local x = self.mLayout:MidX("stats") - 10
    local y = self.mLayout:Top("stats") - 14
    renderer:ScaleText(1,1)

    local statList = self.mActor:CreateStatNameList()
    local statLabels = self.mActor:CreateStatLabelList()

    for k, v in ipairs(statList) do
        self:DrawStat(renderer, x, y, statLabels[k], v, diffs[v])
        y = y - 14
    end

    -- Description panel
    local descX = self.mLayout:Left("desc") + 10
    local descY = self.mLayout:MidY("desc")
    renderer:ScaleText(1, 1)
    local item = ItemDB[itemId]
    renderer:DrawText2d(descX, descY, item.description)
end

function EquipMenuState:DrawStat(renderer, x, y, label, stat, diff)
    renderer:AlignText("right", "center")
    renderer:DrawText2d(x, y, label)
    renderer:AlignText("left", "center")

    local current = self.mActor.mStats:Get(stat)
    local changed = current + diff

    renderer:DrawText2d(x + 15, y, string.format("%d", current))

    if diff > 0 then
        renderer:DrawText2d(x + 60, y, string.format("%d", changed),
                            Vector.Create(0,1,0,1))
        self.mBetterSprite:SetPosition(x + 80, y)
        renderer:DrawSprite(self.mBetterSprite)
    elseif diff < 0 then
        renderer:DrawText2d(x + 60, y, string.format("%d", changed),
                            Vector.Create(1,0,0,1))
        self.mWorseSprite:SetPosition(x + 80, y)
        renderer:DrawSprite(self.mWorseSprite)
    end

end

function EquipMenuState:GetSelectedSlot()
    local i = self.mSlotMenu:GetIndex()
    return Actor.EquipSlotId[i]
end

function EquipMenuState:GetSelectedItem()
    if self.mInList then
        local menu = self.mFilterMenus[self.mMenuIndex]
        local item = menu:SelectedItem() or {id = nil}
        return item.id
    else
        local slot = self:GetSelectedSlot()
        return self.mActor.mEquipment[slot]
    end
end

function EquipMenuState:FocusSlotMenu()
    self.mInList = false
    self.mSlotMenu:ShowCursor()
    self.mMenuIndex = self.mSlotMenu:GetIndex()
    self.mFilterMenus[self.mMenuIndex]:HideCursor()
end


function EquipMenuState:OnEquipMenuChanged()
    self.mMenuIndex = self.mSlotMenu:GetIndex()

    -- Equip menu only changes, when list isn't in focus
    self.mFilterMenus[self.mMenuIndex]:HideCursor()
end

function EquipMenuState:OnDoEquip(index, item)
    -- Let the character handle this.
    self.mActor:Equip(self:GetSelectedSlot(), item)
    self:RefreshFilteredMenus()
    self:FocusSlotMenu()
end
