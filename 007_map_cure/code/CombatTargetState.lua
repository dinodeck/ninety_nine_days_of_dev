
CombatTargetType =
{
    One = "One",
    Side = "Side",
    All = "All",
}

CombatTargetState = {}
CombatTargetState.__index = CombatTargetState
function CombatTargetState:Create(context, params)

    if params.switchSides == nil then
        params.switchSides = true
    end

    local this =
    {
        mCombatState = context,
        mStack = context.mStack,
        mDefaultSelector = params.defaultSelector,
        mCanSwitchSide = params.switchSides,
        mTargetType = params.targetType or CombatTargetType.One,
        mOnSelect = params.OnSelect,
        mOnExit = params.OnExit or function() end,
        mTargets = {},
        mMarker = Sprite.Create(),
        mEnemy = {},
        mParty = {},
    }

    if this.mDefaultSelector == nil then

        if this.mTargetType == CombatTargetType.One then
            this.mDefaultSelector = CombatSelector.WeakestEnemy
        elseif this.mTargetType == CombatTargetType.Side then
            this.mDefaultSelector = CombatSelector.SideEnemy
        elseif this.mTargetType == CombatTargetType.All  then
            this.mDefaultSelector = CombatSelector.SelectAll
        end

    end

    local markTexture = Texture.Find('cursor.png')
    this.mMarkerWidth = markTexture:GetWidth()
    this.mMarker:SetTexture(markTexture)
    this.mMarker:SetUVs(1,1,0,0)


    setmetatable(this, self)

    return this
end


function CombatTargetState:Enter(actor)

    self.mActor = actor
    self.mEnemy = self.mCombatState.mActors["enemy"]
    self.mParty = self.mCombatState.mActors["party"]

    self.mTargets = self.mDefaultSelector(self.mCombatState)

end

function CombatTargetState:Exit()

    self.mActor = nil
    self.mEnemy = {}
    self.mParty = {}
    self.mTargets = {}

    self.mOnExit()

end

function CombatTargetState:Update(dt)
end

function CombatTargetState:GetActorList(actor)
    local isParty = self.mCombatState:IsPartyMember(actor)
    if isParty then
        return self.mParty
    else
        return self.mEnemy
    end
end

function CombatTargetState:GetIndex(list, item)
    for k, v in ipairs(list) do
        if v == item then
            return k
        end
    end
    return -1
end

function CombatTargetState:Up()

    if self.mTargetType ~= CombatTargetType.One then
        return
    end

    local target = self.mTargets[1]
    local side = self:GetActorList(target)
    local index = self:GetIndex(side, target)

    index = index - 1
    if index == 0 then
        index = #side
    end
    self.mTargets = { side[index] }

end

function CombatTargetState:Down()
    if self.mTargetType ~= CombatTargetType.One then
        return
    end

    local target = self.mTargets[1]
    local side = self:GetActorList(target)
    local index = self:GetIndex(side, target)

    index = index + 1

    if index > #side then
        index = 1
    end

    self.mTargets = { side[index] }
end

function CombatTargetState:Left()
    if not self.mCanSwitchSide then
        return
    end

    if not self.mCombatState:IsPartyMember(self.mTargets[1]) then
        return
    end

    if self.mTargetType == CombatTargetType.One then
        self.mTargets = { self.mEnemy[1] }
    end

    if self.mTargetType == CombatTargetType.Side then
        self.mTargets = self.mEnemy
    end
end

function CombatTargetState:Right()
    if not self.mCanSwitchSide then
        return
    end

    if self.mCombatState:IsPartyMember(self.mTargets[1]) then
        return
    end

   if self.mTargetType == CombatTargetType.One then
        self.mTargets = { self.mParty[1] }
    end

    if self.mTargetType == CombatTargetType.Side then
        self.mTargets = self.mParty
    end
end


function CombatTargetState:Render(renderer)
    for k, v in ipairs(self.mTargets) do
        local char = self.mCombatState.mActorCharMap[v]

        --
        -- GetTargetPosition is new!
        --
        local pos = char.mEntity:GetTargetPosition()
        pos:SetX(pos:X() + self.mMarkerWidth/2)
        self.mMarker:SetPosition(pos)
        renderer:DrawSprite(self.mMarker)
    end
end

function CombatTargetState:HandleInput()

    if Keyboard.JustPressed(KEY_BACKSPACE) then
        self.mStack:Pop()
    elseif Keyboard.JustPressed(KEY_UP) then
        self:Up()
    elseif Keyboard.JustPressed(KEY_DOWN) then
        self:Down()
    elseif Keyboard.JustPressed(KEY_LEFT) then
        self:Left()
    elseif Keyboard.JustPressed(KEY_RIGHT) then
        self:Right()
    elseif Keyboard.JustPressed(KEY_SPACE) then
        self.mOnSelect(self.mTargets)
    end
end