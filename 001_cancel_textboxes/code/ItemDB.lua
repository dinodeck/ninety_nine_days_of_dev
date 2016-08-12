ItemDB =
{
    [-1] =
    {
        name = "",
        type = "",
        icon = nil,
        restriction = nil,
        description = "",
        stats =
        {
        },
        use = nil,
        use_restriction = nil,
    },
    {
        name = "Bone Blade",
        type = "weapon",
        icon = "sword",
        restriction = {"hero"},
        description = "A wicked sword made from bone.",
        stats = { add = { attack = 5 } },
        price = 300,
    },
    {
        name = "Bone Armor",
        type = "armor",
        icon = "plate",
        restriction = {"hero"},
        description = "Armor made from plates of blackened bone.",
        stats =
        {
            add =
            {
                defense = 5,
                resist = 1,
            }
        },
        price = 500,
    },
    {
        name = "Ring of Titan",
        type = "accessory",
        description = "Grants the strength of the Titan.",
        stats = { add = { strength = 10 } },
        price = 1000
    },
    {
        name = "World Tree Branch",
        type = "weapon",
        icon = "stave",
        restriction = {"mage"},
        description = "A hard wood branch.",
        stats =
        {
            add =
            {
                attack = 2,
                magic = 5
            }
        },
        price = 300
    },
    {
        name = "Dragon's Cloak",
        type = "armor",
        icon = "robe",
        restriction = {"mage"},
        description = "A cloak of dragon scales.",
        stats =
        {
            add =
            {
                defense = 3,
                resist = 10,
            }
        },
        price = 500,
    },
    {
        name = "Singer's Stone",
        type = "accessory",
        description = "The stone's song resists magical attacks.",
        stats = { add = { resist = 10 } },
        price = 1000,
    },
    {
        name = "Black Dagger",
        type = "weapon",
        icon = "dagger",
        restriction = {"thief"},
        description = "A dagger made out of an unknown material.",
        stats = { add = { attack = 4 } },
        price = 100,
    },
    {
        name = "Footpad Leathers",
        type = "armor",
        icon = "leather",
        restriction = {"thief"},
        description = "Light armor for silent movement.",
        stats = { add = { defense = 3 } },
        price = 250,
    },
    {
        name = "Swift Boots",
        type = "accessory",
        description = "Increases speed by 25%",
        stats = { mult = { speed = 0.25 } },
        price = 2000,
    },
    {
        name = "Heal Potion",
        type = "useable",
        description = "Heal a small amount of HP.",
        use =
        {
            action = "hp_restore",
            restore = 250,
            target =
            {
                selector = "MostHurtParty",
                switch_sides = true,
                type = "One"
            },
            hint = "Choose target to heal.",
        },
        price = 50,
    },
    {
        name = "Life Salve",
        type = "useable",
        description = "Restore a character from the brink of death.",
        use =
        {
            action = "revive",
            restore = 100,
            target =
            {
                selector = "DeadParty",
                switch_sides = true,
                type = "One"
            },
            hint = "Choose target to revive.",
        },
        price = 100,
    },
    {
        name = "Mana Potion",
        type = "useable",
        description = "Restores a small amount of MP.",
        use =
        {
            action = "mp_restore",
            restore = 50,
            target =
            {
                selector = "MostDrainedParty",
                switch_sides = true,
                type = "One"
            },
            hint = "Choose target to restore mana."
        },
        price = 100,
    },
    {
        name = "Mysterious Torque",
        type = "accessory",
        description = "A golden torque that glitters.",
        stats =
        {
            add =
            {
                strength = 10,
                speed = 10
            }
        },
        price = 1000
    },
    {
        name = "Gemstone",
        type = "key",
        description = "Red gemstone shaped like a small skull."
    },
    {
        name = "Keystone",
        type = "key",
        description = "A heavy stone orb."
    }
}

EmptyItem = ItemDB[-1]

--Give all items an id based on their position
-- in the list.
for id, def in pairs(ItemDB) do
    def.id = id
    print(id, def.name)
end