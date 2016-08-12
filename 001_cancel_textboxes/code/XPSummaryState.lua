XPSummaryState = {}
XPSummaryState.__index = XPSummaryState
function XPSummaryState:Create(stack, party, combatData)
    local this =
    {
        mStack = stack,
        mCombatData = combatData,
        mLayout = Layout:Create(),
        mXP = combatData.xp,
        mXPPerSec = 5.0,
        mXPCounter = 0,
        mIsCountingXP = true,
        mParty = party:ToArray()
    }

    local digitNumber = math.log10(this.mXP + 1)
    this.mXPPerSec = this.mXPPerSec * (digitNumber ^ digitNumber)

    this.mLayout:Contract('screen', 118, 40)
    this.mLayout:SplitHorz('screen', 'top', 'bottom', 0.5, 2)
    this.mLayout:SplitHorz('top', 'top', 'one', 0.5, 2)
    this.mLayout:SplitHorz('bottom', 'two', 'three', 0.5, 2)

    this.mLayout:SplitHorz('top', 'title', 'detail', 0.5, 2)

    this.mTitlePanels =
    {
        this.mLayout:CreatePanel("title"),
        this.mLayout:CreatePanel("detail"),
    }

    this.mActorPanels =
    {
        this.mLayout:CreatePanel("one"),
        this.mLayout:CreatePanel("two"),
        this.mLayout:CreatePanel("three"),
    }

    this.mPartySummary = {}

    local summaryLeft = this.mLayout:Left('detail') + 16
    local index = 1
    local panelIds = {"one", "two", "three"}
    for _, v in ipairs(this.mParty) do
        local panelId = panelIds[index]
        print(panelId)
        local summary = ActorXPSummary:Create(v, this.mLayout, panelId)
        -- local summaryTop = this.mLayout:Top(panelId)
        -- summary:SetPosition(summaryLeft, summaryTop)
        table.insert(this.mPartySummary, summary)
        index = index + 1
    end

    setmetatable(this, self)
    return this
end


function XPSummaryState:Enter()
    self.mIsCountingXP = true
    self.mXPCounter = 0
end

function XPSummaryState:Exit()

end

function XPSummaryState:UnlockPopUps(summary, actions)

    for k, v in pairs(actions) do

        local color = Vector.Create(1, 0.843, 0, 1)
        local db = SpecialDB
        if k == 'magic' then
            db = SpellDB
            color = Vector.Create(0.57, 0.43, 0.85, 1)
        end

        for _, id in ipairs(v) do
            local name = db[id].name
            local msg = string.format("+ %s", name)
            summary:AddPopUp(msg, color)
        end
    end
end

function XPSummaryState:ApplyXPToParty(xp)
    for k, actor in pairs(self.mParty) do

        if actor.mStats:Get("hp_now") > 0 then

            local summary = self.mPartySummary[k]

            actor:AddXP(xp)
            while(actor:ReadyToLevelUp()) do
                local levelup = actor:CreateLevelUp()
                local levelNumber = actor.mLevel + levelup.level
                summary:AddPopUp("Level Up!")

                self:UnlockPopUps(summary, levelup.actions)

                actor:ApplyLevel(levelup)
            end

        end
    end
end

function XPSummaryState:Update(dt)

    for k, v in ipairs(self.mPartySummary) do
        v:Update(dt)
    end

    if self.mIsCountingXP then

        self.mXPCounter = self.mXPCounter + self.mXPPerSec * dt
        local xpToApply = math.floor(self.mXPCounter)
        self.mXPCounter = self.mXPCounter - xpToApply
        self.mXP = self.mXP - xpToApply

        self:ApplyXPToParty(xpToApply)

        if self.mXP == 0 then
            self.mIsCountingXP = false
        end

        return
    end
end

function XPSummaryState:Render(renderer)

    renderer:DrawRect2d(System.ScreenTopLeft(),
                        System.ScreenBottomRight(),
                        Vector.Create(0,0,0,1))

    for k,v in ipairs(self.mTitlePanels) do
        v:Render(renderer)
    end

    local titleX = self.mLayout:MidX('title')
    local titleY = self.mLayout:MidY('title')
    renderer:ScaleText(1.5, 1.5)
    renderer:AlignText("center", "center")
    renderer:DrawText2d(titleX, titleY, "Experience Increased!")

    local xp = self.mXP
    local detailX = self.mLayout:Left('detail') + 16
    local detailY = self.mLayout:MidY('detail')
    renderer:ScaleText(1.25, 1.25)
    renderer:AlignText("left", "center")
    local detailStr = string.format('XP increased by %d.', xp)
    renderer:DrawText2d(detailX, detailY, detailStr)

    for i = 1, #self.mPartySummary do
        self.mActorPanels[i]:Render(renderer)
        self.mPartySummary[i]:Render(renderer)
    end

end

function XPSummaryState:ArePopUpsRemaining()
    for k, v in ipairs(self.mPartySummary) do
        if v:PopUpCount() > 0 then
            return true
        end
    end
    return false
end

function XPSummaryState:CloseNextPopUp()
    for k, v in ipairs(self.mPartySummary) do
        if v:PopUpCount() > 0 then
            v:CancelPopUp()
        end
    end
end

function XPSummaryState:SkipCountingXP()
    self.mIsCountingXP = false
    self.mXPCounter = 0
    local xpToApply = self.mXP
    self.mXP = 0
    self:ApplyXPToParty(xpToApply)
end

function XPSummaryState:HandleInput()
    if Keyboard.JustPressed(KEY_SPACE) then

        if self.mXP > 0 then
            self:SkipCountingXP()
            return
        end

        if self:ArePopUpsRemaining() then
            self:CloseNextPopUp()
            return
        end

        --self.mStack:Pop()
        self:GotoLootSummary()
    end
end

function XPSummaryState:GotoLootSummary()
    local lootSummaryState = LootSummaryState:Create(self.mStack,
                                                     gWorld,
                                                     self.mCombatData)
    -- CombatState is on top, let's push the loot summary state behind it.
    local storyboard =
    {
        SOP.BlackScreen("black", 0),
        SOP.FadeInScreen("black", 0.2),
        SOP.ReplaceState(self, lootSummaryState),
        SOP.Wait(0.1),
        SOP.FadeOutScreen("black", 0.2),
    }

    local storyboard = Storyboard:Create(self.mStack, storyboard)
    self.mStack:Push(storyboard)
end