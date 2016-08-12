CombatChoiceState = {}
CombatChoiceState.__index = CombatChoiceState
function CombatChoiceState:Create(context, actor)
    local this =
    {
        mStack = context.mStack,
        mCombatState = context,
        mActor = actor,
        mCharacter = context.mActorCharMap[actor],
        mUpArrow = gWorld.mIcons:Get('uparrow'),
        mDownArrow = gWorld.mIcons:Get('downarrow'),
        mMarker = Sprite.Create(),
        mHide = false,
    }

    this.mMarker:SetTexture(Texture.Find('continue_caret.png'))
    this.mMarkPos = this.mCharacter.mEntity:GetSelectPosition()
    this.mTime = 0


    setmetatable(this, self)

    this.mSelection = Selection:Create
    {
        data = this.mActor.mActions,
        columns = 1,
        displayRows = 3,
        spacingX = 0,
        spacingY = 19,
        OnSelection = function(...) this:OnSelect(...) end,
        RenderItem = this.RenderAction,
    }

    this:CreateChoiceDialog()

    return this
end

function CombatChoiceState:Hide()
    self.mHide = true
end

function CombatChoiceState:Show()
    self.mHide = false
end

function CombatChoiceState:SetArrowPosition()
    local x = self.mTextbox.mSize.left
    local y = self.mTextbox.mSize.top
    local width = self.mTextbox.mWidth
    local height = self.mTextbox.mHeight

    local arrowPad = 9
    local arrowX = x + width - arrowPad
    self.mUpArrow:SetPosition(arrowX, y - arrowPad)
    self.mDownArrow:SetPosition(arrowX, y - height + arrowPad)
end

function CombatChoiceState:CreateChoiceDialog()
    local x = -System.ScreenWidth()/2
    local y = -System.ScreenHeight()/2

    local height = self.mSelection:GetHeight() + 18
    local width = self.mSelection:GetWidth() + 16

    y = y + height + 16
    x = x + 100


    self.mTextbox = Textbox:Create
    {
        textScale = 1.2,
        text = "",
        size =
        {
            left = x,
            right = x + width,
            top = y,
            bottom = y - height
        },
        textbounds =
        {
            left = -20,
            right = 0,
            top = 0,
            bottom = 2
        },
        panelArgs =
        {
            texture = Texture.Find("gradient_panel.png"),
            size = 3,
        },
        selectionMenu = self.mSelection,
        stack = self.mStack,
    }
end

function CombatChoiceState:RenderAction(renderer, x, y, item)

    local text = Actor.ActionLabels[item] or ""
    renderer:DrawText2d(x, y, text)
end

function CombatChoiceState:OnSelect(index, data)

    print("on select", index, data)

    if data == "attack" then
        self.mSelection:HideCursor()
        local state = CombatTargetState:Create(
            self.mCombatState,
            {
                targetType = CombatTargetType.One,
                --switchSides = false,
                OnSelect = function(targets)
                   self:TakeAction(data, targets)
                end,
                OnExit = function()
                    self.mSelection:ShowCursor()
                end
            })
        self.mStack:Push(state)
    elseif data == "flee" then
        self.mStack:Pop() -- choice state
        local queue = self.mCombatState.mEventQueue
        local event = CEFlee:Create(self.mCombatState, self.mActor)
        local tp = event:TimePoints(queue)
        queue:Add(event, tp)
    elseif data == "item" then

        self:OnItemAction()

    elseif data == "magic" then

        self:OnMagicAction()

    elseif data == "special" then

        self:OnSpecialAction()

    end
end

function CombatChoiceState:OnSpecialAction()

    local actor = self.mActor

    --  Create the selection box
    local x = self.mTextbox.mSize.left - 64
    local y = self.mTextbox.mSize.top
    self.mSelection:HideCursor()

    local OnRenderItem = function(self, renderer, x, y, item)
       local text = "--"
       local cost = "0"
       local canPerform = false
       local mp = actor.mStats:Get("mp_now")

       local color = Vector.Create(1,1,1,1)
        if item then
            local def = SpecialDB[item]
            text = def.name
            cost = string.format("%d", def.mp_cost)

            if def.mp_cost > 0 then

                canPerform = mp >= def.mp_cost

                if not canPerform then
                    color = Vector.Create(0.7, 0.7, 0.7, 1)
                end

                renderer:AlignText("right", "center")
                renderer:DrawText2d(x + 96, y, cost, color)
            end
        end
        renderer:AlignText("left", "center")
        renderer:DrawText2d(x, y, text, color)
    end

    local OnExit = function()
        self.mSelection:ShowCursor()
    end

    local OnSelection = function(selection, index, item)
        if not item then
            return
        end
        local def = SpecialDB[item]
        local mp = actor.mStats:Get("mp_now")

        if mp < def.mp_cost then
            return
        end

        -- Find associated event
        local event = nil
        if def.action == "slash" then
            event = CESlash
        elseif def.action == "steal" then
            event = CESteal
        end

        local targeter = self:CreateActionTargeter(def, selection, event)
        self.mStack:Push(targeter)
    end

    local state = BrowseListState:Create
    {
        stack = self.mStack,
        title = "Special",
        x = x,
        y = y,
        data = actor.mSpecial,
        OnExit = OnExit,
        OnRenderItem = OnRenderItem,
        OnSelection = OnSelection
    }
    self.mStack:Push(state)
end

function CombatChoiceState:OnMagicAction()

    local actor = self.mActor

    --  Create the selection box
    local x = self.mTextbox.mSize.left - 64
    local y = self.mTextbox.mSize.top
    self.mSelection:HideCursor()

    local OnRenderItem = function(self, renderer, x, y, item)
       local text = "--"
       local cost = "0"
       local canCast = false
       local mp = actor.mStats:Get("mp_now")

       local color = Vector.Create(1,1,1,1)
        if item then
            local def = SpellDB[item]
            print(tostring(item), tostring(def))
            text = def.name
            cost = string.format("%d", def.mp_cost)

            canCast = mp >= def.mp_cost

            if not canCast then
                color = Vector.Create(0.7, 0.7, 0.7, 1)
            end

            renderer:AlignText("right", "center")
            renderer:DrawText2d(x + 96, y, cost, color)
        end
        renderer:AlignText("left", "center")
        renderer:DrawText2d(x, y, text, color)
    end

    local OnExit = function()
        self.mCombatState:HideTip("")
        self.mSelection:ShowCursor()
    end

    local OnSelection = function(selection, index, item)
        if not item then
            return
        end
        print("spell selected:", item)
        local def = SpellDB[item]
        local mp = actor.mStats:Get("mp_now")

        if mp < def.mp_cost then
            return
        end

        local targeter = self:CreateActionTargeter(def, selection, CECastSpell)
        self.mStack:Push(targeter)
    end

    local state = BrowseListState:Create
    {
        stack = self.mStack,
        title = "MAGIC",
        x = x,
        y = y,
        data = actor.mMagic,
        OnExit = OnExit,
        OnRenderItem = OnRenderItem,
        OnSelection = OnSelection
    }
    self.mStack:Push(state)
end

function CombatChoiceState:CreateActionTargeter(def, browseState, combatEvent)

    local targetDef = def.target
    print(targetDef.type)

    browseState:Hide()
    self:Hide()

    local OnSelect = function(targets)
        self.mStack:Pop() -- target state
        self.mStack:Pop() -- spell browse state
        self.mStack:Pop() -- action state

        local queue = self.mCombatState.mEventQueue
        local event = combatEvent:Create(self.mCombatState,
                                        self.mActor,
                                        def,
                                        targets)
        local tp = event:TimePoints(queue)
        queue:Add(event, tp)

    end

    local OnExit = function()
        browseState:Show()
        self:Show()
    end

    return CombatTargetState:Create(self.mCombatState,
    {
        targetType = targetDef.type,
        defaultSelector = CombatSelector[targetDef.selector],
        switchSides = targetDef.switch_sides,
        OnSelect = OnSelect,
        OnExit = OnExit
    })
end

function CombatChoiceState:OnItemAction()

        -- 1. Get the filtered item list
        local filter = function(def)
            return def.type == "useable"
        end
        local filteredItems = gWorld:FilterItems(filter)


        -- 2. Create the selection box
        local x = self.mTextbox.mSize.left - 64
        local y = self.mTextbox.mSize.top
        self.mSelection:HideCursor()

        local OnFocus = function(item)
            local text = ""
            if item then
                 local def = ItemDB[item.id]
                 text = def.description
            end
            self.mCombatState:ShowTip(text)
        end

        local OnExit = function()
            self.mCombatState:HideTip("")
            self.mSelection:ShowCursor()
        end

        local OnRenderItem = function(self, renderer, x, y, item)
           local text = "--"
            if item then
                local def = ItemDB[item.id]
                text = def.name
                if item.count > 1 then
                    text = string.format("%s x%00d", def.name, item.count)
                end
            end
            renderer:DrawText2d(x, y, text)
        end

        local OnSelection = function(selection, index, item)
            if not item then
                return
            end
            local def = ItemDB[item.id]
            --print("ITEM DATA>>>>>>>>", item.id, def)
            local targeter = self:CreateItemTargeter(def, selection)
            self.mStack:Push(targeter)
        end

        local state = BrowseListState:Create
        {
            stack = self.mStack,
            title = "ITEMS",
            x = x,
            y = y,
            data = filteredItems,
            OnExit = OnExit,
            OnRenderItem = OnRenderItem,
            OnFocus = OnFocus,
            OnSelection = OnSelection,
        }
        self.mStack:Push(state)

end

function CombatChoiceState:CreateItemTargeter(def, browseState)

    local targetDef = def.use.target

    self.mCombatState:ShowTip(def.use.hint)
    browseState:Hide()
    self:Hide()

    local OnSelect = function(targets)
        self.mStack:Pop() -- target state
        self.mStack:Pop() -- item box state
        self.mStack:Pop() -- action state

        local queue = self.mCombatState.mEventQueue
        local event = CEUseItem:Create(self.mCombatState,
                                        self.mActor,
                                        def,
                                        targets)
        local tp = event:TimePoints(queue)
        queue:Add(event, tp)

    end

    local OnExit = function()
        browseState:Show()
        self:Show()
    end

    return CombatTargetState:Create(self.mCombatState,
    {
        targetType = targetDef.type,
        defaultSelector = CombatSelector[targetDef.selector],
        switchSides = targetDef.switch_sides,
        OnSelect = OnSelect,
        OnExit = OnExit
    })

end

function CombatChoiceState:TakeAction(id, targets)
    self.mStack:Pop() -- select state
    self.mStack:Pop() -- action state

    local queue = self.mCombatState.mEventQueue

    if id == "attack" then
        print("Entered attack state")
        local attack = CEAttack:Create(self.mCombatState,
                                       self.mActor,
                                       {player = true},
                                       targets)
        local speed = self.mActor.mStats:Get("speed")
        local tp = queue:SpeedToTimePoints(speed)
        queue:Add(attack, tp)



    end

end

function CombatChoiceState:Enter()
    self.mCombatState.mSelectedActor = self.mActor
end

function CombatChoiceState:Exit()
    self.mCombatState.mSelectedActor = nil
    self.mTextbox:Exit()
end


function CombatChoiceState:Update(dt)

    self.mTextbox:Update(dt)


    -- Make the selection cursor bounce
    self.mTime = self.mTime + dt
    local bounce = self.mMarkPos + Vector.Create(0, math.sin(self.mTime * 5))
    self.mMarker:SetPosition(bounce)

end

function CombatChoiceState:Render(renderer)

    if self.mHide then
        return
    end

    self.mTextbox:Render(renderer)

    self:SetArrowPosition()
    if self.mSelection:CanScrollUp() then
        renderer:DrawSprite(self.mUpArrow)
    end
    if self.mSelection:CanScrollDown() then
        renderer:DrawSprite(self.mDownArrow)
    end

    renderer:DrawSprite(self.mMarker)
end

function CombatChoiceState:HandleInput()
    self.mSelection:HandleInput()
end

