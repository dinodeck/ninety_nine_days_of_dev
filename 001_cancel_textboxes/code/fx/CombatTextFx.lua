-- Used to display "miss", "critical", "posioned", etc
CombatTextFx = {}
CombatTextFx.__index = CombatTextFx
function CombatTextFx:Create(x, y, text, color)
    local this =
    {
        mX = x or 0,
        mY = y or 0,
        mText = text or "", -- to display
        mColor = color or Vector.Create(1,1,1,1),
        mGravity = 700, -- pixels per second
        mScale = 1.1,
        mAlpha = 1,
        mHoldTime = 0.175,
        mHoldCounter = 0,
        mFadeSpeed = 6,

        mPriority = 2,
    }
    this.mCurrentY = this.mY
    this.mVelocityY = 125,

    setmetatable(this, self)
    return this
end

function CombatTextFx:IsFinished()
    -- Has it passed the fade out point?
    return self.mAlpha == 0
end

function CombatTextFx:Update(dt)

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

function CombatTextFx:Render(renderer)

    renderer:ScaleText(self.mScale, self.mScale)
    renderer:AlignText("center", "center")

    local x = self.mX
    local y = math.floor(self.mCurrentY)
    local shadowColor = Vector.Create(0,0,0, self.mColor:W())
    renderer:DrawText2d(x + 2, y - 2, self.mText, shadowColor)
    renderer:DrawText2d(x, y, self.mText, self.mColor)

end