ScreenState = {}
ScreenState.__index = ScreenState
function ScreenState:Create(color)
    params = params or {}
    local this =
    {
        mColor = color or Vector.Create(0, 0, 0, 1),
    }

    setmetatable(this, self)
    return this
end

function ScreenState:Enter() end
function ScreenState:Exit() end
function ScreenState:HandleInput() end

function ScreenState:Update(dt)
    return true
end

function ScreenState:Render(renderer)
    renderer:DrawRect2d(
    -System.ScreenWidth()/2,
    System.ScreenHeight()/2,
    System.ScreenWidth()/2,
    -System.ScreenHeight()/2,
    self.mColor)
end