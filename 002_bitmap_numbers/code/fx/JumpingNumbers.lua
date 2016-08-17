JumpingNumbers = {}
JumpingNumbers.__index = JumpingNumbers
function JumpingNumbers:Create(x, y, number, color)
    local this =
    {
        mX = x or 0,
        mY = y or 0,
        mGravity = 700, -- pixels per second
        mFadeDistance = 33, -- pixels
        mScale = 1.3,
        mNumber = number or 0, -- to display
        mColor = color or Vector.Create(1,1,1,1),
        mPriority = 1,
    }
    this.mCurrentY = this.mY
    this.mVelocityY = 224,

    setmetatable(this, self)
    return this
end

function JumpingNumbers:IsFinished()
    -- Has it passed the fade out point?
    return self.mCurrentY <= (self.mY - self.mFadeDistance)
end

function JumpingNumbers:Update(dt)

    self.mCurrentY = self.mCurrentY + (self.mVelocityY * dt)
    self.mVelocityY = self.mVelocityY - (self.mGravity * dt)

    if self.mCurrentY <= self.mY then
        local fade01 = math.min(1, (self.mY - self.mCurrentY) / self.mFadeDistance)
        self.mColor:SetW(1 - fade01)
    end
end

function JumpingNumbers:Render(renderer)

    renderer:ScaleText(self.mScale, self.mScale)
    renderer:AlignText("center", "center")

    local x = self.mX
    local y = math.floor(self.mCurrentY)
    local n = tostring(self.mNumber)
    renderer:DrawText2d(x + 2, y - 2, n, Vector.Create(0,0,0, self.mColor:W()))
    renderer:DrawText2d(x, y, n, self.mColor)

end