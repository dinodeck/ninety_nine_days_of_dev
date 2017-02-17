
CECastSpell = {}
CECastSpell.__index = CECastSpell
function CECastSpell:Create(state, owner, spell, targets)
    local this =
    {
        mState = state,
        mOwner = owner,
        mSpell = spell,
        mTargets = targets,
        mIsFinished = false,
        mCharacter = state.mActorCharMap[owner],
    }

    this.mController = this.mCharacter.mController
    this.mController:Change(CSRunAnim.mName, {'prone', true})

    local storyboard =
    {
        SOP.Function(function() this:ShowSpellNotice() end),
        SOP.RunState(this.mController, CSMove.mName, {dir = 1}),
        SOP.Wait(0.5),
        SOP.RunState(this.mController, CSRunAnim.mName, {'cast', false}),
        SOP.Wait(0.12),
        SOP.NoBlock(
            SOP.RunState(this.mController, CSRunAnim.mName, {'prone'})
        ),
        SOP.Function(function() this:DoCast() end),
        SOP.Wait(1.0),
        SOP.Function(function() this:HideSpellNotice() end),
        SOP.RunState(this.mController, CSMove.mName, {dir = -1}),
        SOP.Function(function() this:DoFinish() end)
    }
    this.mStoryboard = Storyboard:Create(this.mState.mStack, storyboard)
    this.mName = string.format("%s is casting %s", spell.name, this.mOwner.mName)

    setmetatable(this, self)
    return this
end

function CECastSpell:TimePoints(queue)
    local speed = self.mOwner.mStats:Get("speed")
    local tp = queue:SpeedToTimePoints(speed)
    return tp + self.mSpell.time_points
end

function CECastSpell:ShowSpellNotice()
    self.mState:ShowNotice(self.mSpell.name)
end

function CECastSpell:HideSpellNotice()
    self.mState:HideNotice()
end

function CECastSpell:DoCast()

    local pos = self.mCharacter.mEntity:GetSelectPosition()
    local effect = AnimEntityFx:Create(pos:X(), pos:Y(),
                            gEntities.fx_use_item,
                            gEntities.fx_use_item.frames, 0.1)
    self.mState:AddEffect(effect)

    local mp = self.mOwner.mStats:Get("mp_now")
    local cost = self.mSpell.mp_cost
    local mp = math.max(mp - cost, 0) -- don't handle fizzle

    self.mOwner.mStats:Set("mp_now", mp)

    local action = self.mSpell.action
    CombatActions[action](self.mState,
                           self.mOwner,
                           self.mTargets,
                           self.mSpell)
end

function CECastSpell:DoFinish()
    self.mIsFinished = true
end

function CECastSpell:IsFinished()
    return self.mIsFinished
end

function CECastSpell:Update(dt)
end

function CECastSpell:Execute(queue)
    self.mState.mStack:Push(self.mStoryboard)

    for i = #self.mTargets, 1, -1 do
        local v = self.mTargets[i]
        local hp = v.mStats:Get("hp_now")
        local isEnemy = not self.mState:IsPartyMember(v)
        if isEnemy and hp <= 0 then
            table.remove(self.mTargets, i)
        end
    end

    if not next(self.mTargets) then
        local selector = CombatSelector[self.mSpell.target.selector]
        self.mTargets = selector(self.mState)
    end
end

