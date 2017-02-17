
CSEnemyHurt = { mName = "cs_hurt" }
CSEnemyHurt.__index = CSEnemyHurt
function CSEnemyHurt:Create(character, context)
    local this =
    {
        mCharacter = character,
        mEntity = character.mEntity,
        mCombatScene = context,
        mSprite = character.mEntity.mSprite,
        mKnockback = 3, -- pixels
        mTween = nil,
        mFlashColor = Vector.Create(1,1,0,1),
        mTime = 0.2,
    }

    setmetatable(this, self)
    return this
end

function CSEnemyHurt:Enter(state)

    self.mPrevState = state

    local pixelPos = self.mEntity.mSprite:GetPosition()
    self.mOriginalX = pixelPos:X()
    self.mOriginalY = pixelPos:Y()

    -- push the entity back a few pixels
    self.mEntity.mSprite:SetPosition(
        self.mOriginalX - self.mKnockback,
        self.mOriginalY)

    -- Set the sprite a little yellow
    self.mFlashColor = Vector.Create(1,1,0,1)
    self.mEntity.mSprite:SetColor(self.mFlashColor)

    -- Create a tween to run the effects
    self.mTween = Tween:Create(0, 1, self.mTime)

end

function CSEnemyHurt:Exit()
    -- Back to white
    self.mEntity.mSprite:SetColor(Vector.Create(1,1,1,1))
end

function CSEnemyHurt:Update(dt)

    if self.mTween:IsFinished() then
        self.mCharacter.mController.mCurrent = self.mPrevState
        return
    end

    self.mTween:Update(dt)

    local value = self.mTween:Value()

    self.mEntity.mSprite:SetPosition(
        self.mOriginalX + self.mKnockback * value,
        self.mOriginalY)

    self.mFlashColor:SetZ(value)
    self.mEntity.mSprite:SetColor(self.mFlashColor)

end

function CSEnemyHurt:Render(renderer)
end
