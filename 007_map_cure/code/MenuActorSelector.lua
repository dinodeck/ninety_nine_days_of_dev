MenuActorSelector =
{
    FirstPartyMember = function(targets)
        return { targets[1] }
    end,

    FirstMagicUser = function(targets)

        for k, v in ipairs(targets) do

            local summary = v.summary

            if summary.mActor.mId == "mage" then
                return { targets[k] }
            end
        end

        return {}

    end,

    MostHurtMember = function(targets)

        local target = nil
        local health = 99999

        for k, v in ipairs(targets) do
            local actor = v.summary.mActor
            local hp = v.mStats:Get("hp_now")

            if hp > 0 and hp < health then
                health = hp
                target = v
            end
        end

        return target
    end,

    MostDrainedParty = function(targets)

        local target = nil
        local mana = 99999

        for k, v in ipairs(targets) do
            local actor = v.summary.mActor
            local mp = v.mStats:Get("mp_now")
            local hp = v.mStats:Get("hp_now")

            if hp > 0 and mp < mana then
                mana = mp
                target = v
            end
        end

        return target
    end,

    DeadParty = function(targets)
    end,

    SideParty = function(targets)
        return targets -- return everyone!
    end
}