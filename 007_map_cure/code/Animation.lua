Animation = {}
Animation.__index = Animation
function Animation:Create(frames, loop, spf)

    if loop == nil then
        loop = true
    end

    local this =
    {
        mFrames = frames or { 1 },
        mIndex = 1,
        mSPF = spf or 0.12,
        mTime = 0,
        mLoop = loop
    }

    setmetatable(this, self)
    return this
end

function Animation:Update(dt)
    -- update the animation strip
    self.mTime = self.mTime + dt

    if self.mTime >= self.mSPF then

        self.mIndex = self.mIndex + 1
        self.mTime = 0

        if self.mIndex > #self.mFrames then

            if self.mLoop then
                self.mIndex = 1
            else
                self.mIndex = #self.mFrames
            end

        end
    end
end

function Animation:SetFrames(frames)
    self.mFrames = frames
    self.mIndex = math.min(self.mIndex, #self.mFrames)
end

function Animation:Frame()
    return self.mFrames[self.mIndex]
end

function Animation:IsFinished()
    return self.mLoop == false
           and self.mIndex == #self.mFrames
end