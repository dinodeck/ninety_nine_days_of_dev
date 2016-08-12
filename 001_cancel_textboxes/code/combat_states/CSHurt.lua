
CSHurt = { mName = "cs_hurt" }
CSHurt.__index = CSHurt
function CSHurt:Create(character, context)
    local this =
    {
        mCharacter = character,
        mCombatScene = context,
        mEntity = character.mEntity,
        mPrevState = nil,
    }

    setmetatable(this, self)
    return this
end

function CSHurt:Enter(state)
    self.mPrevState = state
    local frames = self.mCharacter:GetCombatAnim('hurt')
    self.mAnim = Animation:Create(frames, false, 0.2)
    self.mEntity:SetFrame(self.mAnim:Frame())
end

function CSHurt:Exit()
end

function CSHurt:Update(dt)
    if self.mAnim:IsFinished() then
        self.mCharacter.mController.mCurrent = self.mPrevState
        return
    end
    self.mAnim:Update(dt)
    self.mEntity:SetFrame(self.mAnim:Frame())
end

function CSHurt:Render(renderer)
end