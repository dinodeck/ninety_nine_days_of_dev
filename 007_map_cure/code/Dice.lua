Dice = {}
Dice.__index = Dice

function Dice:Create(diceStr)
    local this =
    {
        mDice = {}
    }
    setmetatable(this, self)
    this:Parse(diceStr)
    return this
end

function Dice:Parse(diceStr)
    local len = string.len(diceStr)
    local index = 1
    local allDice = {}

    while index <= len do
        local die
        die, index = self:ParseDie(diceStr, index)
        table.insert(self.mDice, die)
        index = index + 1 -- eat ' '
    end
end

function Dice:ParseDie(diceStr, i)
    local rolls
    rolls, i = self:ParseNumber(diceStr, i)

    i = i + 1 -- Move past the \'D\'

    local sides
    sides, i = self:ParseNumber(diceStr, i)

    if i == string.len(diceStr) or
        string.sub(diceStr, i, i) == ' ' then
        return { rolls, sides, 0 }, i
    end

    if string.sub(diceStr, i, i) == '+' then
        i = i + 1 -- move past the '+'
        local plus
        plus, i = self:ParseNumber(diceStr, i)
        return { rolls, sides, plus }, i
    end

end

function Dice:ParseNumber(str, index)

    local isNum =
    {
        ['0'] = true,
        ['1'] = true,
        ['2'] = true,
        ['3'] = true,
        ['4'] = true,
        ['5'] = true,
        ['6'] = true,
        ['7'] = true,
        ['8'] = true,
        ['9'] = true
    }

    local len = string.len(str)
    local subStr = {}

    for i = index, len do

        local char = string.sub(str, i, i)

        if not isNum[char] then
            return tonumber(table.concat(subStr)), i
        end

        table.insert(subStr, char)

    end

    return tonumber(table.concat(subStr)), len

end

-- Notice this uses a . not a : meaning the function can be called
-- without having a class instance. e.g Dice.RollDie(1, 6) is ok
function Dice.RollDie(rolls, faces, modifier)
    local total = 0

    for i = 1, rolls do
        total = total + math.random(1, faces)
    end
    return total + (modifier or 0)
end

function Dice:Roll()
    local total = 0

    for _, die in ipairs(self.mDice) do
        total = total + Dice.RollDie(unpack(die))
    end

    return total
end