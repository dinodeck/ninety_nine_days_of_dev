CSRunAnim = { mName = "cs_run_anim" }
CSRunAnim.__index = CSRunAnim
function CSRunAnim:Create(character, context)
    local this =
    {
        mCharacter = character,
        mCombatScene = context,
        mEntity = character.mEntity,
    }

    setmetatable(this, self)
    return this
end

function CSRunAnim:Enter(params)
    local anim, loop, spf = unpack(params)
    self.mAnimId = anim
    local frames = self.mCharacter:GetCombatAnim(anim)
    self.mAnim = Animation:Create(frames, loop, spf)
end

function CSRunAnim:Exit()
end

function CSRunAnim:Update(dt)
    self.mAnim:Update(dt)
    self.mEntity:SetFrame(self.mAnim:Frame())
end

function CSRunAnim:Render(renderer)
end

function CSRunAnim:IsFinished()
    return self.mAnim:IsFinished()
end