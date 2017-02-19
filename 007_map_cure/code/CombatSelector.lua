
-- Give the target state returns a list of actors
-- that are targets.

local function WeakestActor(list, onlyCheckHurt)
        local target = nil
        local health = 99999

        for k, v in ipairs(list) do
            local hp = v.mStats:Get("hp_now")
            local isHurt = hp < v.mStats:Get("hp_max")
            local skip = false
            if onlyCheckHurt and not isHurt then
                skip = true
            end

            if hp < health and not skip then
                health = hp
                target = v
            end
        end

        return { target or list[1] }
end

local function MostDrainedActor(list, onlyCheckDrained)
        local target = nil
        local magic = 99999

        for k, v in ipairs(list) do
            local mp = v.mStats:Get("mp_now")
            local isHurt = mp < v.mStats:Get("mp_max")
            local skip = false
            if onlyCheckDrained and not isHurt then
                skip = true
            end

            if mp < magic and not skip then
                magic = mp
                target = v
            end
        end

        return { target or list[1] }
end

CombatSelector =
{

    WeakestEnemy = function(state)
        return WeakestActor(state.mActors["enemy"], false)
    end,

    WeakestParty = function(state)
        return WeakestActor(state.mActors["party"], false)
    end,

    MostHurtEnemy = function(state)
        return WeakestActor(state.mActors["party"], true)
    end,

    MostHurtParty = function(state)
        print("Calling most hurt party")
        return WeakestActor(state.mActors["party"], true)
    end,

    MostDrainedParty = function(state)
        return MostDrainedActor(state.mActors["party"], true)
    end,

    DeadParty = function(state)
        local list = state.mActors["party"]

        for k, v in ipairs(list) do
            local hp = v.mStats:Get("hp_now")
            if hp == 0 then
                return { v }
            end
        end
        -- Just return the first
        return { list[1] }
    end,

    SideEnemy = function(state)
        return state.mActors["enemy"]
    end,

    SideParty = function(state)
        return state.mActors["party"]
    end,

    SelectAll = function(state)
        local targets = {}

        for k, v in ipairs(state.mActors["enemy"]) do
            table.insert(targets, v)
        end

        for k, v in ipairs(state.mActors["party"]) do
            table.insert(targets, v)
        end

        return targets

    end,

    RandomAlivePlayer = function(state)

        local aliveList = {}
        for k, v in ipairs(state.mActors["party"]) do
            if v.mStats:Get("hp_now") > 0 then
                table.insert(aliveList, v)
            end
        end

        local target = aliveList[math.random(#aliveList)]
        return { target }
    end,
}