local function AddAnimEffect(state, entity, def, spf)
    local x = entity.mX
    local y = entity.mY + (entity.mHeight * 0.75)

    local effect = AnimEntityFx:Create(x, y, def, def.frames, spf)
    state:AddEffect(effect)
end

local function AddTextNumberEffect(state, entity, num, color)
    local x = entity.mX
    local y = entity.mY

    --local text = string.format("+%d", num)

    local textEffect = JumpingNumbers:Create(x, y, num, color)
    --CombatTextFx:Create(x, y, text, color)
    state:AddEffect(textEffect)
end

local function StatsCharEntity(state, actor)
    local stats = actor.mStats
    local character = state.mActorCharMap[actor]
    local entity = character.mEntity
    return stats, character, entity
end

local function StatsForCombatState(targets)
    local statList = {}
    for k, v in ipairs(targets) do
        table.insert(statList, v.mStats)
    end
    return statList
end

local function StatsForMenuState(targets)
    local statList = {}
    for k, v in pairs(targets) do
        local stats = v.summary.mActor.mStats
        table.insert(statList, stats)
    end
    return statList
end

CombatActions =
{
    ["hp_restore"] =
    function(state, owner, targets, def, stateId)

        local extractStatFunction = StatsForCombatState
        if stateId == "item" then
            extractStatFunction = StatsForMenuState
        end

        local statList = extractStatFunction(targets)
        local restoreAmount = def.use.restore or 250
        for k, v in ipairs(statList) do
            local maxHP = v:Get("hp_max")
            local nowHP = v:Get("hp_now")
            if nowHP > 0 then
                nowHP = math.min(maxHP, nowHP + restoreAmount)
                v:Set("hp_now", nowHP)
            end
        end

        if stateId == "item" then
            return
        end

        --
        -- Combat Effects
        --

        local animEffect = gEntities.fx_restore_hp
        local restoreColor = Vector.Create(0, 1, 0, 1)

        for k, v in ipairs(targets) do

            local stats, character, entity = StatsCharEntity(state, v)

            if stats:Get("hp_now") > 0 then
                AddTextNumberEffect(state, entity, restoreAmount, restoreColor)
            end

            AddAnimEffect(state, entity, animEffect, 0.1)
        end

    end,

    ["hp_restore_spell"] =
    function(state, owner, targets, def, stateId)

        local extractStatFunction = StatsForCombatState
        if stateId == "magic_menu" then
            extractStatFunction = StatsForMenuState
        end

        local restoreAmount = def.base_heal or 100
        restoreAmount = restoreAmount * owner.mLevel
        local statList = extractStatFunction(targets)

        print(restoreAmount, #statList, next(statList))

        for k, v in ipairs(statList) do
            local maxHP = v:Get("hp_max")
            local nowHP = v:Get("hp_now")
            if nowHP > 0 then
                nowHP = math.min(maxHP, nowHP + restoreAmount)
                v:Set("hp_now", nowHP)
            end
        end

        if stateId == "magic_menu" then
            return
        end

        local animEffect = gEntities.fx_restore_hp
        local restoreColor = Vector.Create(0, 1, 0, 1)

        for k, v in ipairs(targets) do

            local stats, character, entity = StatsCharEntity(state, v)

            local nowHP = stats:Get("hp_now")

            if nowHP > 0 then
                AddTextNumberEffect(state, entity, restoreAmount, restoreColor)
            end

            AddAnimEffect(state, entity, animEffect, 0.1)
        end
    end,

    ['mp_restore'] =
    function(state, owner, targets, def, stateId)

        local restoreAmount = def.use.restore or 50

        local extractStatFunction = StatsForCombatState
        if stateId == "item" then
            extractStatFunction = StatsForMenuState
        end

        local statList = extractStatFunction(targets)
        for k, v in ipairs(statList) do

            local maxMP = v:Get("mp_max")
            local nowMP = v:Get("mp_now")
            local nowHP = v:Get("hp_now")

            if nowHP > 0 then
                nowMP = math.min(maxMP, nowMP + restoreAmount)
                v:Set("mp_now", nowMP)
            end
        end

        if stateId == "item" then
            return
        end

        local animEffect = gEntities.fx_restore_mp
        local restoreColor = Vector.Create(130/255, 200/255, 237/255, 1)

        for k, v in ipairs(targets) do

            local stats, character, entity = StatsCharEntity(state, v)

            if stats:Get("hp_now") > 0 then
                AddTextNumberEffect(state, entity, restoreAmount, restoreColor)
            end

            AddAnimEffect(state, entity, animEffect, 0.1)
        end
    end,

    ['element_spell'] =
    function(state, owner, targets, def, stateId)

        local restoreAmount = def.base_heal or 100
        restoreAmount = restoreAmount * owner.mLevel
        local animEffect = gEntities.fx_restore_hp
        local restoreColor = Vector.Create(0, 1, 0, 1)

        for k, v in ipairs(targets) do

            local stats, character, entity = StatsCharEntity(state, v)

            local maxHP = stats:Get("hp_max")
            local nowHP = stats:Get("hp_now")

            if nowHP > 0 then
                AddTextNumberEffect(state, entity, restoreAmount, restoreColor)
                nowHP = math.min(maxHP, nowHP + restoreAmount)
                stats:Set("hp_now", nowHP)
            end

            AddAnimEffect(state, entity, animEffect, 0.1)

        end
    end,

    ['revive'] =
    function(state, owner, targets, def, stateId)

        local restoreAmount = def.use.restore or 100

        local function DoCombatFX()
            local animEffect = gEntities.fx_revive
            local restoreColor = Vector.Create(0, 1, 0, 1)

            for k, v in ipairs(targets) do
                local stats, character, entity = StatsCharEntity(state, v)
                local nowHP = stats:Get("hp_now")

                if nowHP == 0 then
                    -- the character will get a CETurn event automatically
                    -- assigned next update
                    character.mController:Change(CSStandby.mName)
                    AddTextNumberEffect(state, entity, restoreAmount, restoreColor)
                end

                AddAnimEffect(state, entity, animEffect, 0.1)
            end
        end

        -- Need to run the FX first as it
        -- tests who's dead
        if not (stateId == "item") then
            DoCombatFX()
        end

        local extractStatFunction = StatsForCombatState
        if stateId == "item" then
            extractStatFunction = StatsForMenuState
        end

        local statList = extractStatFunction(targets)
        for k, v in ipairs(statList) do

            local maxHP = v:Get("hp_max")
            local nowHP = v:Get("hp_now")

            if nowHP == 0 then
                nowHP = math.min(maxHP, nowHP + restoreAmount)
                v:Set("hp_now", nowHP)
            end
        end

    end,

    ['element_spell'] =
    function(state, owner, targets, def, stateId)

        for k, v in ipairs(targets) do
            local _, _, entity = StatsCharEntity(state, v)

            local damage, hitResult = Formula.MagicAttack(state, owner, v, def)

            if hitResult == HitResult.Hit then
                state:ApplyDamage(v, damage)
            end

            if def.element == "fire" then
                AddAnimEffect(state, entity, gEntities.fx_fire, 0.06)
            elseif def.element == "electric" then
                AddAnimEffect(state, entity, gEntities.fx_electric, 0.12)
            elseif def.element == "ice" then
                AddAnimEffect(state, entity, gEntities.fx_ice_1, 0.1)
                local x = entity.mX
                local y = entity.mY

                local spk = gEntities.fx_ice_spark
                local effect = AnimEntityFx:Create(x, y, spk, spk.frames, 0.12)
                state:AddEffect(effect)

                local x2 = x + entity.mWidth * 0.8
                local ice2 = gEntities.fx_ice_2
                effect = AnimEntityFx:Create(x2, y, ice2, ice2.frames, 0.1)
                state:AddEffect(effect)

                local x3 = x - entity.mWidth * 0.8
                local y3 = y - entity.mHeight * 0.6
                local ice3 = gEntities.fx_ice_3
                effect = AnimEntityFx:Create(x3, y3, ice3, ice3.frames, 0.1)
                state:AddEffect(effect)
            end
        end
    end
}

