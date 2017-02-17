
PlanStrollState = { mName = "plan_stroll" }
PlanStrollState.__index = PlanStrollState
function PlanStrollState:Create(character, map)
    local this =
    {
        mCharacter = character,
        mMap = map,
        mEntity = character.mEntity,
        mController = character.mController,

        mFrameResetSpeed = 0.05,
        mFrameCount = 0,

        mCountDown = math.random(0, 3)
    }

    setmetatable(this, self)
    return this
end

function PlanStrollState:Enter() end
function PlanStrollState:Exit() end

function PlanStrollState:Update(dt)

    self.mCountDown = self.mCountDown - dt
    if self.mCountDown <= 0 then
        -- Choose a random direction and try to move that way.
        local choice = math.random(4)
        if choice == 1 then
            self.mController:Change("move", {x = -1, y = 0})
        elseif choice == 2 then
            self.mController:Change("move", {x = 1, y = 0})
        elseif choice == 3 then
            self.mController:Change("move", {x = 0, y = -1})
        elseif choice == 4 then
            self.mController:Change("move", {x = 0, y = 1})
        end
    end

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

end

function PlanStrollState:Render(renderer)
end