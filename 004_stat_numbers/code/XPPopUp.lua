XPPopUp = {}
XPPopUp.__index = XPPopUp
function XPPopUp:Create(text, x, y, color)
    local this =
    {
        mText = text,
        mX = x or 0,
        mY = y or 0,
        mTextColor = color or Vector.Create(1, 1, 0, 1),
        mTween = nil,
        mFadeTime = 0.25,
        mPane = Panel:Create
        {
            texture = Texture.Find("gradient_panel.png"),
            size = 3,
        },
        mDisplayTime = 0,
    }

    setmetatable(this, self)
    return this
end

function XPPopUp:SetPosition(x, y)
    self.mX = x
    self.mY = y
end

function XPPopUp:TurnOn()
    self.mTween = Tween:Create(0, 1, self.mFadeTime)
end

function XPPopUp:TurnOff()
    local current = self.mTween:Value()
    self.mTween = Tween:Create(current, 0, current*self.mFadeTime)
end

function XPPopUp:IsTurningOff()
    return self.mTween:FinishValue() == 0
end

function XPPopUp:Update(dt)
    self.mTween:Update(dt)

    if self.mTween:IsFinished() then
        self.mDisplayTime = math.min(5, self.mDisplayTime + dt)
    end
end

function XPPopUp:IsFinished()
    return self.mTween:Value() == 0 and self.mTween:FinishValue() == 0
end

function XPPopUp:Render(renderer)

    local alpha = self.mTween:Value()
    self.mTextColor:SetW(alpha)
    self.mPane:SetColor(Vector.Create(1,1,1,alpha))

    renderer:AlignText("center", "center")
    renderer:ScaleText(1.4, 1.4)

    local x = self.mX
    local y = self.mY
    local textSize = renderer:MeasureText(self.mText)

    self.mPane:CenterPosition(x, y, textSize:X() + 24, textSize:Y() + 12)
    self.mPane:Render(renderer)

    renderer:DrawText2d(x, y, self.mText, self.mTextColor)
end