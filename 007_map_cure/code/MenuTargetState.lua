MenuTargetType =
{
    One = "One",
    All = "All",
}

MenuTargetState = {}
MenuTargetState.__index = MenuTargetState
function MenuTargetState:Create(params)

    print(params.selector)

    params = params or {}

    local this =
    {
        mStack = params.stack,
        mStateMachine = params.stateMachine,
        mOriginalState = params.originState,
        mStartedInFrontMenu = (params.originId == "frontmenu"),

        mTargetType = params.targetType or MenuTargetType.One,
        mSelector = params.selector or MenuActorSelector["FirstPartyMember"],

        mFrontMenuState = nil,
        mMarker = Sprite.Create(),

        mTargets = nil,
        mActiveTargets = nil,

        OnSelect = params.OnSelect or function() end,
        OnCancel = params.OnCancel or function() end,

        mIndex = 1, -- used in MenuTargetType.One
    }

    local markTexture = Texture.Find('cursor.png')
    this.mMarkerWidth = markTexture:GetWidth()
    this.mMarker:SetTexture(markTexture)

    setmetatable(this, self)
    return this
end

function MenuTargetState:Enter()

    self.mIndex = 1

    -- Selection for previous state should be ignored!
    self.mIgnoreSpaceRelease = Keyboard.JustPressed(KEY_SPACE)

    if not self.mStartedInFrontMenu then
        self.mStateMachine:Change("frontmenu")
    end

    self.mFrontMenuState = self.mStateMachine:Current()
    self.mFrontMenuState:HideOptionsCursor()

    -- Need to get the list of targets with position
    -- Of the form { x = 0, y = 0, summary = Y }
    self.mTargets = self.mFrontMenuState:GetPartyAsSelectionTargets()

    -- Filter the target by the selector
    self.mActiveTargets = self.mSelector(self.mTargets)

    if self.mTargetType == MenuTargetType.One then
        self.mIndex = self:FindIndex()
    end
end

function MenuTargetState:FindIndex()

    for k, v in ipairs(self.mTargets) do
        if self.mActiveTargets[1] == v then
            return k
        end
    end

    print("Error: Failed to find index!")
    return 1

end


function MenuTargetState:Exit()
end

function MenuTargetState:Update(dt)
end

function MenuTargetState:Render(renderer)
    local font = gGame.Font.default

    for k, v in ipairs(self.mActiveTargets) do
        self.mMarker:SetPosition(v.x, v.y)
        renderer:DrawSprite(self.mMarker)
    end
end

function MenuTargetState:HandleInput()

    -- Released otherwise the keypress gets picked up in the state
    -- we transition to
    if Keyboard.JustReleased(KEY_BACKSPACE) or
       Keyboard.JustReleased(KEY_ESCAPE) then
        self.OnCancel()
        self:Back()
    end

    if Keyboard.JustReleased(KEY_SPACE) then

        if self.mIgnoreSpaceRelease then
            self.mIgnoreSpaceRelease = false
            return
        end

        self.OnSelect(self.mActiveTargets)
        self:Back()
    end

    if Keyboard.JustPressed(KEY_UP) then
        self:Up()
    elseif Keyboard.JustPressed(KEY_DOWN) then
        self:Down()
    end
end

function MenuTargetState:Up()
    if self.mTargetType ~= MenuTargetType.One then
        return
    end

    local newIndex = self.mIndex

    while newIndex > 0 do
        newIndex = newIndex - 1

        local targets = self.mSelector({self.mTargets[newIndex]})

        if next(targets) then
            self.mIndex = newIndex
            self.mActiveTargets = targets
            return
        end
    end
end

function MenuTargetState:Down()
    if self.mTargetType ~= MenuTargetType.One then
        return
    end

    local newIndex = self.mIndex

    while newIndex <= #self.mTargets do
        newIndex = newIndex + 1

        local targets = self.mSelector({self.mTargets[newIndex]})

        if next(targets) then
            self.mIndex = newIndex
            self.mActiveTargets = targets
            return
        end
    end
end

-- Back out of targetting
function MenuTargetState:Back()
    self.mStack:Pop() -- remove targetting state

    -- If we're not already in the front menu, then restore previous menu
    if not self.mStartedInFrontMenu then
        self.mStateMachine.mCurrent = self.mOriginalState
    end
end