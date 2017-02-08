Entity = {}
Entity.__index = Entity
function Entity:Create(def)
    local this =
    {
        mSprite = Sprite.Create(),
        mTexture = Texture.Find(def.texture),
        mHeight = def.height,
        mWidth = def.width,
        mTileX = def.tileX,
        mTileY = def.tileY,
        mLayer = def.layer,
        mStartFrame = def.startFrame,
        mX = def.x or 0,
        mY = def.y or 0,
        mChildren = {}
    }

    this.mSprite:SetTexture(this.mTexture)
    this.mUVs = GenerateUVs(this.mWidth, this.mHeight, this.mTexture)
    setmetatable(this, self)
    this:SetFrame(this.mStartFrame)
    return this
end

function Entity:SetFrame(frame)
    self.mSprite:SetUVs(unpack(self.mUVs[frame]))
end

function Entity:SetTilePos(x, y, layer, map)

    -- Remove from current tile
    if map:GetEntity(self.mTileX, self.mTileY, self.mLayer) == self then
        map:RemoveEntity(self)
    end

    -- Check target tile
    if map:GetEntity(x, y, layer, map) ~= nil then
        for k, v in pairs(map:GetEntity(x, y, layer, map)) do
            print(k, v)
        end
        assert(false) -- there's something in the target position!
    end

    self.mTileX = x or self.mTileX
    self.mTileY = y or self.mTileY
    self.mLayer = layer or self.mLayer

    map:AddEntity(self)
    local x, y = map:GetTileFoot(self.mTileX, self.mTileY)
    self.mSprite:SetPosition(x, y + self.mHeight / 2)
    self.mX = x
    self.mY = y


end

-- Get a position just above the top of the sprite
function Entity:GetSelectPosition()

    local pos = self.mSprite:GetPosition()
    local height = self.mHeight

    local x = pos:X()
    local y = pos:Y() + height / 2

    local yPad = 16

    y = y + yPad

    return Vector.Create(x, y)
end



function Entity:GetTargetPosition()

    local pos = self.mSprite:GetPosition()
    local width = self.mWidth

    local x = pos:X() + width / 2
    local y = pos:Y()

    return Vector.Create(x, y)

end

function Entity:AddChild(id, entity)
    assert(self.mChildren[id] == nil)
    self.mChildren[id] = entity
end

function Entity:RemoveChild(id)
    self.mChildren[id] = nil
end

function Entity:Render(renderer)
    renderer:DrawSprite(self.mSprite)

    for k, v in pairs(self.mChildren) do
        local sprite = v.mSprite
        sprite:SetPosition(self.mX + v.mX, self.mY + v.mY)
        renderer:DrawSprite(sprite)
    end

end