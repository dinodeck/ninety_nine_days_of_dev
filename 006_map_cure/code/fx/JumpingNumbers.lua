JumpingNumbers = {}
JumpingNumbers.__index = JumpingNumbers
function JumpingNumbers:Create(x, y, number, color)
    local this =
    {
        mX = x or 0,
        mY = y or 0,
        mGravity = 700, -- pixels per second
        mFadeDistance = 33, -- pixels
        mNumber = number or 0, -- to display
        mColor = color or Vector.Create(1,1,1,1),
        mPriority = 1,
        mHoldTime = 0.1,
        mHoldCount = 0,

        State =
        {
            rise = "rise",
            hold = "hold",
            fall = "fall"
        }
    }
    this.mState = this.State.rise
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

    if self.mState == self.State.hold then

        if self.mHoldCount >= self.mHoldTime then
            self.mState = self.State.fall
        end

        self.mHoldCount = self.mHoldCount + dt
        return
    end


    self.mCurrentY = self.mCurrentY + (self.mVelocityY * dt)
    self.mVelocityY = self.mVelocityY - (self.mGravity * dt)

    if self.mState == self.State.rise and self.mVelocityY <= 0 then
        self.mHoldCount = 0
        self.mState = self.State.hold
        return
    end

    if self.mCurrentY <= self.mY then
        local fade01 = math.min(1, (self.mY - self.mCurrentY) / self.mFadeDistance)
        self.mColor:SetW(1 - fade01)
    end
end

function JumpingNumbers:Render(renderer)

    local x = self.mX
    local y = math.floor(self.mCurrentY)
    local n = tostring(self.mNumber)


    local font = gGame.Font.damage
    font:AlignText("center", "center")
    font:DrawText2d(renderer, x + 1, y - 1, n, Vector.Create(0,0,0, self.mColor:W()))
    font:DrawText2d(renderer, x, y, n, self.mColor)

end