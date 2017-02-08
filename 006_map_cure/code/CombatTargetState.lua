
-- Give the target state returns a list of actors
-- that are targets.

local function WeakestActor(list, onlyCheckHurt)
        local target = nil
        local health = 99999

        for k, v in ipairs(list) do
            local hp = v.mStats:Get("hp_now")
            local isHurt = hp < v.mStats:Get("hp_max")
            local skip = false
            if onlyCheckHurt and not isHurt then
                skip = true
            end

            if hp < health and not skip then
                health = hp
                target = v
            end
        end

        return { target or list[1] }
end

local function MostDrainedActor(list, onlyCheckDrained)
        local target = nil
        local magic = 99999

        for k, v in ipairs(list) do
            local mp = v.mStats:Get("mp_now")
            local isHurt = mp < v.mStats:Get("mp_max")
            local skip = false
            if onlyCheckDrained and not isHurt then
                skip = true
            end

            if mp < magic and not skip then
                magic = mp
                target = v
            end
        end

        return { target or list[1] }
end

CombatSelector =
{

    WeakestEnemy = function(state)
        return WeakestActor(state.mActors["enemy"], false)
    end,

    WeakestParty = function(state)
        return WeakestActor(state.mActors["party"], false)
    end,

    MostHurtEnemy = function(state)
        return WeakestActor(state.mActors["party"], true)
    end,

    MostHurtParty = function(state)
        print("Calling most hurt party")
        return WeakestActor(state.mActors["party"], true)
    end,

    MostDrainedParty = function(state)
        return MostDrainedActor(state.mActors["party"], true)
    end,

    DeadParty = function(state)
        local list = state.mActors["party"]

        for k, v in ipairs(list) do
            local hp = v.mStats:Get("hp_now")
            if hp == 0 then
                return { v }
            end
        end
        -- Just return the first
        return { list[1] }
    end,

    SideEnemy = function(state)
        return state.mActors["enemy"]
    end,

    SelectAll = function(state)
        local targets = {}

        for k, v in ipairs(state.mActors["enemy"]) do
            table.insert(targets, v)
        end

        for k, v in ipairs(state.mActors["party"]) do
            table.insert(targets, v)
        end

        return targets

    end,

    RandomAlivePlayer = function(state)

        local aliveList = {}
        for k, v in ipairs(state.mActors["party"]) do
            if v.mStats:Get("hp_now") > 0 then
                table.insert(aliveList, v)
            end
        end

        local target = aliveList[math.random(#aliveList)]
        return { target }
    end,
}

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
        elseif this.mTargetType == CombatTargetType.All then
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