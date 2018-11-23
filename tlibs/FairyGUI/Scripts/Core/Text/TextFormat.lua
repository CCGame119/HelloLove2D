--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 10:51
--

local Class = require('libs.Class')
local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

local Color = Love2DEngine.Color

---@class FairyGUI.TextFormat.SpecialStyle:enum
local SpecialStyle = {
    None = 0,
    Superscript = 1,
    Subscript = 2,
}

---@class FairyGUI.TextFormat:ClassType
---@field public size number
---@field public font string
---@field public color Love2DEngine.Color
---@field public lineSpacing number
---@field public letterSpacing number
---@field public bold boolean
---@field public underline boolean
---@field public italic boolean
---@field public gradientColor Love2DEngine.Color32[]
---@field public align FairyGUI.AlignType
---@field public specialStyle FairyGUI.TextFormat.SpecialStyle
local TextFormat = Class.inheritsFrom('TextFormat')

function TextFormat:__ctor()
    self.color = Color.black
    self.size = 12
    self.lineSpacing = 3
end

---@param value number
function TextFormat:SetColor(value)
    local rr = band(rshift(value, 16), 0x0000ff)
    local gg = band(rshift(value, 8), 0x0000ff)
    local bb = band(value, 0x0000ff)
    local r = rr / 255.0
    local g = gg / 255.0
    local b = bb / 255.0
    self.color = Color(r, g, b, 1)
end

---@param aFormat FairyGUI.TextFormat
---@return boolean
function TextFormat:EqualStyle(aFormat)
    return self.size == aFormat.size and self.color == aFormat.color
            and self.bold == aFormat.bold and self.underline == aFormat.underline
            and self.italic == aFormat.italic
            and self.gradientColor == aFormat.gradientColor
            and self.align == aFormat.align
            and self.specialStyle == aFormat.specialStyle;
end

---@param source FairyGUI.TextFormat
function TextFormat:CopyFrom(source)
    self.size = source.size
    self.font = source.font
    self.color = source.color:Clone()
    self.lineSpacing = source.lineSpacing
    self.letterSpacing = source.letterSpacing
    self.bold = source.bold
    self.underline = source.underline
    self.italic = source.italic
    if (source.gradientColor ~= nil) then
        self.gradientColor = {}
        ---@param v Love2DEngine.Color32
        local callback = function (v) return v:Clone() end
        table.copy_l(source.gradientColor, self.gradientColor, callback)
    else
        self.gradientColor = nil
    end
    self.align = source.align
    self.specialStyle = source.specialStyle
end


TextFormat.SpecialStyle = SpecialStyle
FairyGUI.TextFormat = TextFormat
return TextFormat