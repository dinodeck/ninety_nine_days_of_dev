CaptionState = {}
CaptionState.__index = CaptionState
function CaptionState:Create(style, text)
    params = params or {}
    local this =
    {
        mStyle = style,
        mText = text
    }

    setmetatable(this, self)
    return this
end

function CaptionState:Enter() end
function CaptionState:Exit() end
function CaptionState:HandleInput() end

function CaptionState:Update(dt)
    return true
end

function CaptionState:Render(renderer)
    self.mStyle:Render(renderer, self.mText)
end