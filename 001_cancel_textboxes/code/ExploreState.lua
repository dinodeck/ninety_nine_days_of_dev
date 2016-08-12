
ExploreState = {}
ExploreState.__index = ExploreState
function ExploreState:Create(stack, mapDef, startPos)
    local this =
    {
        mStack = stack,
        mMapDef = mapDef,

        mFollowCam = true,
        mFollowChar = nil,
        mManualCamX = 0,
        mManualCamY = 0,
    }


    this.mMap = Map:Create(this.mMapDef)
    this.mHero = Character:Create(gCharacters.hero, this.mMap)
    this.mHero.mEntity:SetTilePos(
        startPos:X(),
        startPos:Y(),
        startPos:Z(), this.mMap)
    this.mMap:GotoTile(startPos:X(), startPos:Y())

    this.mFollowChar = this.mHero
    setmetatable(this, self)
    return this
end

function ExploreState:HideHero()
    self.mHero.mEntity:SetTilePos(
        self.mHero.mEntity.mTileX,
        self.mHero.mEntity.mTileY,
        -1,
        self.mMap
    )
end

function ExploreState:ShowHero(layer)
     self.mHero.mEntity:SetTilePos(
        self.mHero.mEntity.mTileX,
        self.mHero.mEntity.mTileY,
        layer or 1,
        self.mMap
    )
end

function ExploreState:Enter()
end

function ExploreState:Exit()
end

function ExploreState:UpdateCamera(map)

    if self.mFollowCam then
        local pos = self.mHero.mEntity.mSprite:GetPosition()
        map.mCamX = math.floor(pos:X())
        map.mCamY = math.floor(pos:Y())
    else
        map.mCamX = math.floor(self.mManualCamX)
        map.mCamY = math.floor(self.mManualCamY)
    end

end

function ExploreState:SetFollowCam(flag, character)
    self.mFollowChar = character or self.mFollowChar
    self.mFollowCam = flag
    if not self.mFollowCam then
        local pos = self.mFollowChar.mEntity.mSprite:GetPosition()
        self.mManualCamX = pos:X()
        self.mManualCamY = pos:Y()
    end
end

function ExploreState:Update(dt)

    local hero = self.mHero
    local map = self.mMap

    self:UpdateCamera(map)

    for k, v in ipairs(map.mNPCs) do
        v.mController:Update(dt)
    end
end

function ExploreState:Render(renderer)

    local hero = self.mHero
    local map = self.mMap

    renderer:Translate(-map.mCamX, -map.mCamY)
    local layerCount = map:LayerCount()

    for i = 1, layerCount do

        local heroEntity = nil
        if i == hero.mEntity.mLayer then
            heroEntity = hero.mEntity
        end

        map:RenderLayer(gRenderer, i, heroEntity)

    end

    renderer:Translate(0, 0)
end

function ExploreState:HandleInput()

    if gWorld:IsInputLocked() then
        return
    end

    self.mHero.mController:Update(GetDeltaTime())

    if Keyboard.JustPressed(KEY_SPACE) then
        -- which way is the player facing?
        local x, y = self.mHero:GetFacedTileCoords()
        print(x,y)
        local layer = self.mHero.mEntity.mLayer
        local trigger = self.mMap:GetTrigger(x, y, layer)
        if trigger then
            trigger:OnUse(self.mHero, x, y, layer)
        end
    end

    if Keyboard.JustPressed(KEY_LALT) then
        local menu = InGameMenuState:Create(self.mStack, self.mMapDef)
        return self.mStack:Push(menu)
    end

end