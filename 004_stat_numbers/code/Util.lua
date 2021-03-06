
function GenerateUVs(tileWidth, tileHeight, texture)

    -- This is the table we'll fill with uvs and return.
    local uvs = {}

    local textureWidth = texture:GetWidth()
    local textureHeight = texture:GetHeight()
    local width = tileWidth / textureWidth
    local height = tileHeight / textureHeight
    local cols = textureWidth / tileWidth
    local rows = textureHeight / tileHeight

    local ux = 0
    local uy = 0
    local vx = width
    local vy = height

    for j = 0, rows - 1 do
        for i = 0, cols -1 do

            table.insert(uvs, {ux, uy, vx, vy})

            -- Advance the UVs to the next column
            ux = ux + width
            vx = vx + width

        end

        -- Put the UVs back to the start of the next row
        ux = 0
        vx = width
        uy = uy + height
        vy = vy + height
    end
    return uvs
end

function ShallowClone(t)
    local clone = {}
    for k, v in pairs(t) do
        clone[k] = v
    end
    return clone
end

function DeepClone(t)
    local clone = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            clone[k] = DeepClone(v)
        else
            clone[k] = v
        end
    end
    return clone
end

function Clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

function PixelCoordsToUVs(tex, def)
    local texWidth = tex:GetWidth()
    local texHeight = tex:GetHeight()

    local x = def.x / texWidth
    local y = def.y / texHeight
    local width = def.width / texWidth
    local height = def.height / texHeight

    return {x, y, x + width, y + height}

end

function CreateSpriteSet(def)
    local texture = Texture.Find(def.texture)
    local spriteSet = {}
    for k, v in pairs(def.sprites) do
        local sprite = Sprite.Create()
        sprite:SetTexture(texture)
        sprite:SetUVs(unpack(PixelCoordsToUVs(texture, v)))
        spriteSet[k] = sprite
    end
    return spriteSet
end