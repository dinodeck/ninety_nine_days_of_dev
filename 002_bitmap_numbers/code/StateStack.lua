
StateStack = {}
StateStack.__index = StateStack
function StateStack:Create()
    local this =
    {
        mStates = {}
    }

    setmetatable(this, self)
    return this
end

function StateStack:Push(state)
    table.insert(self.mStates, state)
    state:Enter()
end

function StateStack:Pop()

    local top = self.mStates[#self.mStates]
    print("pop called", top)
    table.remove(self.mStates)
    top:Exit()
    return top
end

function StateStack:Top()
    return self.mStates[#self.mStates]
end

function StateStack:Update(dt)
    -- update them and check input
    for k = #self.mStates, 1, -1 do
        local v = self.mStates[k]
        local continue = v:Update(dt)
        if not continue then
            break
        end
    end

    local top = self.mStates[#self.mStates]

    if not top then
        return
    end

    top:HandleInput()
end

function StateStack:Render(renderer)
    for _, v in ipairs(self.mStates) do
        v:Render(renderer)
    end
end


function StateStack:PushFix(renderer, x, y, width, height, text, params)

    params = params or {}
    local avatar = params.avatar
    local title = params.title
    local choices = params.choices

    local padding = 10
    local titlePadY = params.titlePadY or 10
    local textScale = params.textScale or 1.5
    local panelTileSize = 3

    --
    -- This a fixed dialog so the wrapping value is calculated here.
    --
    local wrap = width - padding
    local boundsTop = padding
    local boundsLeft = padding
    local boundsBottom = padding

    local children = {}

    if avatar then
        boundsLeft = avatar:GetWidth() + padding * 2
        wrap = width - (boundsLeft) - padding
        local sprite = Sprite.Create()
        sprite:SetTexture(avatar)
        table.insert(children,
        {
            type = "sprite",
            sprite = sprite,
            x = avatar:GetWidth() / 2 + padding,
            y = -avatar:GetHeight() / 2
        })
    end

    local selectionMenu = nil
    if choices then
        -- options and callback
        selectionMenu = Selection:Create
        {
            data = choices.options,
            OnSelection = choices.OnSelection,
            displayRows = #choices.options,
            columns = 1,
        }
        boundsBottom = boundsBottom - padding*0.5
    end

    if title then
        -- adjust the top
        local size = renderer:MeasureText(title, wrap)
        boundsTop = size:Y() + padding * 2 + titlePadY

        table.insert(children,
        {
            type = "text",
            text = title,
            x = 0,
            y = size:Y() + padding + titlePadY
        })
    end

    renderer:ScaleText(textScale)

    --
    -- Section text into box size chunks.
    --
    local faceHeight = math.ceil(renderer:MeasureText(text):Y())
    local start, finish = gRenderer:NextLine(text, 1, wrap)

    local boundsHeight = height - (boundsTop + boundsBottom)
    local currentHeight = faceHeight

    local chunks = {{string.sub(text, start, finish)}}
    while finish < #text do
        start, finish = gRenderer:NextLine(text, finish, wrap)

        -- If we're going to overflow
        if (currentHeight + faceHeight) > boundsHeight then
            -- make a new entry
            currentHeight = 0
            table.insert(chunks, {string.sub(text, start, finish)})
        else
            table.insert(chunks[#chunks], string.sub(text, start, finish))
        end
        currentHeight = currentHeight + faceHeight
    end

    -- Make each textbox be represented by one string.
    for k, v in ipairs(chunks) do
        chunks[k] = table.concat(v)
    end

    local textbox = Textbox:Create
    {
        text = chunks,
        textScale = textScale,
        size =
        {
            left    = x - width / 2,
            right   = x + width / 2,
            top     = y + height / 2,
            bottom  = y - height / 2
        },
        textbounds =
        {
            left = boundsLeft,
            right = -padding,
            top = -boundsTop,
            bottom = boundsBottom
        },
        panelArgs =
        {
            texture = Texture.Find("gradient_panel.png"),
            size = panelTileSize,
        },
        children = children,
        wrap = wrap,
        selectionMenu = selectionMenu,
        OnFinish = params.OnFinish,
        stack = self,
    }
    table.insert(self.mStates, textbox)
end

function StateStack:PushFit(renderer, x, y, text, wrap, params)

    local params = params or {}
    local choices = params.choices
    local title = params.title
    local avatar = params.avatar

    local padding = 10
    local titlePadY = params.titlePadY or 10
    local panelTileSize = 3
    local textScale = params.textScale or 1.5

    renderer:ScaleText(textScale, textScale)

    local size = renderer:MeasureText(text, wrap)
    local width = size:X() + padding * 2
    local height = size:Y() + padding * 2

    if choices then
        -- options and callback
        local selectionMenu = Selection:Create
        {
            data = choices.options,
            displayRows = #choices.options,
            columns = 1,
        }
        height = height + selectionMenu:GetHeight() + padding
        width = math.max(width, selectionMenu:GetWidth() + padding * 2)
    end

    if title then
        local size = renderer:MeasureText(title, wrap)
        height = height + size:Y() + titlePadY
        width = math.max(width, size:X() + padding * 2)
    end

    if avatar then
        local avatarWidth = avatar:GetWidth()
        local avatarHeight = avatar:GetHeight()
        width = width + avatarWidth + padding
        height = math.max(height, avatarHeight + padding)
    end

    return self:PushFix(renderer, x, y, width, height, text, params)
end
