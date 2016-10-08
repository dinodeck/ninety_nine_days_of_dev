GameOverState = {}
GameOverState.__index = GameOverState
function GameOverState:Create(stack, world, won)
    local this =
    {
        mWorld = world,
        mStack = stack,
        mWon = false,
    }

    if won == true then
        this.mWon = true
    end

    setmetatable(this, self)

    if not this.mWon then

        this.mShowContinue = Save:DoesExist()
        local data = {}
        if this.mShowContinue then
            table.insert(data, "Continue")
        end
        table.insert(data, "New Game")

        this.mMenu = Selection:Create
        {
            data = data,
            spacingY = 36,
            OnSelection = function(...) this:OnSelect(...) end,
        }
        this.mMenu:SetPosition(-this.mMenu:GetWidth(), 0)
    end

    return this
end

function GameOverState:Enter()
    CaptionStyles["title"].color:SetW(1)
    if self.mWon then
        CaptionStyles["subtitle"].color:SetW(1)
    end
end
function GameOverState:Exit() end
function GameOverState:Update(dt) end

function GameOverState:HandleInput()
    if not self.mWon then
        self.mMenu:HandleInput()
    end
end

function GameOverState:Render(renderer)

    renderer:DrawRect2d(System.ScreenTopLeft(),
                        System.ScreenBottomRight(),
                        Vector.Create(0,0,0,1))

    if self.mWon then
        CaptionStyles["title"]:Render(renderer,
        "The End")

        CaptionStyles["subtitle"]:Render(renderer,
        "Want to find out what happens next? Write it!")
    else
        CaptionStyles["title"]:Render(renderer,
            "Game Over")

        renderer:AlignText("left", "center")
        self.mMenu:Render(renderer)
    end
end

function GameOverState:OnSelect(index, data)

    -- reset text
    gRenderer:SetFont(CaptionStyles["default"].font)
    gRenderer:ScaleText(CaptionStyles["default"].scale)

    if not self.mShowContinue then
        index = index + 1
    end

    if index == 1 then
        Save:Load()
    elseif index == 2 then
        local storyboard = SetupNewGame()
        gStack:Push(storyboard)
        storyboard:Update(0)
    end
end


