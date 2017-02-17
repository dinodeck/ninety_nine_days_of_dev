
--
-- params =
-- {
--     texture = [texture],
--     size = [size of a single tile in pixels]
-- }
--
--

Panel = {}
Panel.__index = Panel
function Panel:Create(params)

    local this =
    {
        mTexture = params.texture,
        mUVs = GenerateUVs(params.size, params.size, params.texture),
        mTileSize = params.size,
        mTiles = {}, -- the sprites representing the border.
    }

    -- Fix up center U,Vs by moving them 0.5 texels in.
    local center = this.mUVs[5]
    local pixelToTexelX = 1 / this.mTexture:GetWidth()
    local pixelToTexelY = 1 / this.mTexture:GetHeight()
    center[1] = center[1] + (pixelToTexelX / 2)
    center[2] = center[2] + (pixelToTexelY / 2)
    center[3] = center[3] - (pixelToTexelX / 2)
    center[4] = center[4] - (pixelToTexelY / 2)
    -- The center sprite is going to be 1 pixel smaller on the X, Y
    -- So we need a variable that will account for that when scaling.
    this.mCenterScale = this.mTileSize / (this.mTileSize - 1)


    -- Create a sprite for each tile of the panel
    -- 1. top left      2. top          3. top right
    -- 4. left          5. middle       6. right
    -- 7. bottom left   8. bottom       9. bottom right
    for k, v in ipairs(this.mUVs) do
        local sprite = Sprite:Create()
        sprite:SetTexture(this.mTexture)
        sprite:SetUVs(unpack(v))
        this.mTiles[k] = sprite
    end

    setmetatable(this, self)
    return this
end

function Panel:SetColor(color)
    for k, v in ipairs(self.mTiles) do
        v:SetColor(color)
    end
end


function Panel:Position(left, top, right, bottom)

    -- Reset scales
    for _, v in ipairs(self.mTiles) do
        v:SetScale(1, 1)
    end

    local hSize = self.mTileSize / 2
    -- Align the corner tiles
    self.mTiles[1]:SetPosition(left + hSize, top - hSize)
    self.mTiles[3]:SetPosition(right - hSize, top - hSize)
    self.mTiles[7]:SetPosition(left + hSize, bottom + hSize)
    self.mTiles[9]:SetPosition(right - hSize, bottom + hSize)

    -- Calculate how much to scale the side tiles
    local widthScale = (math.abs(right - left) - (2 * self.mTileSize)) / self.mTileSize
    local centerX = (right + left) / 2

    self.mTiles[2]:SetPosition(centerX, top - hSize)
    self.mTiles[2]:SetScale(widthScale, 1)

    self.mTiles[8]:SetPosition(centerX, bottom + hSize)
    self.mTiles[8]:SetScale(widthScale, 1)


    local heightScale = (math.abs(bottom - top) - (2 * self.mTileSize)) / self.mTileSize
    local centerY = (top + bottom) / 2

    self.mTiles[4]:SetScale(1, heightScale)
    self.mTiles[4]:SetPosition(left + hSize, centerY)

    self.mTiles[6]:SetScale(1, heightScale)
    self.mTiles[6]:SetPosition(right - hSize, centerY)

    -- Scale the middle backing panel
    self.mTiles[5]:SetScale(widthScale * self.mCenterScale,
                            heightScale * self.mCenterScale)
    self.mTiles[5]:SetPosition(centerX, centerY)

    -- Hide corner tiles when scale is equal to zero
   if left - right == 0 or top - bottom == 0 then
        for _, v in ipairs(self.mTiles) do
            v:SetScale(0, 0)
        end
    end
end

function Panel:CenterPosition(x, y, width, height)
    local hWidth = width / 2
    local hHeight = height / 2
    return self:Position(x - hWidth, y + hHeight,
                         x + hWidth, y - hHeight)
end

function Panel:Render(renderer)
    for k, v in ipairs(self.mTiles) do
        renderer:DrawSprite(v)
    end
end
