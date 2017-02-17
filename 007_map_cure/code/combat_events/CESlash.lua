CESlash = {}
CESlash.__index = CESlash
function CESlash:Create(state, owner, def, targets)

    local this =
    {
        mState = state,
        mOwner = owner,
        mDef = def,
        mFinished = false,
        mCharacter = state.mActorCharMap[owner],
        mTargets = targets,
        mIsFinished = false
    }

    this.mController = this.mCharacter.mController
    this.mController:Change(CSRunAnim.mName, {'prone'})
    this.mName = string.format("Slash for %s", this.mOwner.mName)

    setmetatable(this, self)

    local storyboard = nil

    this.mAttackAnim = gEntities.slash
    this.mDefaultTargeter = CombatSelector.SideEnemy

    storyboard =
    {
        SOP.Function(function() this:ShowNotice() end),
        SOP.Wait(0.2),
        SOP.RunState(this.mController, CSMove.mName, {dir = 1}),
        SOP.RunState(this.mController, CSRunAnim.mName, {'slash', false, 0.05}),
        SOP.NoBlock(
            SOP.RunState(this.mController, CSRunAnim.mName, {'prone'})
        ),
        SOP.Function(function() this:DoAttack() end),
        SOP.RunState(this.mController, CSMove.mName, {dir = -1}),
        SOP.Wait(0.2),
        SOP.Function(function() this:OnFinish() end)
    }


    this.mStoryboard = Storyboard:Create(this.mState.mStack,
                                         storyboard)

    return this
end

function CESlash:TimePoints(queue)
    local speed = self.mOwner.mStats:Get("speed")
    local tp = queue:SpeedToTimePoints(speed)
    return tp + self.mDef.time_points
end

function CESlash:ShowNotice()
    self.mState:ShowNotice(self.mDef.name)
end

function CESlash:Execute(queue)
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


function CESlash:OnFinish()
    self.mIsFinished = true
end

function CESlash:IsFinished()
    return self.mIsFinished
end

function CESlash:Update()
end

function CESlash:DoAttack()
    self.mState:HideNotice()

    local mp = self.mOwner.mStats:Get("mp_now")
    local cost = self.mDef.mp_cost
    local mp = math.max(mp - cost, 0) -- don't handle fizzle

    self.mOwner.mStats:Set("mp_now", mp)

    for _, target in ipairs(self.mTargets) do
        self:AttackTarget(target)

        if not self.mDef.counter then
            self:CounterTarget(target)
        end
    end
end

-- Decide if the attack is countered.
function CESlash:CounterTarget(target)
    local countered = Formula.IsCountered(self.mState, self.mOwner, target)
    if countered then
        self.mState:ApplyCounter(target, self.mOwner)
    end
end

function CESlash:AttackTarget(target)

    local damage, hitResult = Formula.MeleeAttack(self.mState,
                                                  self.mOwner,
                                                  target)

    -- hit result lets us know the status of this attack


    local entity = self.mState.mActorCharMap[target].mEntity

    if hitResult == HitResult.Miss then
        self.mState:ApplyMiss(target)
        return
    elseif hitResult == HitResult.Dodge then
        self.mState:ApplyDodge(target)
    else
        local isCrit = hitResult == HitResult.Critical
        self.mState:ApplyDamage(target, damage, isCrit)
    end

    local x = entity.mX
    local y = entity.mY
    local effect = AnimEntityFx:Create(x, y,
                            self.mAttackAnim,
                            self.mAttackAnim.frames)

    self.mState:AddEffect(effect)
end