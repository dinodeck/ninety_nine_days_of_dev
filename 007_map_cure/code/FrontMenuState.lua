
FrontMenuState = {}
FrontMenuState.__index = FrontMenuState
function FrontMenuState:Create(parent)

    local layout = Layout:Create()
    layout:Contract('screen', 118, 40)
    layout:SplitHorz('screen', "top", "bottom", 0.12, 2)
    layout:SplitVert('bottom', "left", "party", 0.726, 2)
    layout:SplitHorz('left', "menu", "gold", 0.7, 2)

    local this
    this =
    {
        mParent = parent,
        mStack = parent.mStack,
        mStateMachine = parent.mStateMachine,
        mLayout = layout,

        mSelections = Selection:Create
        {
            spacingY = 28,
            data =
            {
                { id = "items",     stateId = "items",  text = "Items" },
                { id = "status",    stateId = "status", text = "Status" },
                { id = "equipment", stateId = "equip",  text = "Equipment" },
                { id = "magic",     stateId = "magic",  text = "Magic"},
                { id = "save", text = "Save" },
                { id = "load", text = "Load" }
            },
            RenderItem = function(...) this:RenderMenuItem(...) end,
            OnSelection = function(...) this:OnMenuClick(...) end
        },

        mPanels =
        {
            layout:CreatePanel("gold"),
            layout:CreatePanel("top"),
            layout:CreatePanel("party"),
            layout:CreatePanel("menu")
        },
        mTopBarText = parent.mMapDef.name,
        mInPartyMenu = false,
    }

    setmetatable(this, self)


    this.mSelections.mX = this.mLayout:MidX("menu") - 60
    this.mSelections.mY = this.mLayout:Top("menu") - 24

    this.mPartyMenu = Selection:Create
    {
        spacingY = 90,
        data = this:CreatePartySummaries(),
        columns = 1,
        rows = 3,
        OnSelection = function(...) this:OnPartyMemberChosen(...) end,
        RenderItem = function(menu, renderer, x, y, item)
            if item then
                item:SetPosition(x, y + 35)
                item:Render(renderer)
            end
        end
    }
    this.mPartyMenu:HideCursor()

    return this
end

function FrontMenuState:RenderMenuItem(menu, renderer, x, y, item)

    local color = Vector.Create(1, 1, 1, 1)
    local canSave = self.mParent.mMapDef.can_save
    local text = item.text

    if item.id == "save" and not canSave then
        color = Vector.Create(0.6, 0.6, 0.6, 1)
    end

    if item.id == "load" and not Save:DoesExist() then
        color = Vector.Create(0.6, 0.6, 0.6, 1)
    end

    if item then
        local font = gGame.Font.default
        font:AlignText("left", "center")
        font:DrawText2d(renderer, x, y, text, color)
    end
end

function FrontMenuState:Enter()
    local partyX = self.mLayout:Left("party") - 16
    local partyY = self.mLayout:Top("party") - 45
    self.mPartyMenu:SetPosition(partyX, partyY)
end

function FrontMenuState:Exit()
end

function Selection:JumpToFirstItem()
    self.mFocusY = 1
    self.mFocusX = 1
    self.mDisplayStart = 1
end

function FrontMenuState:OnMenuClick(index, item)

    if item.id == "items" then
        return self.mStateMachine:Change("items")
    end

    if item.id == "save" then
        if self.mParent.mMapDef.can_save then
            self.mStack:Pop()
            Save:Save()
            self.mStack:PushFit(gRenderer, 0, 0, "Saved!")
        end
        return
    end

    if item.id == "load" then
        if Save:DoesExist() then
            Save:Load()
            gGame.Stack:PushFit(gRenderer, 0, 0, "Loaded!")
        end
        return
    end

    self.mPartyMenu:JumpToFirstItem()
    self.mInPartyMenu = true
    self.mSelections:HideCursor()
    self.mPartyMenu:ShowCursor()
    self.mPrevTopBarText = self.mTopBarText
    self.mTopBarText = "Choose a party member"

    if item.id == "magic" then
        local member = self.mPartyMenu:SelectedItem()
        local memberCount = #self.mPartyMenu.mDataSource

        -- Start at the top and scroll down
        -- until you hit a mage character

        while member.mActor.mId ~= "mage" and
            self.mPartyMenu.mFocusY < memberCount do

            self.mPartyMenu:MoveDown()
            member = self.mPartyMenu:SelectedItem()
        end

        if(member.mActor.mId ~= "mage") then
            print("Couldn't find mage!");
            self.mPartyMenu:JumpToFirstItem()
        end

    end
end

function FrontMenuState:OnPartyMemberChosen(actorIndex, actorSummary)

    local item = self.mSelections:SelectedItem()
    local actor = actorSummary.mActor

    self.mStateMachine:Change(item.stateId, actor)
end

function FrontMenuState:HandlePartyMenuInput()

    local item = self.mSelections:SelectedItem()

    if item.id == "magic" then
        if Keyboard.JustPressed(KEY_SPACE) then
            self.mPartyMenu:OnClick()
        end
        return
    end

    self.mPartyMenu:HandleInput()

end

function FrontMenuState:Update(dt)

    if self.mInPartyMenu then

        self:HandlePartyMenuInput()

        if Keyboard.JustPressed(KEY_BACKSPACE) or
           Keyboard.JustPressed(KEY_ESCAPE) then
            self.mInPartyMenu = false
            self.mTopBarText = self.mPrevTopBarText
            self.mSelections:ShowCursor()
            self.mPartyMenu:HideCursor()
       end

    else
        self.mSelections:HandleInput()

        if Keyboard.JustPressed(KEY_BACKSPACE) or
           Keyboard.JustPressed(KEY_ESCAPE) then
            self.mStack:Pop()
        end

    end
end

function FrontMenuState:CreatePartySummaries()

    local partyMembers = gGame.World.mParty.mMembers

    local out = {}
    for _, v in pairs(partyMembers) do
        print(_, v, v.mName)
        local summary = ActorSummary:Create(v,
            { showXP = true})
        table.insert(out, summary)
    end

    print("Out size", #out)
    return out
end

function FrontMenuState:Render(renderer)

    local font = gGame.Font.default

    for k, v in ipairs(self.mPanels) do
        v:Render(renderer)
    end

    renderer:ScaleText(self.mParent.mTitleSize, self. mParent.mTitleSize)
    renderer:AlignText("left", "center")
    local menuX = self.mLayout:Left("menu") - 16
    local menuY = self.mLayout:Top("menu") - 24
    self.mSelections:SetPosition(menuX, menuY)
    self.mSelections:Render(renderer)

    local nameX = self.mLayout:MidX("top")
    local nameY = self.mLayout:MidY("top")
    font:AlignText("center", "center")
    font:DrawText2d(renderer, nameX, nameY, self.mTopBarText)

    local goldX = self.mLayout:MidX("gold") - 22
    local goldY = self.mLayout:MidY("gold") + 22

    font:AlignText("right", "top")
    font:DrawText2d(renderer, goldX, goldY, "GP:")
    font:DrawText2d(renderer, goldX, goldY - 25, "TIME:")
    font:AlignText("left", "top")

    font:AlignText("left", "top")
    font:DrawText2d(renderer, math.floor(goldX + 10), math.floor(goldY), gGame.World:GoldAsString())
    font:DrawText2d(renderer, goldX + 10, goldY - 25, gGame.World:TimeAsString())

    self.mPartyMenu:Render(renderer)
end

function FrontMenuState:HideOptionsCursor()
    self.mSelections:HideCursor()
end

function FrontMenuState:GetPartyAsSelectionTargets()
    local targets = {}

    local x = self.mPartyMenu.mX
    local y = self.mPartyMenu.mY
    local cursorWidth = self.mPartyMenu:CursorWidth()

    for k, v in ipairs(self.mPartyMenu.mDataSource) do

        local indexFrom0 = k - 1

        table.insert(targets,
                     {
                        x = x + cursorWidth * 0.5,
                        y = y - (indexFrom0 * self.mPartyMenu.mSpacingY),
                        summary = v
                    })
    end
    return targets
end