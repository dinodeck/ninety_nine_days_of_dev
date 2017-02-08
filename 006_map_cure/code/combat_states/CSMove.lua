
CSMove = { mName = "cs_move" }
CSMove.__index = CSMove
function CSMove:Create(character, context)
    local this =
    {
        mCharacter = character,
        mEntity = character.mEntity,
        mTween = nil,
        mMoveTime = 0.3,
        mMoveDistance = 32,
    }

    setmetatable(this, self)
    return this
end

function CSMove:Enter(params)
    self.mMoveTime = params.time or self.mMoveTime
    self.mMoveDistance = params.distance or self.mMoveDistance

    local backforth = params.dir


    local anims = self.mCharacter.mAnims

    if anims == nil then
        anims =
        {
            advance = { self.mEntity.mStartFrame },
            retreat = { self.mEntity.mStartFrame },
        }
    end

    local frames = anims.advance
    local dir = -1
    if self.mCharacter.mFacing == "right" then
        frames = anims.retreat
        dir = 1
    end
    dir = dir * backforth

    self.mAnim = Animation:Create(frames)

    -- Store current position
    local pixelPos = self.mEntity.mSprite:GetPosition()
    self.mPixelX = pixelPos:X()
    self.mPixelY = pixelPos:Y()

    self.mTween = Tween:Create(0, dir, self.mMoveTime)

end

function CSMove:Exit()
end

function CSMove:Update(dt)
    self.mAnim:Update(dt)
    self.mEntity:SetFrame(self.mAnim:Frame())

    self.mTween:Update(dt)
    local value = self.mTween:Value()
    local x = self.mPixelX + (value * self.mMoveDistance)
    local y = self.mPixelY
    self.mEntity.mX = math.floor(x)
    self.mEntity.mY = math.floor(y)
    self.mEntity.mSprite:SetPosition(self.mEntity.mX , self.mEntity.mY)
end

function CSMove:Render(renderer)
end

function CSMove:IsFinished()
    return self.mTween:IsFinished()
end