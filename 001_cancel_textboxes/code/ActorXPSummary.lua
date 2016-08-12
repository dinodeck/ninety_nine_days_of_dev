
ActorXPSummary = {}
ActorXPSummary.__index = ActorXPSummary
function ActorXPSummary:Create(actor, layout, layoutId)
    local this =
    {
        mActor = actor,
        mLayout = layout,
        mId = layoutId,

        mXPBar = ProgressBar:Create
        {
            value = actor.mXP,
            maximum = actor.mNextLevelXP,
            background = Texture.Find("xpbackground.png"),
            foreground = Texture.Find("xpforeground.png"),
        },
        mPopUpList = {},
        mPopUpDisplayTime = 1, -- secs
    }


    this.mAvatar = Sprite.Create()
    this.mAvatar:SetTexture(this.mActor.mPortraitTexture)
    local avatarScale = 0.8
    this.mAvatar:SetScale(avatarScale, avatarScale)
    this.mActorWidth = actor.mPortraitTexture:GetWidth() * avatarScale

    setmetatable(this, self)

    return this
end

function ActorXPSummary:Update(dt)

    local popup = self.mPopUpList[1]
    if popup == nil then
        --print("popup at 1 is nil")
        return
    end

    if popup:IsFinished() then
        print("Removed")
        table.remove(self.mPopUpList, 1)
        return
    end

    popup:Update(dt)

    if popup.mDisplayTime > self.mPopUpDisplayTime
    and #self.mPopUpList > 1 then
        popup:TurnOff()
    end

end

function ActorXPSummary:Render(renderer)

    renderer:ScaleText(1.25, 1.25)
    -- Potrait
    local left = self.mLayout:Left(self.mId)
    local midY = self.mLayout:MidY(self.mId)
    local avatarLeft = left + self.mActorWidth/2 + 6
    self.mAvatar:SetPosition(avatarLeft , midY)
    renderer:DrawSprite(self.mAvatar)

    -- Name
    local nameX = left + self.mActorWidth + 84
    local nameY = self.mLayout:Top(self.mId) - 12
    renderer:AlignText("right", "top")
    renderer:DrawText2d(nameX, nameY, self.mActor.mName)

    -- Level
    local strLevelLabel = "Level:"
    local strLevelValue = string.format("%d", self.mActor.mLevel)
    local levelY = nameY - 42
    renderer:DrawText2d(nameX, levelY, strLevelLabel)
    renderer:AlignText("left", "top")
    renderer:DrawText2d(nameX + 12, levelY, strLevelValue)

    -- XP
    renderer:AlignText("right", "top")
    local strXPLabel = "EXP:"
    local strXPValue = string.format("%d", self.mActor.mXP)
    local right = self.mLayout:Right(self.mId) - 18
    local rightLabel = right - 96
    renderer:DrawText2d(rightLabel, nameY, strXPLabel)
    renderer:DrawText2d(right, nameY, strXPValue)

    local barX = right - self.mXPBar.mHalfWidth


    self.mXPBar:SetPosition(barX, nameY - 24)
    self.mXPBar:SetValue(self.mActor.mXP, self.mActor.mNextLevelXP)
    self.mXPBar:Render(renderer)

    local strNextLevelLabel = "Next Level:"
    local strNextLevelValue = string.format("%d", self.mActor.mNextLevelXP)

    renderer:DrawText2d(rightLabel, levelY, strNextLevelLabel)
    renderer:DrawText2d(right, levelY, strNextLevelValue)

    local popup = self.mPopUpList[1]
    if popup == nil then
        return
    end
    popup:Render(renderer)
end

function ActorXPSummary:SetPosition(x, y)
    self.mX = x
    self.mY = y
end

function ActorXPSummary:AddPopUp(text, color)
    local x = self.mLayout:MidX(self.mId)
    local y = self.mLayout:MidY(self.mId)
    local popup = XPPopUp:Create(text, x, y, color)

    table.insert(self.mPopUpList, popup)
    popup:TurnOn()
    Apply(self.mPopUpList, print)
end

function ActorXPSummary:PopUpCount()
    return #self.mPopUpList
end

function ActorXPSummary:CancelPopUp()
    local popup = self.mPopUpList[1]
    if popup == nil or popup:IsTurningOff() then
        return
    end
    popup:TurnOff()
end