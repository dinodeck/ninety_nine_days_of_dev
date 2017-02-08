StatusMenuState = {}
StatusMenuState.__index = StatusMenuState
function StatusMenuState:Create(parent, world)

    local layout = Layout:Create()
    layout:Contract('screen', 118, 40)
    layout:SplitHorz('screen', "title", "bottom", 0.12, 2)

    local this =
    {
        mParent = parent,
        mStateMachine = parent.mStateMachine,
        mStack = parent.mStack,

        mLayout = layout,
        mPanels =
        {
            layout:CreatePanel("title"),
            layout:CreatePanel("bottom"),
        },
    }

    setmetatable(this, self)
    return this
end

function StatusMenuState:Enter(actor)
    self.mActor = actor
    self.mActorSummary = ActorSummary:Create(actor, { showXP = true })

    self.mEquipMenu = Selection:Create
    {
        data = self.mActor.mActiveEquipSlots,
        columns = 1,
        rows = #self.mActor.mActiveEquipSlots,
        spacingY = 26,
        RenderItem = function(...) self.mActor:RenderEquipment(...) end
    }
    self.mEquipMenu:HideCursor()

    self.mActions = Selection:Create
    {
        data = self.mActor.mActions,
        columns = 1,
        rows = #self.mActor.mActions,
        spacingY = 18,
        RenderItem = function(self, renderer, x, y, item)
            local label = Actor.ActionLabels[item]
            renderer:ScaleText(1,1)
            Selection.RenderItem(self, renderer, x, y, label)
        end
    }
    self.mActions:HideCursor()

end

function StatusMenuState:Exit()
end

function StatusMenuState:Update(dt)
    if  Keyboard.JustReleased(KEY_BACKSPACE) or
        Keyboard.JustReleased(KEY_ESCAPE) then
        self.mStateMachine:Change("frontmenu")
    end
end

function StatusMenuState:DrawStat(renderer, x, y, label, value)
    local font = gGame.Font.default

    font:AlignText("right", "center")
    font:DrawText2d(renderer, x - 5, y, label)
    font:AlignText("left", "center")
    font:DrawText2d(renderer, x + 5, y, tostring(value))

end

function StatusMenuState:Render(renderer)

    local statFont = gGame.Font.stat
    local font = gGame.Font.default

    for k,v in ipairs(self.mPanels) do
        v:Render(renderer)
    end

    local titleX = self.mLayout:MidX("title")
    local titleY = self.mLayout:MidY("title")
    font:AlignText("center", "center")
    font:DrawText2d(renderer, titleX, titleY, "Status")

    local left = self.mLayout:Left("bottom") + 10
    local top = self.mLayout:Top("bottom") - 10
    self.mActorSummary:SetPosition(left , top)
    self.mActorSummary:Render(renderer)


    font:AlignText("right", "top")
    font:DrawText2d(renderer, left + 258, top-58, "XP:")
    local xpStr = string.format("%d/%d",
                                self.mActor.mXP,
                                self.mActor.mNextLevelXP)
    statFont:AlignText(renderer, "left", "top")
    statFont:DrawText2d(renderer, left + 264, top - 60, xpStr)

    self.mEquipMenu:SetPosition(-10, -64)
    self.mEquipMenu:Render(renderer)

    local stats = self.mActor.mStats

    local x = left + 106
    local y = 0
    for k, v in ipairs(Actor.ActorStats) do
        local label = Actor.ActorStatLabels[k]
        self:DrawStat(renderer, x, y, label, stats:Get(v))
        y = y - 16
    end
    y = y - 16
    for k, v in ipairs(Actor.ItemStats) do
        local label = Actor.ItemStatLabels[k]
        self:DrawStat(renderer, x, y, label, stats:Get(v))
        y = y - 16
    end

    font:AlignText("left", "top")
    local x = 80
    local y = 36
    local w = 100
    local h = 84
    -- this should be a panel - duh!
    local box = Textbox:Create
    {
        text = {""},
        textScale = 1.5,
        size =
        {
            left = x,
            right = x + w,
            top = y,
            bottom = y - h,
        },
        textbounds =
        {
            left = 10,
            right = -10,
            top = -10,
            bottom = 10
        },
        panelArgs =
        {
            texture = Texture.Find("gradient_panel.png"),
            size = 3,
        },
    }
    box.mAppearTween = Tween:Create(1,1,0)
    box:Render(renderer)
    self.mActions:SetPosition(x - 14, y - 10)
    self.mActions:Render(renderer)
end