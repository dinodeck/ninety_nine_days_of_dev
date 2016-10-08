SOP = {}

WaitEvent = {}
WaitEvent.__index = WaitEvent
function WaitEvent:Create(seconds)
    local this =
    {
        mSeconds = seconds,
    }
    setmetatable(this, self)
    return this
end

function WaitEvent:Update(dt)
    self.mSeconds = self.mSeconds - dt
end

function WaitEvent:IsBlocking()
    return true
end

function WaitEvent:IsFinished()
    return self.mSeconds <= 0
end

function WaitEvent:Render() end

TweenEvent = {}
TweenEvent.__index = TweenEvent
function TweenEvent:Create(tween, target, ApplyFunc)
    local this =
    {
        mTween = tween,
        mTarget = target,
        mApplyFunc = ApplyFunc
    }
    setmetatable(this, self)
    return this
end

function TweenEvent:Update(dt, storyboard)
    self.mTween:Update(dt)
    self.mApplyFunc(self.mTarget, self.mTween:Value())
end

function TweenEvent:Render() end
function TweenEvent:IsFinished()
    return self.mTween:IsFinished()
end
function TweenEvent:IsBlocking()
    return true
end

BlockUntilEvent = {}
BlockUntilEvent.__index = BlockUntilEvent
function BlockUntilEvent:Create(UntilFunc)
    local this =
    {
        mUntilFunc = UntilFunc,
    }
    setmetatable(this, self)
    return this
end

function BlockUntilEvent:Update(dt) end
function BlockUntilEvent:Render() end

function BlockUntilEvent:IsBlocking()
    return not self.mUntilFunc()
end

function BlockUntilEvent:IsFinished()
    return not self:IsBlocking()
end

AnimateEvent = {}
AnimateEvent.__index = AnimateEvent
function AnimateEvent:Create(entity, anim)
    local this =
    {
        mEntity = entity,
        mAnimation = anim,
    }
    setmetatable(this, self)
    return this
end

function AnimateEvent:Update(dt)
    self.mAnimation:Update(dt)
    local frame = self.mAnimation:Frame()
    self.mEntity:SetFrame(frame)
end

function AnimateEvent:Render() end

function AnimateEvent:IsBlocking()
    return true
end

function AnimateEvent:IsFinished()
    return self.mAnimation:IsFinished()
end

TimedTextboxEvent = {}
TimedTextboxEvent.__index = TimedTextboxEvent
function TimedTextboxEvent:Create(box, time)
    local this =
    {
        mTextbox = box,
        mCountDown = time
    }
    setmetatable(this, self)
    return this
end

function TimedTextboxEvent:Update(dt, storyboard)
    self.mCountDown = self.mCountDown - dt
    if self.mCountDown <= 0 then
        self.mTextbox:OnClick()
    end
end
function TimedTextboxEvent:Render() end

function TimedTextboxEvent:IsBlocking()
    return not self.mTextbox:IsDead()
end

function TimedTextboxEvent:IsFinished()
    return self.mTextbox:IsDead()
end


function SOP.Wait(seconds)
    return function()
        return WaitEvent:Create(seconds)
    end
end

local EmptyEvent = WaitEvent:Create(0)

function SOP.BlackScreen(id, alpha)

    id = id or "blackscreen"
    local black = Vector.Create(0, 0, 0, alpha or 1)

    return function(storyboard)
        local screen = ScreenState:Create(black)
        storyboard:PushState(id, screen)
        return EmptyEvent
    end
end

function SOP.Play(soundName, name, volume)
    name = name or soundName
    volume = volume or 1
    return function(storyboard)
        local id = Sound.Play(soundName)
        Sound.SetVolume(id, volume)
        storyboard:Sound(name, id)
        return EmptyEvent
    end
end

function SOP.Stop(name)
    return function(storyboard)
        storyboard:StopSound(name)
        return EmptyEvent
    end
end


function SOP.FadeOutChar(mapId, npcId, duration)

    duration = duration or 1

    return function(storyboard)

        local map = GetMapRef(storyboard, mapId)
        local npc = map.mNPCbyId[npcId]
        if npcId == "hero" then
           npc = storyboard.mStates[mapId].mHero
        end

        return TweenEvent:Create(
            Tween:Create(1, 0, duration),
            npc.mEntity.mSprite,
            function(target, value)
                local c = target:GetColor()
                c:SetW(value)
                target:SetColor(c)
            end)
    end
end

function SOP.WriteTile(mapId, writeParams)
    return function(storyboard)
        local map = GetMapRef(storyboard, mapId)
        map:WriteTile(writeParams)
        return EmptyEvent
    end
end

function SOP.MoveCamToTile(stateId, tileX, tileY, duration)

    duration = duration or 1

    return function(storyboard)

        local state = storyboard.mStates[stateId]
        state:SetFollowCam(false)
        local startX = state.mManualCamX
        local startY = state.mManualCamY
        local endX, endY = state.mMap:GetTileFoot(tileX, tileY)
        local xDistance = endX - startX
        local yDistance = endY - startY


        return TweenEvent:Create(
            Tween:Create(0, 1, duration, Tween.EaseOutQuad),
            state,
            function(target, value)
                local dX = startX + (xDistance * value)
                local dY = startY + (yDistance * value)

                state.mManualCamX = dX
                state.mManualCamY = dY
            end)
    end
end

function SOP.FadeSound(name, start, finish, duration)
    return function(storyboard)

        local id = storyboard.mPlayingSounds[name]
        assert(id)
        return TweenEvent:Create(
            Tween:Create(start, finish, duration),
            id,
            function(target, value)
                Sound.SetVolume(target, value)
            end)
    end
end

local function FadeScreen(id, duration, start, finish)

    local duration = duration or 3

    return function(storyboard)

        local target = storyboard.mSubStack:Top()
        if id then
            target = storyboard.mStates[id]
        end
        assert(target and target.mColor)

        return TweenEvent:Create(
            Tween:Create(start, finish, duration),
            target,
            function(target, value)
                target.mColor:SetW(value)
            end)
    end
end

function SOP.FadeInScreen(id, duration)
    return FadeScreen(id, duration, 0, 1)
end

function SOP.FadeOutScreen(id, duration)
    return FadeScreen(id, duration, 1, 0)
end

function SOP.Caption(id, style, text)

    return function(storyboard)
        local style = ShallowClone(CaptionStyles[style])
        local caption = CaptionState:Create(style, text)
        storyboard:PushState(id, caption)

        return TweenEvent:Create(
                Tween:Create(0, 1, style.duration),
                style,
                style.ApplyFunc)

    end

end

function SOP.FadeOutCaption(id, duration)
    return function(storyboard)
        local target = storyboard.mSubStack:Top()
        if id then
            target = storyboard.mStates[id]
        end
        print(id, target)
        local style = target.mStyle
        duration = duration or style.duration

        return TweenEvent:Create(
            Tween:Create(1, 0, duration),
            style,
            style.ApplyFunc
        )
    end
end

function SOP.NoBlock(f)
    return function(...)
        local event = f(...)
        event.IsBlocking = function()
            return false
        end
        return event
    end
end

function SOP.KillState(id)
    return function(storyboard)
        storyboard:RemoveState(id)
        return EmptyEvent
    end
end

function SOP.Scene(params)
    return function(storyboard)
        local id = params.name or params.map
        local map = MapDB[params.map]()
        local focus = Vector.Create(params.focusX or 1,
                                    params.focusY or 1,
                                    params.focusZ or 1)
        local state = ExploreState:Create(nil, map, focus)
        if params.hideHero then
            state:HideHero()
        end
        storyboard:PushState(id, state)

        -- Allows the following instruction to be carried out
        -- on the same frame.
        return SOP.NoBlock(SOP.Wait(0.1))()
    end
end


function GetMapRef(storyboard, stateId)
    local exploreState = storyboard.mStates[stateId]
    assert(exploreState and exploreState.mMap)
    return exploreState.mMap
end

function SOP.ReplaceScene(name, params)
    return function(storyboard)
        gGame.World.mParty:DebugPrintParty()
        local state = storyboard.mStates[name]
        print("Replace scene tried to get", name, "got", state.mId)

        -- Give the state an updated name
        local id = params.name or params.map
        storyboard.mStates[name] = nil
        storyboard.mStates[id] = state

        local mapDef = MapDB[params.map](gGame.World.mGameState)
        state.mMap =  Map:Create(mapDef)
        state.mMapDef = mapDef

        print("after map created")
        gGame.World.mParty:DebugPrintParty()

        state.mMap:GotoTile(params.focusX, params.focusY)
        state.mHero = Character:Create(gCharacters.hero, state.mMap)
        state.mHero.mEntity:SetTilePos(
            params.focusX,
            params.focusY,
            params.focusZ or 1,
            state.mMap)
        state:SetFollowCam(true, state.mHero)

        if params.hideHero then
            state:HideHero()
        else
            state:ShowHero()
        end

        gGame.World.mParty:DebugPrintParty()
        return SOP.NoBlock(SOP.Wait(0.1))()
    end
end

function SOP.ReplaceState(current, new)
    return function(storyboard)
        print("being asked to replace a state")
        local stack = storyboard.mStack

        for k, v in ipairs(stack.mStates) do
            if v == current then
                stack.mStates[k]:Exit()
                stack.mStates[k] = new
                stack.mStates[k]:Enter()
                return EmptyEvent
            end
        end

        print("Failed to replace state in storyboard.")
        assert(false) -- failed to replace
    end
end

function SOP.RemoveState(state)
    return function(storyboard)
        print("being asked to remove a state")
        local stack = storyboard.mStack

        for i = #stack.mStates, 1, -1 do
            local v = stack.mStates[i]
            if v == state then
                v:Exit()
                table.remove(stack.mStates, i)
                break
            end
        end
        return EmptyEvent
    end
end

function SOP.Say(mapId, npcId, text, time, params)

    time = time or 1
    params = params or {textScale = 0.8}

    return function(storyboard)
        local map = GetMapRef(storyboard, mapId)
        local npc = map.mNPCbyId[npcId]
        if npcId == "hero" then
           npc = storyboard.mStates[mapId].mHero
        end
        local pos = npc.mEntity.mSprite:GetPosition()
        storyboard.mStack:PushFit(
            gRenderer,
            -map.mCamX + pos:X(), -map.mCamY + pos:Y() + 32,
            text, -1, params)
        local box = storyboard.mStack:Top()
        return TimedTextboxEvent:Create(box, time)
    end
end

function SOP.RunAction(actionId, actionParams, paramOps)

    local action = Actions[actionId]
    assert(action)

    return function(storyboard)

        --
        --  Look up refences required by action.
        --
        paramOps = paramOps or {}

        Apply(paramOps, print, pairs)
        for k, op in pairs(paramOps) do
            if op then
                print(k, op)
                actionParams[k] = op(storyboard, actionParams[k])
            end
        end

        local actionFunc = action(unpack(actionParams))
        actionFunc()

        return EmptyEvent
    end
end

function SOP.MoveNPC(id, mapId, path)
    return function(storyboard)
        local map = GetMapRef(storyboard, mapId)
        local npc = map.mNPCbyId[id]
        npc:FollowPath(path)
        return BlockUntilEvent:Create(
            function()
                return npc.mPathIndex > #npc.mPath
            end)
    end
end

function SOP.HandOff(mapId)
    return function(storyboard)
        print("trying to handoff to", mapId)
        local exploreState = storyboard.mStates[mapId]
        storyboard.mStack:Pop() -- remove storyboard from the top of the stack
        storyboard.mStack:Push(exploreState)
        exploreState.mStack = gGame.Stack
        return EmptyEvent
    end
end

function SOP.Function(func)
    return function(storyboard)
        func()
        return EmptyEvent
    end
end

function SOP.RunState(statemachine, id, params)
    return function(storyboard)
        statemachine:Change(id, params)
        return BlockUntilEvent:Create(
            function()
                return statemachine.mCurrent:IsFinished()
            end)
    end
end

function SOP.UpdateState(state, time)
    return function(storyboard)
        return TweenEvent:Create(
            Tween:Create(0, 1, time),
            state,
            function(target, value)
                target:Update(GetDeltaTime())
            end)
    end
end

function SOP.Animate(entity, params)
    return function(storyboard)
        local animation = Animation:Create(unpack(params))
        return AnimateEvent:Create(entity, animation)
    end
end
