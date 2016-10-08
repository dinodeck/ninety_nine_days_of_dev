OddmentTable = {}
OddmentTable.__index = OddmentTable
function OddmentTable:Create(items)
    local this =
    {
        mItems = items or {}
    }

    setmetatable(this, self)

    this.mOddment = this:CalcOddment()

    return this
end

function OddmentTable:CalcOddment()
    local total = 0
    for _, v in ipairs(self.mItems) do
        total = total + v.oddment
    end
    return total
end

function OddmentTable:Pick()

    local n = math.random(self.mOddment) -- 1 - oddment
    local total = 0
    for _, v in ipairs(self.mItems) do
        total = total + v.oddment

        if total >= n then
            return v.item
        end
    end

    -- Otherwise return the last item
    local last = self.mItems[#self.mItems]
    last = last or {}
    return last.item
end
