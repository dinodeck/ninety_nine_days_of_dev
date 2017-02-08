
FollowPathState = { mName = "follow_path" }
FollowPathState.__index = FollowPathState
function FollowPathState:Create(character, map)
    local this =
    {
        mCharacter = character,
        mMap = map,
        mEntity = character.mEntity,
        mController = character.mController,
    }

    setmetatable(this, self)
    return this
end

function FollowPathState:Enter()

    local char = self.mCharacter
    local controller = self.mController

    if char.mPathIndex == nil
        or char.mPath == nil
        or char.mPathIndex > #char.mPath then
        char.mDefaultState = char.mPrevDefaultState or char.mDefaultState
        return controller:Change(char.mDefaultState)
    end

    local direction = char.mPath[char.mPathIndex]
    if direction == "left" then
       return controller:Change("move", {x = -1, y = 0})
    elseif direction == "right" then
        return controller:Change("move", {x = 1, y = 0})
    elseif direction == "up" then
        return controller:Change("move", {x = 0, y = -1})
    elseif direction == "down" then
        return controller:Change("move", {x = 0, y = 1})
    end

    -- If we get here, there's an incorrect direction in the path.
    assert(false)
end

function FollowPathState:Exit()
    self.mCharacter.mPathIndex = self.mCharacter.mPathIndex + 1
end

function FollowPathState:Update(dt)
end

function FollowPathState:Render(renderer)
end