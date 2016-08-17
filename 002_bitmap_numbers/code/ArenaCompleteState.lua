
ArenaCompleteState = {}
ArenaCompleteState.__index = ArenaCompleteState
function ArenaCompleteState:Create()
    local this = {}

    setmetatable(this, self)
    return this
end

function ArenaCompleteState:Enter()
end

function ArenaCompleteState:Exit()
end

function ArenaCompleteState:Update(dt)
end

function ArenaCompleteState:Render(renderer)
    renderer:DrawRect2d(System.ScreenTopLeft(),
                        System.ScreenBottomRight(),
                        Vector.Create(0,0,0,1))


    CaptionStyles["title"]:Render(renderer,
        "You win!")
    CaptionStyles["subtitle"]:Render(renderer,
        "Champion of the Arena.")
end

function ArenaCompleteState:HandleInput()

end