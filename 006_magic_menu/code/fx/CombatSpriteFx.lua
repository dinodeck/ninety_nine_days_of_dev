CombatSpriteFx = {}
CombatSpriteFx.__index = CombatSpriteFx
function CombatSpriteFx:Create(x, y, sprite)

    local this =
    {
        mSprite = sprite,
        mPriority = 2,
        mX = x or 0,
        mY = y or 0,
        mColor = color or Vector.Create(1,1,1,1),
        mGravity = 700, -- pixels per second
        mAlpha = 1,
        mHoldTime = 0.175,
        mHoldCounter = 0,
        mFadeSpeed = 6,
        mPriority = 2,
    }

    this.mCurrentY = this.mY
    this.mVelocityY = 125,
    this.mSprite:SetPosition(x, y)

    setmetatable(this, self)
    return this
end

function CombatSpriteFx:Update(dt)
    self.mCurrentY = self.mCurrentY + (self.mVelocityY * dt)
    self.mVelocityY = self.mVelocityY - (self.mGravity * dt)

    if self.mCurrentY <= self.mY then
        self.mCurrentY = self.mY

        self.mHoldCounter = self.mHoldCounter + dt

        if self.mHoldCounter > self.mHoldTime then
            self.mAlpha = math.max(0, self.mAlpha - (dt * self.mFadeSpeed))
            self.mColor:SetW(self.mAlpha)
        end
    end
end

function CombatSpriteFx:Render(renderer)
    renderer:ScaleText(self.mScale, self.mScale)
    renderer:AlignText("center", "center")

    local x = self.mX
    local y = math.floor(self.mCurrentY)

    self.mSprite:SetPosition(x, y)
    self.mSprite:SetColor(self.mColor)
    renderer:DrawSprite(self.mSprite)
end

function CombatSpriteFx:IsFinished()
    -- Has it passed the fade out point?
    return self.mAlpha == 0
end