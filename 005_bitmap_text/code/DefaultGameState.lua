function GetDefaultGameState()
    return
    {
        defeated_cave_drake = false,
        maps =
        {
            town =
            {
                quest_given = false,
            },
            world = {},
            cave =
            {
                completed_puzzle = false,
                chests_looted = {}
            }
        }
    }
end