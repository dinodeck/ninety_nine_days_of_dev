
TitleScreenState = {}
TitleScreenState.__index = TitleScreenState
function TitleScreenState:Create(stack, storyboard)
    local this
    this =
    {
        mTitleBanner = Sprite.Create(),
        mStack = stack,
        mStoryboard = storyboard,
    }

    this.mTitleBanner:SetTexture(Texture.Find("title_screen.png"))
    this.mTitleBanner:SetPosition(0, 100)

    this.mShowContinue = Save:DoesExist()
    print("Save exists?", Save:DoesExist())
    local data = {}
    if this.mShowContinue then
        table.insert(data, "Continue")
    end
    table.insert(data, "Play")
    table.insert(data, "Exit")

    this.mMenu = Selection:Create
    {
        data = data,
        spacingY = 24,
        OnSelection = function(index)
            this:OnSelection(index)
        end
    }

    -- Code to center the menu
    this.mMenu.mCursorWidth = 50
    this.mMenu.mX = -this.mMenu:GetWidth()/2 - this.mMenu.mCursorWidth
    this.mMenu.mY = -50

    setmetatable(this, self)
    return this
end

function TitleScreenState:Enter()
end

function TitleScreenState:Exit()
end

function TitleScreenState:Update(dt)
end

function TitleScreenState:OnSelection(index)

    if not self.mShowContinue then
        index = index + 1
    end

    if index == 1 then
        Save:Load()
    elseif index == 2 then
        self.mStack:Pop()
        self.mStack:Push(self.mStoryboard)
        -- We're in the update function, so update the storyboard
        -- before it gets rendered.
        self.mStoryboard:Update(0)
    elseif index == 3 then
        System.Exit()
    end
end

function TitleScreenState:Render(renderer)

    renderer:DrawRect2d(
        -System.ScreenWidth()/2,
        -System.ScreenHeight()/2,
        System.ScreenWidth()/2,
        System.ScreenHeight()/2,
        Vector.Create(0, 0, 0, 1)
    )

    renderer:DrawSprite(self.mTitleBanner)
    renderer:AlignText("center", "center")
    renderer:ScaleText(1.2, 1.2)
    renderer:DrawText2d(0, 0, "A mini-rpg adventure.")
    renderer:ScaleText(1.2, 1.2)
    renderer:AlignText("left", "center")
    self.mMenu:Render(renderer)
end

function TitleScreenState:HandleInput()
    self.mMenu:HandleInput()
end