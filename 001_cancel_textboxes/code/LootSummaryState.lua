LootSummaryState = {}
LootSummaryState.__index = LootSummaryState
function LootSummaryState:Create(stack, world, combatData)
    local this =
    {
        mStack = stack,
        mWorld = world,
        mLayout = Layout:Create(),
        mPanels = {},
        mLoot = combatData.loot or {},
        mGold = combatData.gold or 0,
        mGoldPerSec = 5.0,
        mGoldCounter = 0,
        mIsCountingGold = true,
    }

    local digitNumber = math.log10(this.mGold + 1)
    this.mGoldPerSec = this.mGoldPerSec * (digitNumber ^ digitNumber)

    this.mLayout:Contract('screen', 118, 40)
    this.mLayout:SplitHorz('screen', 'top', 'bottom', 0.25, 2)
    this.mLayout:SplitHorz('top', 'title', 'detail', 0.55, 2)
    this.mLayout:SplitVert('detail', 'left', 'right', 0.5, 1)
    this.mPanels =
    {
        this.mLayout:CreatePanel('title'),
        this.mLayout:CreatePanel('left'),
        this.mLayout:CreatePanel('right'),
        this.mLayout:CreatePanel('bottom'),
    }

    setmetatable(this, self)

    this.mLootView = Selection:Create
    {
        data = combatData.loot,
        spacingX = 175,
        columns = 3,
        rows = 9,
        RenderItem = function(self, ...) this:RenderItem(...) end
    }

    local lootX = this.mLayout:Left('bottom') - 16
    local lootY = this.mLayout:Top('bottom') - 16
    this.mLootView:SetPosition(lootX, lootY)
    this.mLootView:HideCursor()

    return this
end

function LootSummaryState:RenderItem(renderer, x, y, item)
    if not item then
        return
    end

    local def = ItemDB[item.id]
    local text = def.name

    if item.count > 1 then
        text = string.format("%s x%d", text, item.count)
    end

    renderer:DrawText2d(x, y, text)
end

function LootSummaryState:Enter()
    self.mIsCountingGold = true
    self.mGoldCounter = 0

    -- Add the items to the inventory.
    for k, v in ipairs(self.mLoot) do
        self.mWorld:AddItem(v.id, v.count)
    end
end

function LootSummaryState:Exit()
end

function LootSummaryState:Update(dt)

    if self.mIsCountingGold then

        self.mGoldCounter = self.mGoldCounter + self.mGoldPerSec * dt
        local goldToGive = math.floor(self.mGoldCounter)
        self.mGoldCounter = self.mGoldCounter - goldToGive
        self.mGold = self.mGold - goldToGive

        self.mWorld.mGold = self.mWorld.mGold + goldToGive

        if self.mGold == 0 then
            self.mIsCountingGold = false
        end

        return
    end
end

function LootSummaryState:Render(renderer)

    renderer:DrawRect2d(System.ScreenTopLeft(),
                    System.ScreenBottomRight(),
                    Vector.Create(0,0,0,1))

    for _, v in pairs(self.mPanels) do
        v:Render(renderer)
    end


    local titleX = self.mLayout:MidX('title')
    local titleY = self.mLayout:MidY('title')
    renderer:ScaleText(1.5, 1.5)
    renderer:AlignText("center", "center")
    renderer:DrawText2d(titleX, titleY, "Found Loot!")

    renderer:AlignText("left", "center")
    renderer:ScaleText(1.25, 1.25)
    local leftX = self.mLayout:Left('left') + 12
    local leftValueX = self.mLayout:Right('left') - 12
    local leftY = self.mLayout:MidY('left')
    local goldLabelStr = "Gold Found:"
    local goldValueStr = string.format("%d gp", self.mGold)
    renderer:DrawText2d(leftX, leftY, goldLabelStr)
    renderer:AlignText("right", "center")
    renderer:DrawText2d(leftValueX, leftY, goldValueStr)

    renderer:AlignText("left", "center")
    local rightX = self.mLayout:Left('right') + 12
    local rightValueX = self.mLayout:Right('right') - 12
    local rightY = leftY
    local partyGPStr = string.format("%d gp", self.mWorld.mGold)
    renderer:DrawText2d(rightX, rightY, "Party Gold:")
    renderer:AlignText("right", "center")
    renderer:DrawText2d(rightValueX, rightY, partyGPStr)

    renderer:AlignText("center", "center")

    renderer:AlignText("left", "top")
    self.mLootView:Render(renderer)
end

function LootSummaryState:SkipCountingGold()
    self.mIsCountingGold = false
    self.mGoldCounter = 0
    local goldToGive = self.mGold
    self.mGold = 0
    self.mWorld.mGold = self.mWorld.mGold + goldToGive
end

function LootSummaryState:HandleInput()
    if Keyboard.JustPressed(KEY_SPACE) then

        if self.mGold > 0 then
            self:SkipCountingGold()
            return
        end

        self.mStack:Pop()
        local storyboard =
        {
            SOP.BlackScreen("black", 1),
            SOP.Wait(0.1),
            SOP.FadeOutScreen("black", 0.2),
        }
        local storyboard = Storyboard:Create(self.mStack, storyboard)
        storyboard:Update(0) -- creates the black screen this frame
        self.mStack:Push(storyboard)
    end
end