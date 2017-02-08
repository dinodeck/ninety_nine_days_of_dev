function NextLevel(level)
    local exponent = 1.5
    local baseXP = 1000
    return math.floor(baseXP * (level ^ exponent))
end