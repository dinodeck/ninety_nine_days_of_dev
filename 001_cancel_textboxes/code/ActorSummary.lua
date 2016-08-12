ActorSummary = {}
ActorSummary.__index = ActorSummary
function ActorSummary:Create(actor, params)
    params = params or {}

    local this =
    {
        mX = 0,
        mY = 0,
        mWidth = 340, -- width of entire box
        mActor = actor,
        mHPBar = ProgressBar:Create
        {
            value = actor.mStats:Get("hp_now"),
            maximum = actor.mStats:Get("hp_max"),
            background = Texture.Find("hpbackground.png"),
            foreground = Texture.Find("hpforeground.png"),
        },
        mMPBar = ProgressBar:Create
        {
            value = actor.mStats:Get("mp_now"),
            maximum = actor.mStats:Get("mp_max"),
            background = Texture.Find("mpbackground.png"),
            foreground = Texture.Find("mpforeground.png"),
        },
        mAvatarTextPad = 14,
        mLabelRightPad = 15,
        mLabelValuePad = 8,
        mVerticalPad = 18,
        mShowXP = params.showXP
    }

    if this.mShowXP then
        this.mXPBar = ProgressBar:Create
        {
            value = actor.mXP,
            maximum = actor.mNextLevelXP,
            background = Texture.Find("xpbackground.png"),
            foreground = Texture.Find("xpforeground.png"),
        }
    end

    setmetatable(this, self)
    this:SetPosition(this.mX, this.mY)
    return this
end

function ActorSummary:SetPosition(x, y)
    self.mX = x
    self.mY = y

    if self.mShowXP then
        local boxRight = self.mX + self.mWidth
        local barX = boxRight - self.mXPBar.mHalfWidth
        local barY = self.mY - 44
        self.mXPBar:SetPosition(barX, barY)
    end

    -- HP & MP
    local avatarW = self.mActor.mPortraitTexture:GetWidth()
    local barX = self.mX + avatarW + self.mAvatarTextPad
    barX = barX + self.mLabelRightPad + self.mLabelValuePad
    barX = barX + self.mMPBar.mHalfWidth

    self.mMPBar:SetPosition(barX, self.mY - 72)
    self.mHPBar:SetPosition(barX, self.mY - 54)
end

function ActorSummary:GetCursorPosition()
    return Vector.Create(self.mX, self.mY - 40)
end

function ActorSummary:Render(renderer)

    local actor = self.mActor

    --
    -- Position avatar image from top left
    --
    local avatar = actor.mPortrait
    local avatarW = actor.mPortraitTexture:GetWidth()
    local avatarH = actor.mPortraitTexture:GetHeight()
    local avatarX = self.mX + avatarW / 2
    local avatarY = self.mY - avatarH / 2

    avatar:SetPosition(avatarX, avatarY)
    renderer:DrawSprite(avatar)

    --
    -- Position basic stats to the left of the
    -- avatar
    --
    renderer:AlignText("left", "top")


    local textPadY = 2
    local textX = avatarX + avatarW / 2 + self.mAvatarTextPad
    local textY = self.mY - textPadY
    renderer:ScaleText(1.6, 1.6)
    renderer:DrawText2d(textX, textY, actor.mName)

    --
    -- Draw LVL, HP and MP labels
    --
    renderer:AlignText("right", "top")
    renderer:ScaleText(1.22, 1.22)
    textX = textX + self.mLabelRightPad
    textY = textY - 20
    local statsStartY = textY
    renderer:DrawText2d(textX, textY, "LV")
    textY = textY - self.mVerticalPad
    renderer:DrawText2d(textX, textY, "HP")
    textY = textY - self.mVerticalPad
    renderer:DrawText2d(textX, textY, "MP")
    --
    -- Fill in the values
    --
    local textY = statsStartY
    local textX = textX + self.mLabelValuePad
    renderer:AlignText("left", "top")
    local level = actor.mLevel
    local hp = actor.mStats:Get("hp_now")
    local maxHP = actor.mStats:Get("hp_max")
    local mp = actor.mStats:Get("mp_now")
    local maxMP = actor.mStats:Get("mp_max")

    local counter = "%d/%d"
    local hp = string.format(counter,
                             hp,
                             maxHP)
    local mp = string.format(counter,
                             mp,
                             maxMP)

    renderer:DrawText2d(textX, textY, level)
    textY = textY - self.mVerticalPad
    renderer:DrawText2d(textX, textY, hp)
    textY = textY - self.mVerticalPad
    renderer:DrawText2d(textX, textY, mp)

    --
    -- Next Level area
    --
    if self.mShowXP then
        self.mXPBar:Render(renderer)

        local boxRight = self.mX + self.mWidth
        local textY = statsStartY
        local left = boxRight - self.mXPBar.mHalfWidth * 2

        renderer:AlignText("left", "top")
        renderer:DrawText2d(left, textY, "Next Level")
    end

    --
    -- MP & HP bars
    --
    self.mHPBar:Render(renderer)
    self.mMPBar:Render(renderer)
end