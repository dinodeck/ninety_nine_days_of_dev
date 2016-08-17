BitmapText = {}
BitmapText.__index = BitmapText
function BitmapText:Create(def)
    local texture = Texture.Find(def.texture)
    local this =
    {
        mTexture = texture,
        mWidth = texture:GetWidth(),
        mHeight = texture:GetHeight(),
        mGlyphW = def.width,
        mGlyphH = def.height,
        mLookUp = def.lookup,
        mSprite = Sprite.Create(),
        mAlignX = "left",
        mAlignY = "top"

    }
    this.mSprite:SetTexture(this.mTexture)

    setmetatable(this, self)
    return this
end

function BitmapText:AlignText(x, y)
    self.mAlignX = x
    self.mAlignY = y
end

function BitmapText:AlignTextX(x)
    self.mAlignX = x
end

function BitmapText:AlignTextY(y)
    self.mAlignY = y
end

function BitmapText:IndexToUV(x, y)
    local width = self.mGlyphW/self.mWidth
    local height = self.mGlyphH/self.mHeight

    local _x = x * width
    local _y = y * height

    return _x, _y, _x + width, _y + height
end

function BitmapText:DrawText(renderer, x, y, text)

    local _x = x
    for i = 1, string.len(text) do
        local c = string.sub(text, i, i)
        self.mSprite:SetUVs(self:IndexToUV(unpack(self.mLookUp[c])))
        self.mSprite:SetPosition(_x, y)
        renderer:DrawSprite(self.mSprite)
        _x = _x + self.mGlyphW
    end

end

function BitmapText:RenderSubString(renderer, x, y, text, start, finish, color)

    start = start or 1
    finish = finish or string.len(text)
    color = color or Vector.Create(1, 1, 1, 1)

    self.mSprite:SetColor(color)
    local prevC = -1
    for i = start, finish do
        local c = string.sub(text, i, i)
        if prevC ~= -1 then
            -- kerning can be done here!
            x = x + self.mGlyphW
        end

        local cData = self.mLookUp[c] or self.mLookUp['?']
        self.mSprite:SetUVs(self:IndexToUV(unpack(cData)))
        self.mSprite:SetPosition(x, y)
        renderer:DrawSprite(self.mSprite)

        prevC = c
    end
end


function BitmapText:DrawText2d(renderer, x, y, text, color, maxWidth)

    local yOffset = 0
    maxWidth = maxWidth or -1
    -- Center to top-left origin
    x = x + self.mGlyphW * 0.5
    y = y - self.mGlyphH * 0.5

    if self.mAlignY == "bottom" then
        local lines = self:CountLines(text, maxWidth)
        yOffset = lines * self.mGlyphH
    elseif self.mAlignY == "center" then
        local lines = self:CountLines(text, maxWidth)
        lines = lines * 0.5
        yOffset = lines * self.mGlyphH
    end

    local lineEnd = 1
    local textLen = string.len(text)

    while lineEnd < (textLen + 1) do

        local outStart, lEnd, outPixelWidth =
            self:NextLine(text, lineEnd, maxWidth)

        lineEnd = math.min(textLen, lEnd) -- this shouldn't happen! hack fix!

        local xPos = x
        if self.mAlignX == "right" then
            xPos = xPos - outPixelWidth
        elseif self.mAlignX == "center" then
           xPos = xPos - outPixelWidth * 0.5
        end

        self:RenderSubString(renderer,
                        xPos, y + yOffset,
                        text, outStart, lineEnd,
                        color)

        y = y - self.mGlyphH;

        -- so the while loop will properly support 1 char strings
        if lineEnd == textLen then
            break
        end
    end

end


function BitmapText:RenderLine(renderer, x, y, text, color)
    alignX = self.mAlignX
    alignY = self.mAlignY
    color = color or Vector.Create(1,1,1,1)

    if alignX == "right" then
        x = x - self:MeasureText(text):X()
    elseif alignX == "center" then
        x = x - self:MeasureText(text):X() / 2;
    end

    if alignY == "bottom" then
        y = y - self.mGlyphH;
    elseif alignY == "center" then
        y = y - self.mGlyphH * 0.5
    end


    local prevC = -1
    for i = 1, string.len(text) do
        local c = string.sub(text, i, i)

        if prevC ~= -1 then
            x = x + self.mGlyphW
        end

        local cData = self.mLookUp[c] or self.mLookUp['?']
        self.mSprite:SetUVs(self:IndexToUV(unpack(cData)))
        self.mSprite:SetPosition(x, y)
        renderer:DrawSprite(self.mSprite)

        prevC = c;
    end
end


function BitmapText:CalcWidth(str)
    return string.len(str) * self.mGlyphW
end

function BitmapText:CalcHeight()
    return self.mGlyphH
end

function BitmapText:MeasureText(text, maxWidth)

    maxWidth = maxWidth or -1

    if maxWidth < 1 then

        local width = self:CalcWidth(text)
        local height = self.mGlyphH
        return Vector.Create(width, height)

    else

        local lines, outLongestLine = self:CountLines(text, maxWidth)
        local width = outLongestLine
        if lines == 1 then
            width = self:CalcWidth(text)
        end
        local height = lines * self.mGlyphH
        return Vector.Create(width, height)
    end
end


-- Returns 3 variables
-- start - start of the next line
-- finish - end the next line
-- width - pixel with of the line
function BitmapText:NextLine(text, cursor, maxWidth)
    if self:IsWhiteSpace(string.sub(text, cursor, cursor)) then
        cursor = cursor + 1
    end

    local start = cursor
    local finish = cursor

    local prevC = -1
    local prevNonWhite = -1

    local pixelWidth = 0
    local pixelWidthStart = 0

    for i = cursor, string.len(text) do
        local c = string.sub(text, i, i)

        if self:IsWhiteSpace(c) then
            start = math.max(cursor, i - 1)
            pixelWidthStart = pixelWidth
            prevNonWhite = prevC
        end

        if prevC ~= -1 then

            local kern = 0;
            local finishW = self.mGlyphW;

            if start == cursor or
                pixelWidth + kern + finishW < maxWidth then
                pixelWidth = pixelWidth + finishW + kern

            else
                finishW = self.mGlyphW
                return cursor, start + 1, pixelWidthStart + finishW
            end
        end

        prevC = c;
        finish = finish + 1;

    end

    local finishW = 0;

    if prevC ~= -1 then
        finishW = self.mGlyphW;
    end

    -- From cursor to last word
     return cursor, finish, pixelWidth + finishW;
end

function BitmapText:IsWhiteSpace(char)
    if char == ' ' then
        return true
    end
    return false
end

function BitmapText:CountLines(text, maxWidth)

    local lineCount = 0
    local lineEnd = 1
    local outMaxLineWidth = -1
    local outStart = -1

    local textLen = string.len(text)

    if textLen == 1 then
        return 1
    end

    while lineEnd < textLen do

        outStart, lineEnd, outPixelWidth = self:NextLine(text,
                                                      lineEnd,
                                                       maxWidth)

        outMaxLineWidth = math.max(outMaxLineWidth, outPixelWidth)

        lineCount = lineCount + 1
    end

    return lineCount, outMaxLineWidth
end