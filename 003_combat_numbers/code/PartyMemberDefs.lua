gPartyMemberDefs =
{
    hero =
    {
        id = "hero",
        stats =
        {
            ["hp_now"] = 36,
            ["hp_max"] = 36,
            ["mp_now"] = 5,
            ["mp_max"] = 5,
            ["strength"] = 10,
            ["speed"] = 16,
            ["intelligence"] = 10,
        },
        actionGrowth =
        {
            [5] =
            {
                ['special'] = {'slash'},
            }
        },
        statGrowth =
        {
            ["hp_max"] = Dice:Create("2d25+25"),
            ["mp_max"] = Dice:Create("1d5+2"),
            ["strength"] = gStatGrowth.fast,
            ["speed"] = gStatGrowth.fast,
            ["intelligence"] = gStatGrowth.med,
        },
        portrait = "hero_portrait.png",
        name = "Seven",
        actions = { "attack", "item", "flee" },
        level = 0,
    },
    thief =
    {
        id = "thief",
        stats =
        {
            ["hp_now"] = 34,
            ["hp_max"] = 34,
            ["mp_now"] = 5,
            ["mp_max"] = 5,
            ["strength"] = 10,
            ["speed"] = 15,
            ["intelligence"] = 10,
        },
        statGrowth =
        {
            ["hp_max"] = Dice:Create("2d25+15"),
            ["mp_max"] = Dice:Create("2d10+5"),
            ["strength"] = gStatGrowth.med,
            ["speed"] = gStatGrowth.fast,
            ["intelligence"] = gStatGrowth.med,
        },
        actionGrowth =
        {
            [2] =
            {
                ['special'] = { 'steal' }
            }
        },
        portrait = "thief_portrait.png",
        name = "Jude",
        actions = { "attack", "item", "flee" },
        level = 0,
    },
    mage =
    {
        id = "mage",
        stats =
        {
            ["hp_now"] = 32,
            ["hp_max"] = 32,
            ["mp_now"] = 10,
            ["mp_max"] = 10,
            ["strength"] = 8,
            ["speed"] = 10,
            ["intelligence"] = 20,
        },
        statGrowth =
        {
            ["hp_max"] = Dice:Create("2d25+18"),
            ["mp_max"] = Dice:Create("1d5+2"),
            ["strength"] = gStatGrowth.med,
            ["speed"] = gStatGrowth.med,
            ["intelligence"] = gStatGrowth.fast,
        },
        actionGrowth =
        {
            [1] =
            {
                ['magic'] = { 'bolt' },
            },
            [2] =
            {
                ['magic'] = {'fire', 'ice'}
            },
            [4] =
            {
                ['magic'] = { 'burn' }
            }
        },
        portrait = "mage_portrait.png",
        name = "Ermis",
        actions = { "attack", "item", "flee"},
        magic = { },
        level = 0,
    },
}