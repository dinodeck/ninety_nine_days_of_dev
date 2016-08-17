CEUseItem = {}
CEUseItem.__index = CEUseItem
function CEUseItem:Create(state, owner, item, targets)

    print("CEItemUse", state, owner, item, targets)

    local this =
    {
        mState = state,
        mOwner = owner,
        mItemDef = item,
        mTargets = targets,
        mIsFinished = false,
        mCharacter = state.mActorCharMap[owner],
    }

    -- Remove item here, otherwise 2 people could try and use the 1 potion
    gWorld:RemoveItem(item.id)


    this.mController = this.mCharacter.mController
    this.mController:Change(CSRunAnim.mName, {'prone'})

    local storyboard =
    {
        SOP.Function(function() this:ShowItemNotice() end),
        SOP.RunState(this.mController, CSMove.mName, {dir = 1}),
        SOP.RunState(this.mController, CSRunAnim.mName, {'use', false}),
        SOP.Function(function() this:DoUseItem() end),
        SOP.Wait(1.3), -- time to read the notice
        SOP.RunState(this.mController, CSMove.mName, {dir = -1}),
        SOP.Function(function() this:DoFinish() end)
    }
    this.mStoryboard = Storyboard:Create(this.mState.mStack, storyboard)

    this.mName = string.format("%s using %s", owner.mName, item.name)

    setmetatable(this, self)
    return this
end

function CEUseItem:TimePoints(queue)
    local speed = self.mOwner.mStats:Get("speed")
    return queue:SpeedToTimePoints(speed)
end

function CEUseItem:ShowItemNotice()
    local str = string.format("Item: %s", self.mItemDef.name)
    self.mState:ShowNotice(str)
end


function CEUseItem:DoUseItem()
    self.mState:HideNotice()
    local pos = self.mCharacter.mEntity:GetSelectPosition()
    local effect = AnimEntityFx:Create(pos:X(), pos:Y(),
                            gEntities.fx_use_item,
                            gEntities.fx_use_item.frames, 0.1)
    self.mState:AddEffect(effect)

    local action = self.mItemDef.use.action
    CombatActions[action](self.mState,
                           self.mOwner,
                           self.mTargets,
                           self.mItemDef)
end

function CEUseItem:DoFinish()
    self.mIsFinished = true
end

function CEUseItem:Execute(queue)
    self.mState.mStack:Push(self.mStoryboard)
end

function CEUseItem:IsFinished()
    return self.mIsFinished
end

function CEUseItem:Update()
end


