
CEFlee = {}
CEFlee.__index = CEFlee
function CEFlee:Create(state, actor)
    local this =
    {
        mState = state,
        mOwner = actor,
        mCharacter = state.mActorCharMap[actor],
        mFleeParams = { dir = 1, distance = 180, time = 0.6 },
        mIsFinished = false,
    }

    -- Decide if flee succeeds
    this.mCanFlee = Formula.CanFlee(state, actor)

    if this.mCanFlee then
        local storyboard =
        {
            SOP.Function(function() this:Notice("Attempting to Flee...") end),
            SOP.Wait(0.75),
            SOP.Function(function() this:DoFleeSuccessPart1() end),
            SOP.Wait(0.3),
            SOP.Function(function() this:DoFleeSuccessPart2() end),
            SOP.Wait(0.6)
        }
        this.mStoryboard = Storyboard:Create(
                            this.mState.mStack,
                            storyboard)
    else
        local storyboard =
        {
            SOP.Function(function() this:Notice("Attempting to Flee...") end),
            SOP.Wait(0.75),
            SOP.Function(function() this:Notice("Failed!") end),
            SOP.Wait(0.3),
            SOP.Function(function() this:OnFleeFail() end),
        }
        this.mStoryboard = Storyboard:Create(
                            this.mState.mStack,
                            storyboard)
    end

    -- Move the character into the prone state, as soon as the event is
    -- created
    this.mCharacter.mFacing = "right"
    this.mController = this.mCharacter.mController
    this.mController:Change(CSRunAnim.mName, {'prone'})
    this.mName = string.format("Flee for %s", this.mOwner.mName)

    setmetatable(this, self)
    return this
end

function CEFlee:TimePoints(queue)
    -- Faster than an attack
    local speed = self.mOwner.mStats:Get("speed")
    return queue:SpeedToTimePoints(speed) * 0.5
end

function CEFlee:Notice(text)
    self.mState:ShowNotice(text)
end

function CEFlee:DoFleeSuccessPart1()
    self:Notice("Success!")
    self.mController:Change(CSMove.mName, self.mFleeParams)
end

function CEFlee:DoFleeSuccessPart2()
    for k, v in ipairs(self.mState.mActors['party']) do
        local alive = v.mStats:Get("hp_now") > 0
        local isFleer = v == self.mOwner

        if alive and not isFleer then
            local char = self.mState.mActorCharMap[v]
            char.mFacing = "right"
            char.mController:Change(CSMove.mName, self.mFleeParams)
        end
    end
    self.mState:OnFlee()
    self.mState:HideNotice()
end


function CEFlee:OnFleeFail()
    self.mCharacter.mFacing = "left"
    self.mController = self.mCharacter.mController
    self.mController:Change(CSStandby.mName)
    self.mIsFinished = true
    self.mState:HideNotice()
end

function CEFlee:IsFinished()
    return self.mIsFinished
end

function CEFlee:Execute()
    self.mState.mStack:Push(self.mStoryboard)
end

function CEFlee:Update(dt)
end
