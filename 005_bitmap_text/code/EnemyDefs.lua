gEnemyDefs =
{
    goblin =
    {
        id = "goblin",
        stats =
        {
            ["hp_now"] = 60,
            ["hp_max"] = 60,
            ["mp_now"] = 0,
            ["mp_max"] = 0,
            ["strength"] = 15,
            ["speed"] = 6,
            ["intelligence"] = 2,
            ["counter"] = 0,
        },
        name = "Arena Goblin",
        actions = { "attack" },
        steal_item =  10,
        drop =
        {
            xp = 150,
            gold = {5, 15},
            always = nil,
            chance =
            {
                { oddment = 1, item = { id = -1 } },
                { oddment = 3, item = { id = 10 } }
            }
        }
    },
    goblin_field =
    {
        id = "goblin_field",
        stats =
        {
            ["hp_now"] = 40,
            ["hp_max"] = 40,
            ["mp_now"] = 0,
            ["mp_max"] = 0,
            ["strength"] = 12,
            ["speed"] = 6,
            ["intelligence"] = 8,
            ["counter"] = 0,
        },
        name = "Field Goblin",
        actions = { "attack" },
        steal_item =  10,
        drop =
        {
            xp = 50,
            gold = {5, 15},
            always = nil,
            chance =
            {
                { oddment = 1, item = { id = -1 } },
                { oddment = 3, item = { id = 10 } }
            }
        }
    },
    goblin_forest =
    {
        id = "goblin_forest",
        stats =
        {
            ["hp_now"] = 60,
            ["hp_max"] = 60,
            ["mp_now"] = 0,
            ["mp_max"] = 0,
            ["strength"] = 20,
            ["speed"] = 5,
            ["intelligence"] = 9,
            ["counter"] = 0,
        },
        name = "Forest Goblin",
        actions = { "attack" },
        steal_item =  10,
        drop =
        {
            xp = 75,
            gold = {15, 20},
            always = nil,
            chance =
            {
                { oddment = 1, item = { id = -1 } },
                { oddment = 1, item = { id = 10 } }
            }
        }
    },
    cave_drake =
    {
        id = "cave_drake",
        stats =
        {
            ["hp_now"] = 250,
            ["hp_max"] = 250,
            ["mp_now"] = 0,
            ["mp_max"] = 0,
            ["strength"] = 30,
            ["speed"] = 13,
            ["intelligence"] = 20,
            ["counter"] = 0,
        },
        name = "Cave Drake",
        actions = { "attack" },
        steal_item =  10,
        drop =
        {
            xp = 750,
            gold = {15, 20},
            always = nil,
            chance =
            {
                { oddment = 1, item = { id = -1 } },
                { oddment = 1, item = { id = 10 } }
            }
        }
    },
    demon_major =
    {
        id = "demon_major",
        stats =
        {
            ["hp_now"] = 300,
            ["hp_max"] = 300,
            ["mp_now"] = 0,
            ["mp_max"] = 0,
            ["strength"] = 30,
            ["speed"] = 13,
            ["intelligence"] = 20,
            ["counter"] = 0.05,
        },
        name = "Demon Major",
        actions = { "attack" },
        steal_item =  10,
        drop =
        {
            xp = 750,
            gold = {15, 20},
            always = nil,
            chance =
            {
                { oddment = 1, item = { id = -1 } },
                { oddment = 1, item = { id = 10 } }
            }
        }
    },
    cave_bat =
    {
        id = "cave_bat",
        stats =
        {
            ["hp_now"] = 40,
            ["hp_max"] = 40,
            ["strength"] = 9,
            ["speed"] = 16,
            ["intelligence"] = 3,
        },
        name = "Bat",
        actions = { "attack" },
        drop = { xp = 50 }
    },
    cave_shade =
    {
        id = "cave_shade",
        stats =
        {
            ["hp_now"] = 110,
            ["hp_max"] = 110,
            ["strength"] = 25,
            ["speed"] = 8,
            ["intelligence"] = 5,
        },
        name = "Shade",
        actions = { "attack" },
        drop =
        {
            xp = 100,
            gold = {5, 50},
            chance =
             {
                { oddment = 3, item = { id = -1 } },
                { oddment = 1, item = { id = 12 } }
            }
        }
    }
}