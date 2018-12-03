--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:20
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2

local BaseFont = FairyGUI.BaseFont
local UIPackage = FairyGUI.UIPackage
local ShaderConfig = FairyGUI.ShaderConfig

---@class FairyGUI.BitmapFont.BMGlyph:ClassType
---@field public offsetX number
---@field public offsetY number
---@field public width number
---@field public height number
---@field public advance number
---@field public lineHeight number
---@field public uv Love2DEngine.Vector2[]
---@field public channel number  --0-n/a, 1-r,2-g,3-b,4-alpha
local BMGlyph = Class.inheritsFrom('BMGlyph')

function BMGlyph:__ctor()
    self.uv = {}
end

---@class FairyGUI.BitmapFont:FairyGUI.BaseFont
---@field public size number
---@field public resizable boolean
---@field private _dict table<number, FairyGUI.BitmapFont.BMGlyph>
---@field public scale number
local BitmapFont = Class.inheritsFrom('BitmapFont', nil, BaseFont)

---@param item FairyGUI.PackageItem
function BitmapFont:__ctor(item)
    self.packageItem = item
    self.name = UIPackage.URL_PREFIX + self.packageItem.owner.id + self.packageItem.id
    self.canTint = true
    self.canLight = false
    self.canOutline = true
    self.hasChannel = false
    self.shader = ShaderConfig.bmFontShader

    self._dict = {}
    self.scale = 1
end

---@param ch char
---@param glyph FairyGUI.BitmapFont.BMGlyph
function BitmapFont:AddChar(ch, glyph)
    self._dict[ch] = glyph
end

function BitmapFont:SetFormat(format, fontSizeScale)
    if self.resizable then
        self.scale = format.size / self.size * fontSizeScale
    else
        self.scale = fontSizeScale
    end
end

function BitmapFont:GetGlyphSize(ch, width, height)
    if (ch == ' ') then
        width = math.ceil(self.size * self.scale / 2)
        height = math.ceil(self.size * self.scale)
        return true, width, height
    end

    local bg = self._dict[ch]
    if nil ~= bg then
       width = math.ceil(bg.advance * self.scale)
       height = math.ceil(bg.lineHeight * self.scale)
        return true, width, height
    end

    width = 0
    height = 0
    return false, width, height
end

function BitmapFont:GetGlyph(ch, glyph)
    if (ch == ' ') then
        glyph.width = math.ceil(self.size * self.scale / 2)
        glyph.height = math.ceil(self.size * self.scale)
        glyph.vert.xMin = 0
        glyph.vert.xMax = 0
        glyph.vert.yMin = 0
        glyph.vert.yMax = 0
        glyph.uv[1] = Vector2.zero
        glyph.uv[2] = Vector2.zero
        glyph.uv[3] = Vector2.zero
        glyph.uv[4] = Vector2.zero
        glyph.channel = 0
        return true
    end

    local bg = self._dict[ch]
    if nil ~= bg then
        glyph.width = math.ceil(bg.advance * self.scale)
        glyph.height = math.ceil(bg.lineHeight * self.scale)
        glyph.vert.xMin = bg.offsetX * self.scale
        glyph.vert.xMax = (bg.offsetX + bg.width) * self.scale
        glyph.vert.yMin = (-bg.height - bg.offsetY) * self.scale
        glyph.vert.yMax = -bg.offsetY * self.scale
        glyph.uv[1] = bg.uv[1]
        glyph.uv[2] = bg.uv[2]
        glyph.uv[3] = bg.uv[3]
        glyph.uv[4] = bg.uv[4]
        glyph.channel = bg.channel
        return true
    end

    return false
end

FairyGUI.BitmapFont = BitmapFont
return BitmapFont