-- spell cast time 1 is based, 2 is twice as long etc

SpellDB =
{
    ["fire"] =
    {
        name = "Fire",
        action = "element_spell",
        element = "fire",
        mp_cost = 8,
        cast_time = 1,
        base_damage = {3, 5}, -- multiplied by level
        base_hit_chance = 1,
        time_points = 10,
        target =
        {
            selector = "WeakestEnemy",
            switch_sides = true,
            type = "One"
        }
        --Damage = Spell Power * 4 + (Level * Magic Power * Spell Power / 32)
    },
    ["burn"] =
    {
        name = "Burn",
        action = "element_spell",
        element = "fire",
        mp_cost = 16,
        cast_time = 1.5,
        base_damage = {3, 6},
        base_hit_chance = 1,
        time_points = 20,
        target =
        {
            selector = "SideEnemy",
            switch_sides = true,
            type = "Side"
        }
    },
    ["ice"] =
    {
        name = "Ice",
        action = "element_spell",
        element = "ice",
        mp_cost = 8,
        cast_time = 1.8,
        base_damage = {7, 17},
        base_hit_chance = 1,
        time_points = 10,
        target =
        {
            selector = "WeakestEnemy",
            switch_sides = true,
            type = "One"
        }
    },
    ["bolt"] =
    {
        name = "Bolt",
        action = "element_spell",
        element = "electric",
        mp_cost = 8,
        cast_time = 1.1,
        base_damage = {4, 14},
        base_hit_chance = 1,
        time_points = 10,
        target =
        {
            selector = "WeakestEnemy",
            switch_sides = true,
            type = "One"
        }
    },
}