CSStandby = { mName = "cs_standby" }
CSStandby.__index = CSStandby
function CSStandby:Create(character, context)
    local this =
    {
        mCharacter = character,
        mCombatScene = context,
        mEntity = character.mEntity,
        mAnim = nil,
    }

    setmetatable(this, self)
    return this
end

function CSStandby:Enter()
    local frames = self.mCharacter:GetCombatAnim('standby')
    self.mAnim = Animation:Create(frames)
end

function CSStandby:Exit()
end

function CSStandby:Update(dt)
    self.mAnim:Update(dt)
    self.mEntity:SetFrame(self.mAnim:Frame())
end

function CSStandby:Render(renderer)
    -- The combat state will do the render for us
end