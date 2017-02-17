
Trigger = {}
Trigger.__index = Trigger
function Trigger:Create(def)

    local EmptyFunc = function() end

    local this =
    {
        OnEnter = def.OnEnter or EmptyFunc,
        OnExit = def.OnExit or EmptyFunc,
        OnUse = def.OnUse or EmptyFunc,
    }

    setmetatable(this, self)
    return this
end