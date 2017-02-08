Scrollbar = {}
Scrollbar.__index = Scrollbar
function Scrollbar:Create(texture, height)
    local this =
    {
        mX = 0,
        mY = 0,
        mHeight = height or 300,
        mTexture = texture,
        mValue = 0,

        mUpSprite = Sprite.Create(),
        mDownSprite = Sprite.Create(),
        mBackgroundSprite = Sprite.Create(),
        mCaretSprite = Sprite.Create(),

        mCaretSize = 1,
    }

    local texWidth = texture:GetWidth()
    local texHeight = texture:GetHeight()

    this.mUpSprite:SetTexture(texture)
    this.mDownSprite:SetTexture(texture)
    this.mBackgroundSprite:SetTexture(texture)
    this.mCaretSprite:SetTexture(texture)
    -- There are expected to be 4 equally sized pieces
    -- that make up a scrollbar.
    this.mTileHeight = texHeight/4
    this.mUVs = GenerateUVs(texWidth, this.mTileHeight, texture)
    this.mUpSprite:SetUVs(unpack(this.mUVs[1]))
    this.mCaretSprite:SetUVs(unpack(this.mUVs[2]))
    this.mBackgroundSprite:SetUVs(unpack(this.mUVs[3]))
    this.mDownSprite:SetUVs(unpack(this.mUVs[4]))

    -- Height ignore the up and down arrows
    this.mLineHeight = this.mHeight - (this.mTileHeight*2)

    setmetatable(this, self)
    this:SetPosition(0, 0)
    return this
end


function Scrollbar:SetPosition(x, y)
    self.mX = x
    self.mY = y

    local top = y + self.mHeight / 2
    local bottom = y - self.mHeight / 2
    local halfTileHeight = self.mTileHeight / 2

    self.mUpSprite:SetPosition(x, top - halfTileHeight)
    self.mDownSprite:SetPosition(x, bottom + halfTileHeight)

    self.mBackgroundSprite:SetScale(1, self.mLineHeight / self.mTileHeight)
    self.mBackgroundSprite:SetPosition(self.mX, self.mY)
    self:SetNormalValue(self.mValue)
end

function Scrollbar:SetNormalValue(v)
    self.mValue = v

    self.mCaretSprite:SetScale(1, self.mCaretSize)
    -- caret 0 is the top of the scrollbar
    local caretHeight = self.mTileHeight * self.mCaretSize
    local halfCaretHeight = caretHeight / 2
    self.mStart = self.mY + (self.mLineHeight / 2) - halfCaretHeight

    -- Subtracting caret, to take into account the first -halfcaret and the one at the other end
    self.mStart = self.mStart - ((self.mLineHeight - caretHeight)*self.mValue)

    self.mCaretSprite:SetPosition(self.mX, self.mStart)
end


function Scrollbar:Render(renderer)
    renderer:DrawSprite(self.mUpSprite)
    renderer:DrawSprite(self.mBackgroundSprite)
    renderer:DrawSprite(self.mDownSprite)
    renderer:DrawSprite(self.mCaretSprite)
end


function Scrollbar:SetScrollCaretScale(normalValue)
    self.mCaretSize = ((self.mLineHeight )*normalValue)/self.mTileHeight
    --print('cSize', normalValue, self.mCaretSize, self.mLineHeight - self.mTileHeight)

    -- Don't let it go below 1
    self.mCaretSize = math.max(1, self.mCaretSize)
end