local DefaultRenderer =
function(self, renderer, text)
    renderer:SetFont(self.font)
    renderer:ScaleText(self.scale, self.scale)
    renderer:AlignText(self.alignX, self.alignY)
    renderer:DrawText2d(self.x, self.y, text, self.color, self.width)

    -- Reset renderer
    local default = CaptionStyles["default"]
    renderer:SetFont(default.font)
    renderer:ScaleText(default.scale, default.scale)
end

local FadeApply =
function(target, value)
    target.color:SetW(value)
end

CaptionStyles =
{
    ["default"] =
    {
        font = "default",
        scale = 1,
        alignX = "center",
        alignY = "center",
        x = 0,
        y = 0,
        color = Vector.Create(1, 1, 1, 1),
        width = -1,
        Render = DefaultRenderer,
        ApplyFunc = function() end,
    },
    ["title"] =
    {
        --font = "title",
        scale = 3,
        y = 75,
        Render = DefaultRenderer,
        ApplyFunc = FadeApply,
        duration = 3,
    },
    ["subtitle"] =
    {
        scale = 1,
        y = -5,
        color = Vector.Create(0.4, 0.38, 0.39, 1),
        Render = DefaultRenderer,
        ApplyFunc = FadeApply,
        duration = 1
    }
}


--
-- Set caption defaults
--
for name, style in pairs(CaptionStyles) do
    if name ~= "default" then
        for k, v in pairs(CaptionStyles.default) do
            style[k] = style[k] or v
        end
    end
end