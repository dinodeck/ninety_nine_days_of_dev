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
    end,

    LowestManaMember = function(targets)
    end,

    FirstDeadMember = function(targets)
    end,
}