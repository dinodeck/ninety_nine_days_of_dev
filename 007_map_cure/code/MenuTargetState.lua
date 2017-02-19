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
        mOriginalStateId = params.originId,
        mStartedInFrontMenu = (params.originId == "frontmenu"),

        mTargetType = params.targetType or MenuTargetType.One,
        mSelector = params.selector or MenuActorSelector["FirstPartyMember"],

        mFrontMenuState = nil,
        mMarker = Sprite.Create(),

        mTargets = nil,
        mActiveTargets = nil,

        OnSelect = params.OnSelect or function() end,
        OnCancel = params.OnCancel or function() end,
    }

    local markTexture = Texture.Find('cursor.png')
    this.mMarkerWidth = markTexture:GetWidth()
    this.mMarker:SetTexture(markTexture)

    setmetatable(this, self)
    return this
end

function MenuTargetState:Enter()

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

    -- If the selector is of type one then we need to select a default target
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
        self:OnCancel()
        self:Back()
    end

    if Keyboard.JustReleased(KEY_SPACE) then

        if self.mIgnoreSpaceRelease then
            self.mIgnoreSpaceRelease = false
            return
        end

        self:OnSelect(self.mActiveTargets)
        self:Back()
    end
end

-- Back out of targetting
function MenuTargetState:Back()
    self.mStack:Pop() -- remove targetting state

    -- If we're not already in the front menu, then restore previous menu
    if not self.mStartedInFrontMenu then
        self.mStateMachine:Change(self.mOriginalStateId)
    end
end