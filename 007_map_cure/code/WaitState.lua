WaitState = {mName = "wait"}
WaitState.__index = WaitState
function WaitState:Create(character, map)
    local this =
    {
        mCharacter = character,
        mMap = map,
        mEntity = character.mEntity,
        mController = character.mController,

        mFrameResetSpeed = 0.05,
        mFrameCount = 0
    }

    setmetatable(this, self)
    return this
end

function WaitState:Enter(data)
    self.mFrameCount = 0
end

function WaitState:Render(renderer) end
function WaitState:Exit() end

function WaitState:Update(dt)


    -- If we're in the wait state for a few frames, reset the frame to
    -- the starting frame.
    if self.mFrameCount ~= -1 then
        self.mFrameCount = self.mFrameCount + dt
        if self.mFrameCount >= self.mFrameResetSpeed then
            self.mFrameCount = -1
            self.mEntity:SetFrame(self.mEntity.mStartFrame)
            self.mCharacter.mFacing = "down"
        end
    end

    if Keyboard.Held(KEY_LEFT) then
        self.mController:Change("move", {x = -1, y = 0})
    elseif Keyboard.Held(KEY_RIGHT) then
        self.mController:Change("move", {x = 1, y = 0})
    elseif Keyboard.Held(KEY_UP) then
        self.mController:Change("move", {x = 0, y = -1})
    elseif Keyboard.Held(KEY_DOWN) then
        self.mController:Change("move", {x = 0, y = 1})
    end
end


