SpecialDB =
{
    ['slash'] =
    {
        name = "Slash",
        mp_cost = 15,
        action = "slash",
        time_points = 10,
        target =
        {
            selector = "SideEnemy",
            switch_sides = false,
            type = "Side"
        }
    },
    ['steal'] =
    {
        name = "Steal",
        mp_cost = 0,
        action = "steal",
        time_points = 10,
        target =
        {
            selector = "WeakestEnemy",
            switch_sides = false,
            type = "One"
        }
    }
}