ProgressBar = {}
ProgressBar.__index = ProgressBar
function ProgressBar:Create(params)
    params = params or {}

    local this =
    {
        mX           = params.x or 0,
        mY           = params.y or 0,
        mBackground  = Sprite.Create(),
        mForeground  = Sprite.Create(),
        mValue       = params.value or 0,
        mMaximum     = params.maximum or 1,
    }

    this.mBackground:SetTexture(params.background)
    this.mForeground:SetTexture(params.foreground)

    -- Get UV positions in texture atlas
    -- A table with name fields: left, top, right, bottom
    this.mHalfWidth = params.foreground:GetWidth() / 2

    setmetatable(this, self)
    this:SetValue(this.mValue)
    return this
end

function ProgressBar:SetValue(value, max)
    self.mMaximum = max or self.mMaximum
    self:SetNormalValue(value / self.mMaximum)
end

function ProgressBar:SetNormalValue(value)

    self.mForeground:SetUVs(
        0,                      -- left
        1,                      -- top
        value,                  -- right
        0)                      -- bottom

    local position = Vector.Create(
        self.mX -( self.mHalfWidth * (1 - value)),
        self.mY)

    self.mForeground:SetPosition(position)
end

function ProgressBar:SetPosition(x, y)
    self.mX = x
    self.mY = y
    local position = Vector.Create(self.mX, self.mY)
    self.mBackground:SetPosition(position)
    self.mForeground:SetPosition(position)
    -- Make sure the foreground position is set correctly.
    self:SetValue(self.mValue)
end

function ProgressBar:GetPosition()
    return Vector.Create(self.mX, self.mY)
end

function ProgressBar:Render(renderer)
    renderer:DrawSprite(self.mBackground)
    renderer:DrawSprite(self.mForeground)
end

