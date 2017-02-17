Stats = {}
Stats.__index = Stats
function Stats:Create(stats)
    local this =
    {
        mBase = {},
        mModifiers = {}
    }

    -- Shallow copy
    for k, v in pairs(stats) do
        this.mBase[k] = v
    end

    setmetatable(this, self)
    return this
end

function Stats:GetBase(id)
    return self.mBase[id]
end

function Stats:Set(id, value)
    self.mBase[id] = value
end

--
-- id = used to uniquely identify the modifier
-- modifier =
-- {
--     add = { table of stat increments }
--     mult = { table of stat multipliers }
-- }
function Stats:AddModifier(id, modifier)
    self.mModifiers[id] =
    {
        add     = modifier.add or {},
        mult    = modifier.mult or {}
    }
end

function Stats:RemoveModifier(id)
    self.mModifiers[id] = nil
end

function Stats:Get(id)
    local total = self.mBase[id] or 0
    local multiplier = 0

    for k, v in pairs(self.mModifiers) do
        total = total + (v.add[id] or 0)
        multiplier = multiplier + (v.mult[id] or 0)
    end

    return total + (total * multiplier)
end
