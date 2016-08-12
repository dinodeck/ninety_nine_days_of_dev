
Textbox = {}
Textbox.__index = Textbox
function Textbox:Create(params)

    params = params or {}

    if type(params.text) == "string" then
        params.text = {params.text}
    end

    local this =
    {
        -- mText = params.text, Removing this
        mChunks = params.text,
        mChunkIndex = 1,
        mContinueMark = Sprite.Create(),
        mTime = 0,
        mTextScale = params.textScale or 1,
        mPanel = Panel:Create(params.panelArgs),
        mSize = params.size,
        mBounds = params.textbounds,
        mAppearTween = Tween:Create(0, 1, 0.4, Tween.EaseOutCirc),
        mWrap = params.wrap or -1,
        mChildren = params.children or {},
        mSelectionMenu = params.selectionMenu,
        mStack = params.stack,
        mDoClickCallback = false,
        mOnFinish = params.OnFinish or function() end
    }

    this.mContinueMark:SetTexture(Texture.Find("continue_caret.png"))

    -- Calculate center point from mSize
    -- We can use this to scale.
    this.mX = (this.mSize.right + this.mSize.left) / 2
    this.mY = (this.mSize.top + this.mSize.bottom) / 2
    this.mWidth = this.mSize.right - this.mSize.left
    this.mHeight = this.mSize.top - this.mSize.bottom

    setmetatable(this, self)
    return this
end

function Textbox:Update(dt)
    self.mTime = self.mTime + dt
    self.mAppearTween:Update(dt)
    if self:IsDead() then
        self.mStack:Pop()
    end
    return true
end


function Textbox:HandleInput()

    if Keyboard.JustPressed(KEY_SPACE) then
        self:OnClick()
    elseif self.mSelectionMenu then
        self.mSelectionMenu:HandleInput()
    end

end

function Textbox:Enter()

end

function Textbox:Exit()
    if self.mDoClickCallback then
        self.mSelectionMenu:OnClick()
    end

    if self.mOnFinish then
        self.mOnFinish()
    end
end

function Textbox:OnClick()

    if self.mSelectionMenu then
        self.mDoClickCallback = true
    end

    if self.mChunkIndex >= #self.mChunks then
        --
        -- If the dialog is appearing or dissapearing
        -- ignore interaction
        --
        if not (self.mAppearTween:IsFinished()
           and self.mAppearTween:Value() == 1) then
            return
        end
        self.mAppearTween = Tween:Create(1, 0, 0.2, Tween.EaseInCirc)
    else
        self.mChunkIndex = self.mChunkIndex + 1
    end
end

function Textbox:IsDead()
    return self.mAppearTween:IsFinished()
            and self.mAppearTween:Value() == 0
end

function Textbox:Render(renderer)
    local scale = self.mAppearTween:Value()

    renderer:ScaleText(self.mTextScale * scale)
    renderer:AlignText("left", "top")
    -- Draw the scale panel
    self.mPanel:CenterPosition(
        self.mX,
        self.mY,
        self.mWidth * scale,
        self.mHeight * scale)

    self.mPanel:Render(renderer)

    local left = self.mX - (self.mWidth/2 * scale)
    local textLeft = left + (self.mBounds.left * scale)
    local top = self.mY + (self.mHeight/2 * scale)
    local textTop = top + (self.mBounds.top * scale)
    local bottom = self.mY - (self.mHeight/2 * scale)

    renderer:DrawText2d(
        textLeft,
        textTop,
        self.mChunks[self.mChunkIndex],
        Vector.Create(1,1,1,1),
        self.mWrap * scale)

    if self.mSelectionMenu then
        renderer:AlignText("left", "center")
        local menuX = textLeft
        local menuY = bottom + self.mSelectionMenu:GetHeight()
        menuY = menuY + self.mBounds.bottom
        self.mSelectionMenu.mX = menuX
        self.mSelectionMenu.mY = menuY
        self.mSelectionMenu.mScale = scale
        self.mSelectionMenu:Render(renderer)
    end

    if self.mChunkIndex < #self.mChunks then
        -- There are more chunks t come.
        local offset = 12 + math.floor(math.sin(self.mTime*10)) * scale
        self.mContinueMark:SetScale(scale, scale)
        self.mContinueMark:SetPosition(self.mX, bottom + offset)
        renderer:DrawSprite(self.mContinueMark)
    end

    for k, v in ipairs(self.mChildren) do
        if v.type == "text" then
            renderer:DrawText2d(
                textLeft + (v.x * scale),
                textTop + (v.y * scale),
                v.text,
                Vector.Create(1,1,1,1)
            )
        elseif v.type == "sprite" then
            v.sprite:SetPosition(
                left + (v.x * scale),
                top + (v.y * scale))
            v.sprite:SetScale(scale, scale)
            renderer:DrawSprite(v.sprite)
        end
    end
end
