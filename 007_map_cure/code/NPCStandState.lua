
NPCStandState = { mName = "npc_stand"}
NPCStandState.__index = NPCStandState
function NPCStandState:Create(character, map)
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

function NPCStandState:Enter()
end

function NPCStandState:Exit()
end

function NPCStandState:Update(dt)
end

function NPCStandState:Render(renderer)
end