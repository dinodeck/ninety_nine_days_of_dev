
Icons = {}
Icons.__index = Icons
function Icons:Create(texture)
    local this =
    {
        mTexture = texture,
        mUVs = {},
        mSprites = {},
        mIconDefs =
        {
            useable = 1,
            accessory = 2,
            weapon = 3,
            sword = 4,
            dagger = 5,
            stave = 6,
            armor = 7,
            plate = 8,
            leather = 9,
            robe = 10,
            uparrow = 11,
            downarrow = 12
        }
    }
    this.mUVs = GenerateUVs(18, 18, this.mTexture)

    for k, v in pairs(this.mIconDefs) do
        local sprite = Sprite.Create()
        sprite:SetTexture(this.mTexture)
        sprite:SetUVs(unpack(this.mUVs[v]))
        this.mSprites[k] = sprite
    end

    setmetatable(this, self)
    return this
end

function Icons:Get(id)
    return self.mSprites[id]
end

