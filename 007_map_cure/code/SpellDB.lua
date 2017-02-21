-- spell cast time 1 is based, 2 is twice as long etc

SpellDB =
{
    ["fire"] =
    {
        name = "Fire",
        action = "element_spell",
        element = "fire",
        mp_cost = 8,
        base_damage = {3, 5}, -- multiplied by level
        base_hit_chance = 1,
        time_points = 10,
        target =
        {
            selector = "WeakestEnemy",
            switch_sides = true,
            type = "One"
        },
        description = "Damages an enemy with elemental fire!"
    },
    ["burn"] =
    {
        name = "Burn",
        action = "element_spell",
        element = "fire",
        mp_cost = 16,
        base_damage = {3, 6},
        base_hit_chance = 1,
        time_points = 20,
        target =
        {
            selector = "SideEnemy",
            switch_sides = true,
            type = "Side"
        },
        description = "Heavily damages all enemies with elemental fire!"
    },
    ["ice"] =
    {
        name = "Ice",
        action = "element_spell",
        element = "ice",
        mp_cost = 8,
        base_damage = {7, 17},
        base_hit_chance = 1,
        time_points = 10,
        target =
        {
            selector = "WeakestEnemy",
            switch_sides = true,
            type = "One"
        },
        description = "Damages an enemy with a freezing ice attack!"
    },
    ["bolt"] =
    {
        name = "Bolt",
        action = "element_spell",
        element = "electric",
        mp_cost = 8,
        base_damage = {4, 14},
        base_hit_chance = 1,
        time_points = 10,
        target =
        {
            selector = "WeakestEnemy",
            switch_sides = true,
            type = "One"
        },
        description = "Damages an enemy with an electric bolt!"
    },
    ["heal"] =
    {
        name = "Heal",
        action = "hp_restore_spell",
        mp_cost = 8,
        base_heal = 100, -- multiplied by level
        base_hit_chance = 1,
        time_points = 10,   -- what's the difference between this and cast time?
        can_use_on_map = true,
        target =
        {
            selector = "MostHurtParty",
            switch_sides = true,
            type = "One"
        },
        description = "Heals some health of a single party member."
    }
}