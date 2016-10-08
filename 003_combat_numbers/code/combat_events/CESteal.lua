CESteal = {}
CESteal.__index = CESteal
function CESteal:Create(state, owner, def, targets)

    local this =
    {
        mState = state,
        mOwner = owner,
        mDef = def,
        mFinished = false,
        mCharacter = state.mActorCharMap[owner],
        mTargets = targets,
        mIsFinished = false,
        mSuccess = false,
    }

    this.mController = this.mCharacter.mController
    this.mController:Change(CSRunAnim.mName, {'prone'})
    this.mName = string.format("Steal for %s", this.mOwner.mName)

    this.mOriginalPos = this.mCharacter.mEntity.mSprite:GetPosition()

    setmetatable(this, self)

    local storyboard = nil

    this.mAnim = gEntities.slash
    this.mDefaultTargeter = CombatSelector.WeakestEnemy

    storyboard =
    {
        SOP.Function(function() this:ShowNotice() end),
        SOP.Wait(0.2),
        SOP.RunState(this.mController, CSMove.mName, {dir = 1}),
        SOP.RunState(this.mController, CSRunAnim.mName, {'steal_1', false}),
        SOP.Function(function() this:TeleportOut() end),
        SOP.RunState(this.mController, CSRunAnim.mName, {'steal_2', false}),
        SOP.Wait(1.1),
        SOP.Function(function() this:DoSteal() end),
        SOP.RunState(this.mController, CSRunAnim.mName, {'steal_3', false}),
        SOP.Function(function() this:TeleportIn() end),
        SOP.RunState(this.mController, CSRunAnim.mName, {'steal_4', false}),
        SOP.Function(function() this:ShowResult() end),
        SOP.Wait(1.0),
        SOP.Function(function() this.mState:HideNotice() end),
        SOP.RunState(this.mController, CSMove.mName, {dir = -1}),
        SOP.Wait(0.2),
        SOP.Function(function() this:OnFinish() end)
    }

    this.mStoryboard = Storyboard:Create(this.mState.mStack,
                                         storyboard)

    return this
end

function CESteal:TeleportOut()
    local target = self.mTargets[1]
    local entity = self.mState.mActorCharMap[target].mEntity
    local width = entity.mTexture:GetWidth() + 32

    local pos = entity.mSprite:GetPosition()
    pos:SetX(math.floor(pos:X() - width / 2))

    self.mCharacter.mEntity.mSprite:SetPosition(pos)
end

function CESteal:ShowResult()
    if self.mSuccess then
        self.mController:Change(CSRunAnim.mName, {'steal_success'})
    else
        self.mController:Change(CSRunAnim.mName, {'steal_failure'})
    end
end

function CESteal:TeleportIn()
    self.mCharacter.mEntity.mSprite:SetPosition(self.mOriginalPos)
end

function CESteal:TimePoints(queue)
    local speed = self.mOwner.mStats:Get("speed")
    return queue:SpeedToTimePoints(speed)
end

function CESteal:ShowNotice()
    self.mState:ShowNotice(self.mDef.name)
end

function CESteal:Execute(queue)
    self.mState.mStack:Push(self.mStoryboard)

    for i = #self.mTargets, 1, -1 do
        local v = self.mTargets[i]
        local hp = v.mStats:Get("hp_now")
        if hp <= 0 then
            table.remove(self.mTargets, i)
        end
    end

    if not next(self.mTargets) then
        -- Find another enemy
        self.mTargets = self.mDefaultTargeter(self.mState)
    end
end


function CESteal:OnFinish()
    self.mIsFinished = true
end

function CESteal:IsFinished()
    return self.mIsFinished
end

function CESteal:Update()
end

function CESteal:DoSteal()

    local target = self.mTargets[1]

    self.mState:HideNotice()

    if not target.mStealItem then
        self.mState:ShowNotice("Nothing to steal.")
        return
    end

    self.mSuccess = self:StealFrom(target)

    if self.mSuccess then
        local id = target.mStealItem
        local def = ItemDB[id]
        local name = def.name
        gWorld:AddItem(id)
        target.mStealItem = nil
        local notice = string.format("Stolen: %s.", name)
        self.mState:ShowNotice(notice)
    else
        self.mState:ShowNotice("Steal failed.")
    end

end

function CESteal:StealFrom(target)

    local success = Formula.Steal(self.mState,
                                  self.mOwner,
                                  target)

    local entity = self.mState.mActorCharMap[target].mEntity

    local x = entity.mX
    local y = entity.mY
    local effect = AnimEntityFx:Create(x, y,
                            self.mAnim,
                            self.mAnim.frames)

    self.mState:AddEffect(effect)

    return success
end