
CSEnemyDie = { mName = "cs_die" }
CSEnemyDie.__index = CSEnemyDie
function CSEnemyDie:Create(character, context)
    local this =
    {
        mCharacter = character,
        mCombatScene = context,
        mSprite = character.mEntity.mSprite,
        mTween = nil,
        mFadeColour = Vector.Create(1,1,1,1)
    }

    setmetatable(this, self)
    return this
end

function CSEnemyDie:Enter()
    self.mTween = Tween:Create(1, 0, 1)
end

function CSEnemyDie:Exit()
end

function CSEnemyDie:Update(dt)
    self.mTween:Update(dt)
    local alpha = self.mTween:Value()
    self.mFadeColour:SetW(alpha)
    self.mSprite:SetColor(self.mFadeColour)
end

function CSEnemyDie:Render(renderer)
end

function CSEnemyDie:IsFinished()
    return self.mTween:IsFinished()
end