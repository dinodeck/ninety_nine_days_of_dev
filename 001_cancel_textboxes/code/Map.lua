
Map = {}
Map.__index = Map
function Map:Create(mapDef)
    local layer = mapDef.layers[1]
    local this =
    {
        mX = 0,
        mY = 0,
        mMapDef = mapDef,
        mTextureAtlas = Texture.Find(mapDef.tilesets[1].image),

        mTileSprite = Sprite.Create(),
        mLayer = layer,
        mWidth = layer.width,
        mHeight = layer.height,

        mTiles = layer.data,
        mTileWidth = mapDef.tilesets[1].tilewidth,
        mTileHeight = mapDef.tilesets[1].tileheight,
        mTriggers = {},
        mEntities = {},
        mNPCs = {},
        mNPCbyId = {},
    }
    this.mTileSprite:SetTexture(this.mTextureAtlas)

    -- Top left corner of the map
    this.mX = -System.ScreenWidth() / 2 + this.mTileWidth / 2
    this.mY = System.ScreenHeight() / 2 - this.mTileHeight / 2

    this.mCamX = 0
    this.mCamY = 0

    this.mWidthPixel = this.mWidth * this.mTileWidth
    this.mHeightPixel = this.mHeight * this.mTileHeight
    this.mUVs = GenerateUVs(mapDef.tilesets[1].tilewidth,
                            mapDef.tilesets[1].tileheight,
                            this.mTextureAtlas)

    -- Assign blocking tile id
    for _, v in ipairs(mapDef.tilesets) do
        if v.name == "collision_graphic" then
            this.mBlockingTile = v.firstgid
        end
    end
    assert(this.mBlockingTile)
    print('blocking tile is', this.mBlockingTile)

    --
    -- Create the Actions from the def
    --
    this.mActions = {}
    for name, def in pairs(mapDef.actions or {}) do

        -- Look up the action and create the action-function
        -- The action takes in the map as the first param
        assert(Actions[def.id])
        local action = Actions[def.id](this, unpack(def.params))
        this.mActions[name] = action
    end

    --
    -- Create the Trigger types from the def
    --
    this.mTriggerTypes = {}
    for k, v in pairs(mapDef.trigger_types or {}) do
        local triggerParams = {}
        for callback, action in pairs(v) do
            triggerParams[callback] = this.mActions[action]
            assert(triggerParams[callback])
        end
        this.mTriggerTypes[k] = Trigger:Create(triggerParams)
    end

    -- Setup encounter data
    local encounterData = mapDef.encounters or {}
    this.mEncounters = {}
    for k, v in ipairs(encounterData) do
        local oddTable = OddmentTable:Create(v)
        this.mEncounters[k] = oddTable
    end
    print("Oddment size", #this.mEncounters)


    setmetatable(this, self)

    --
    -- Place any triggers on the map
    --
    this.mTriggers = {}
    for k, v in ipairs(mapDef.triggers) do
        this:AddTrigger(v)
    end

    for _, v in ipairs(mapDef.on_wake or {}) do
        local action = Actions[v.id]
        action(this, unpack(v.params))()
    end

    return this
end

-- If would be good to renamed this AddTrigerFromDef
function Map:AddTrigger(def)
    local x = def.x
    local y = def.y
    local layer = def.layer or 1

    if not self.mTriggers[layer] then
        self.mTriggers[layer] = {}
    end

    local targetLayer = self.mTriggers[layer]
    local trigger = self.mTriggerTypes[def.trigger]
    assert(trigger)
    targetLayer[self:CoordToIndex(x, y)] = trigger
    --print("Add trigger", x, y)
    --print("Trigger", self:GetTrigger(x, y, layer))
end

function Map:AddFullTrigger(trigger, x, y, layer)

    layer = layer or 1

    -- Create trigger layer if it doesn't exist.
    if not self.mTriggers[layer] then
        self.mTriggers[mLayer] = {}
    end

    local targetLayer = self.mTriggers[layer]
    targetLayer[self:CoordToIndex(x, y)] = trigger

end

function Map:GetEntity(x, y, layer)
    if not self.mEntities[layer] then
        return nil
    end
    local index = self:CoordToIndex(x, y)
    return self.mEntities[layer][index]
end

function Map:AddEntity(entity)

    -- Add the layer if it doesn't exist
    if not self.mEntities[entity.mLayer] then
        self.mEntities[entity.mLayer] = {}
    end

    local layer = self.mEntities[entity.mLayer]
    local index = self:CoordToIndex(entity.mTileX, entity.mTileY)

    assert(layer[index] == entity or layer[index] == nil)
    layer[index] = entity
end

function Map:RemoveEntity(entity)
    -- The layer should exist!
    assert(self.mEntities[entity.mLayer])
    local layer = self.mEntities[entity.mLayer]
    local index = self:CoordToIndex(entity.mTileX, entity.mTileY)
    -- The entity should be at the position
    assert(entity == layer[index])
    layer[index] = nil
end

function Map:GetTile(x, y, layer)
    local layer = layer or 1
    local tiles = self.mMapDef.layers[layer].data

    return tiles[self:CoordToIndex(x, y)]
end

function Map:WriteTile(params)
    local layer = params.layer or 1
    local detail = params.detail or 0

    -- Each layer is 3 of parts
    layer = ((layer - 1) * 3) + 1
    print("LAYER SET TO", layer)

    local x = params.x
    local y = params.y
    local tile = params.tile
    local collision = self.mBlockingTile
    if not params.collision then
        collision = 0
    end

    local index = self:CoordToIndex(x, y)
    local tiles = self.mMapDef.layers[layer].data
    tiles[index] = tile

    -- Detail
    tiles = self.mMapDef.layers[layer + 1].data
    tiles[index] = detail

    -- Collision
    tiles = self.mMapDef.layers[layer + 2].data
    tiles[index] = collision

end

function Map:GetTrigger(x, y, layer)
    layer = layer or 1
    local triggers = self.mTriggers[layer]

    if not triggers then
        return
    end

    local index = self:CoordToIndex(x, y)
    return triggers[index]
end

function Map:RemoveTrigger(x, y, layer)
    layer = layer or 1
    assert(self.mTriggers[layer])
    local triggers = self.mTriggers[layer]
    local index = self:CoordToIndex(x, y)
    assert(triggers[index])
    triggers[index] = nil
end

function Map:GetNPC(x, y, layer)
    layer = layer or 1

    for _, npc in ipairs(self.mNPCs) do
        if npc.mEntity.mTileX == x
            and npc.mEntity.mTileY == y
            and npc.mEntity.mLayer == layer then
            return npc
        end
    end

    return nil

end

function Map:RemoveNPC(x, y, layer)
    layer = layer or 1

    for i = #self.mNPCs, 1, -1 do
        local npc = self.mNPCs[i]
        if npc.mEntity.mTileX == x
            and npc.mEntity.mTileY == y
            and npc.mEntity.mLayer == layer then
            table.remove(self.mNPCs, i)
            self:RemoveEntity(npc.mEntity)
            self.mNPCbyId[npc.mId] = nil
            return true
        end
    end

    return false
end

function Map:CoordToIndex(x, y)
    x = x + 1 -- change from  1 -> rowsize
              -- to           0 -> rowsize - 1
    return x + y * self.mWidth
end

function Map:IsBlocked(layer, tileX, tileY)
    -- Collision layer should always be 2 above the official layer
    local tile = self:GetTile(tileX, tileY, layer + 2)
    local entity = self:GetEntity(tileX, tileY, layer)
    --print(tileX, tileY, layer, tile, tile == self.mBlockingTile)
    return tile == self.mBlockingTile or entity ~= nil
end

function Map:GetTileFoot(x, y)
    return  self.mX + (x * self.mTileWidth),
            self.mY - (y * self.mTileHeight) - self.mTileHeight / 2
end

function Map:GotoTile(x, y)
    print("Goto tile:", x, y)
    self:Goto((x * self.mTileWidth) + self.mTileWidth/2,
              (y * self.mTileHeight) + self.mTileHeight/2)
end

function Map:Goto(x, y)
    self.mCamX = x - System.ScreenWidth()/2
    self.mCamY = -y + System.ScreenHeight()/2
end

function Map:PointToTile(x, y)

    -- Tiles are rendered from the center so we adjust for this.
    x = x + self.mTileWidth / 2
    y = y - self.mTileHeight / 2

    -- Clamp the point to the bounds of the map
    x = math.max(self.mX, x)
    y = math.min(self.mY, y)
    x = math.min(self.mX + self.mWidthPixel - 1, x)
    y = math.max(self.mY- self.mHeightPixel + 1, y)


    -- Map from the bounded point to a tile
    local tileX = math.floor((x - self.mX) / self.mTileWidth)
    local tileY = math.floor((self.mY - y) / self.mTileHeight)

    return tileX, tileY
end

function Map:LayerCount()
    -- Number of layers should be a factor of 3
    assert(#self.mMapDef.layers % 3 == 0)
    return #self.mMapDef.layers / 3
end


function Map:Render(renderer)
    self:RenderLayer(renderer, 1)
end

function Map:TileToScreen(tX, tY)
    local x = -self.mCamX + self.mX + tX * self.mTileWidth
    local y = -self.mCamY + self.mY - tY * self.mTileHeight
    return x, y
end

function Map:RenderLayer(renderer, layer, hero)

    -- Our layers are made of 3 sections
    -- We want the index to point to the tile layer of a give section
    local layerIndex = (layer * 3) - 2

    local tileLeft, tileBottom =
        self:PointToTile(self.mCamX - System.ScreenWidth() / 2,
                         self.mCamY - System.ScreenHeight() / 2)

    local tileRight, tileTop =
        self:PointToTile(self.mCamX + System.ScreenWidth() / 2,
                         self.mCamY + System.ScreenHeight() / 2)

    for j = tileTop, tileBottom do
        for i = tileLeft, tileRight do

            local tile = self:GetTile(i, j, layerIndex)
            local uvs = {}


            self.mTileSprite:SetPosition(self.mX + i * self.mTileWidth,
                                         self.mY - j * self.mTileHeight)

            -- There can be empty tiles in the first layer too!
            if tile > 0 then
                uvs = self.mUVs[tile]

                assert(uvs, string.format("No uvs for tile [%d]", tile))

                self.mTileSprite:SetUVs(unpack(uvs))
                renderer:DrawSprite(self.mTileSprite)
            end

            -- The second section of layer is always the decoration.
            tile = self:GetTile(i, j, layerIndex + 1)

            -- If the decoration tile exists
            if tile > 0 then
                uvs = self.mUVs[tile]
                self.mTileSprite:SetUVs(unpack(uvs))
                renderer:DrawSprite(self.mTileSprite)
            end
        end

        local entLayer = self.mEntities[layer] or {}
        local drawList = { hero }

        for _, j in pairs(entLayer) do
            table.insert(drawList, j)
        end

        table.sort(drawList, function(a, b) return a.mTileY < b.mTileY end)
        for _, j in ipairs(drawList) do
            j:Render(renderer)
        end
    end
end

function Map:TryEncounter(x, y, layer)

    -- Get the tile id from the collision layer (layer +2)
    local tile = self:GetTile(x, y, layer + 2)
    if tile <= self.mBlockingTile then
        return
    end

    -- Get the index into the encounter table
    local index = tile - self.mBlockingTile
    local odd = self.mEncounters[index]

    if not odd then
        return
    end

    local encounter = odd:Pick()

    -- Empty encounter
    if not next(encounter) then
        return
    end

    print(string.format("%d tile id. index: %d", tile, index))
    local action = Actions.Combat(self, encounter)
    action(nil, nil, x, y, layer)

end