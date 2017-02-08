CETurn = {}
CETurn.__index = CETurn
function CETurn:Create(state, owner)
    local this =
    {
        mState = state,
        mOwner = owner,
        mFinished = false,
        mName = nil,
    }

    this.mName = string.format("Turn for %s", this.mOwner.mName)

    setmetatable(this, self)
    return this
end

function CETurn:TimePoints(queue)
    local speed = self.mOwner.mStats:Get("speed")
    return queue:SpeedToTimePoints(speed)
end

function CETurn:Execute(queue)

    -- 1. Am I a player?
    if self.mState:IsPartyMember(self.mOwner) then
        local state = CombatChoiceState:Create(self.mState, self.mOwner)
        self.mState.mStack:Push(state)
        self.mFinished = true
        return
    else
    -- 2. I'm an enemy, just add a new TakeTurn action
    -- we'll add AI later.
        local targets = CombatSelector.RandomAlivePlayer(self.mState)
        local def = { player = false }
        local queue = self.mState.mEventQueue
        local event = CEAttack:Create(self.mState, self.mOwner, def, targets)
        local tp = event:TimePoints(queue)
        queue:Add(event, tp)
        self.mFinished = true
        return
    end

end

function CETurn:Update()
end

function CETurn:IsFinished()
    return self.mFinished
end