MagicMenuState = {}
MagicMenuState.__index = MagicMenuState
function MagicMenuState:Create(parent)

    local this =
    {
        mParent = parent,
        mStack = parent.mStack,
        mStateMachine = parent.mStateMachine,
        mScrollbar = Scrollbar:Create(Texture.Find("scrollbar.png"), 184),
        mSpellMenu = nil
    }
    setmetatable(this, self)
    return this
end

function MagicMenuState:Enter(actor)

    -- Magic shown depends on the actor.
    self.mActor = actor

    local layout = Layout:Create()
    layout:Contract('screen', 118, 40)
    layout:SplitHorz('screen', "top", "bottom", 0.12, 2)
    layout:SplitVert('top', "title", "category", 0.7, 2)
    layout:SplitHorz('bottom', "detail", "spells", 0.3, 2)
    layout:SplitHorz('detail', "char", "desc", 0.5, 2)

    self.mPanels =
    {
        layout:CreatePanel("title"),
        layout:CreatePanel("category"),
        layout:CreatePanel("char"),
        layout:CreatePanel("desc"),
        layout:CreatePanel("spells"),
    }

    self.mMPBar = ProgressBar:Create
    {
        value = self.mActor.mStats:Get("mp_now"),
        maximum = self.mActor.mStats:Get("mp_max"),
        background = Texture.Find("mpbackground.png"),
        foreground = Texture.Find("mpforeground.png"),
    }
    self.mMPBarWidth = Texture.Find("mpbackground.png"):GetWidth()

    self.mSpellMenu = Selection:Create
    {
        data = actor.mMagic,
        OnSelection = function(...) self:OnCastSpell(...) end, -- new!
        spacingX = 256,
        displayRows = 6,
        spacingY = 28,
        columns = 2,
        rows = 20,
        RenderItem = function(...) self:RenderSpell(...) end
    }

    local mpBarX = layout:Right("char")
    mpBarX = mpBarX - (self.mMPBarWidth * 0.5)
    mpBarX = mpBarX - 10
    local mpBarY = layout:Bottom("char") + 12
    self.mMPBar:SetPosition(mpBarX, mpBarY)
    self.mMPBarRight = mpBarX - (self.mMPBarWidth * 0.5)

    self.mLayout = layout
end

function MagicMenuState:Exit()
end

function MagicMenuState:CanCast(spellDef)
    if spellDef == nil or not spellDef.can_use_on_map then
       return false
    end

    return self.mActor:CanCast(spellDef)
end

function MagicMenuState:RenderSpell(menu, renderer, x, y, item)

    local font = gGame.Font.default

    if item == nil then
       font:DrawText2d(renderer, x, y, "--")
    else
        local spell = SpellDB[item]
        local horzSpace = 96
        local color = Vector.Create(107/255, 107/255, 107/255, 1)

        if self:CanCast(spell) then
            color = Vector.Create(1, 1, 1, 1)
        end

        font:DrawText2d(renderer, x, y, spell.name, color)
        font:DrawText2d(renderer, x + horzSpace, y,
                        string.format("%d", spell.mp_cost), color)
    end
end

function MagicMenuState:Update(dt)

    local menu = self.mSpellMenu

    menu:HandleInput()

    if  Keyboard.JustReleased(KEY_BACKSPACE) or
        Keyboard.JustReleased(KEY_ESCAPE) then
        self.mStateMachine:Change("frontmenu")
    end

    local scrolled = menu:PercentageScrolled()
    self.mScrollbar:SetScrollCaretScale(menu:PercentageShown())
    self.mScrollbar:SetNormalValue(scrolled)
end

function MagicMenuState:GetSelectedManaCost()
    local menu = self.mSpellMenu
    local item = spellMenu:SelectedItem()

    if item then
        local spell = SpellDB[item]
        return spell.mp_cost
    end

    return 0
end

function MagicMenuState:GetSelectedDescription()
    local menu = self.mSpellMenu
    local item = menu:SelectedItem()

    if item then
        local spell = SpellDB[item]
        return spell.description or "???"
    end

    return ""
end

function MagicMenuState:Render(renderer)

    local font = gGame.Font.default

    for k,v in ipairs(self.mPanels) do
        v:Render(renderer)
    end

    font:AlignText("center", "center")
    local titleX = self.mLayout:MidX("title")
    local titleY = self.mLayout:MidY("title")
    font:DrawText2d(renderer, titleX, titleY, "Magic")

    font:AlignText("left", "center")
    local charX = self.mLayout:Left("char")
    local charY = self.mLayout:MidY("char")
    font:DrawText2d(renderer, charX + 10, charY, self.mActor.mName)

    -- MP BAR and STATS
    local statFont = gGame.Font.stat

    local mp = self.mActor.mStats:Get("mp_now")
    local maxMP = self.mActor.mStats:Get("mp_max")

    self.mMPBar:SetValue(mp)
    self.mMPBar:Render(renderer)

    local counter = "%d/%d"
    local mp = string.format(counter,
                             mp,
                             maxMP)
    local mpX = self.mMPBarRight
    local mpY = self.mLayout:MidY("char")

    statFont:AlignText("left", "center")
    statFont:DrawText2d(renderer, mpX, mpY, mp)
    font:AlignText("right", "center")
    mpX = mpX - 8
    font:DrawText2d(renderer, mpX, mpY, "MP")
    -- END OF MP BAR and STATS

    font:AlignText("left", "center")
    local descX = self.mLayout:Left("desc")
    local descY = self.mLayout:MidY("desc")
    local desc = self:GetSelectedDescription()
    font:DrawText2d(renderer, descX + 10, descY, desc)

    local spellX = self.mLayout:Left("spells") + 6
    local spellY = self.mLayout:Top("spells") - 30
    local menu = self.mSpellMenu
    menu:SetPosition(spellX, spellY)
    menu:Render(renderer)

    local scrollX = self.mLayout:Right("spells") - 14
    local scrollY = self.mLayout:MidY("spells")
    self.mScrollbar:SetPosition(scrollX, scrollY)
    self.mScrollbar:Render(renderer)
end

function MagicMenuState:OnCastSpell(index, spellId)

    local spellDef = SpellDB[spellId]

    if self:CanCast(spellDef) then
        local selectId = spellDef.target.selector
        local targetState = MenuTargetState:Create
        {
            originState = self,
            stack = gGame.Stack,
            stateMachine = self.mStateMachine,
            targetType = spellDef.target.type,
            selector = MenuActorSelector[selectId],
            OnCancel = function(target) print("Cancelled") end,
            OnSelect = function(targets) self:OnSpellTargetsSelected(spellDef, targets) end
        }
        gGame.Stack:Push(targetState)

    end
end

function MagicMenuState:OnSpellTargetsSelected(spellDef, targets)
    self.mActor:ReduceManaForSpell(spellDef)
    local action = spellDef.action
    print(action)
    CombatActions[action](self.mState,
                           self.mActor,
                           targets,
                           spellDef,
                           "magic_menu")
end
