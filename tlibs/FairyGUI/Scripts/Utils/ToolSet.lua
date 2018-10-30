--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 11:46
--

local Class = require('libs.Class')

local Color = Love2DEngine.Color
local Color32 = Love2DEngine.Color32
local Rect = Love2DEngine.Rect
local FlipType = FairyGUI.FlipType

local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

local byte = string.byte
local char = string.char

---@class Utils.ToolSet:ClassType
local ToolSet = Class.inheritsFrom('ToolSet')

---@param str string
---@return Love2DEngine.Color
function ToolSet.ConvertFromHtmlColor(str)
    if #str < 7 or str[1] ~= '#' then
        return Color.black
    end

    if #str == 9 then
        return Color32(tonumber(str(4, 5), 16),
                tonumber(str(6, 7), 16),
                tonumber(str(8, 9), 16),
                tonumber(str(2, 3), 16))
    end

    return Color32(tonumber(str(2, 3), 16),
            tonumber(str(4, 5), 16),
            tonumber(str(6, 7), 16),
            255)
end

---@param val number
---@return Love2DEngine.Color
function ToolSet.ColorFromRGB(val)
    return Color(band(rshift(val, 16), 0xFF) / 255,
            band(rshift(val, 8), 0xFF) / 255,
            band(val, 0xFF) / 255, 1)
end

---@param val number
---@return Love2DEngine.Color
function ToolSet.ColorFromRGBA(val)
    return Color(band(rshift(val, 16), 0xFF) / 255,
            band(rshift(val, 8), 0xFF) / 255,
            band(val, 0xFF) / 255,
            band(rshift(val, 24), 0xFF) / 255)
end

ToolSet.CharToHex = string.byte

---@param rect1 Love2DEngine.Rect
---@param rect2 Love2DEngine.Rect
---@return Love2DEngine.Rect
function ToolSet.Intersection(rect1, rect2)
    if rect1.width == 0 or rect1.height == 0 or rect2.width == 0 or rect2.height == 0 then
        return Rect(0, 0, 0, 0)
    end

    local left = rect1.xMin > rect2.xMin and rect1.xMin or rect2.xMin
    local right = rect1.xMax < rect2.xMax and rect1.xMax or rect2.xMax
    local top = rect1.yMin > rect2.yMin and rect1.yMin or rect2.yMin
    local bottom = rect1.yMax < rect2.yMax and rect1.yMax or rect2.yMax

    if left > right or top > bottom then
        return Rect(0, 0, 0, 0)
    end
    return Rect.MinMaxRect(left, top, right, bottom)
end

---@param rect1 Love2DEngine.Rect @ref rect1
---@param rect2 Love2DEngine.Rect @ref rect2
---@return Love2DEngine.Rect
function ToolSet.Union(rect1, rect2)
    if rect2.width == 0 or rect2.height == 0 then
       return rect1
    end
    if rect1.width == 0 or rect1.height == 0  then
        return rect2
    end

    local left = rect1.xMin > rect2.xMin and rect1.xMin or rect2.xMin
    local right = rect1.xMax < rect2.xMax and rect1.xMax or rect2.xMax
    local top = rect1.yMin > rect2.yMin and rect1.yMin or rect2.yMin
    local bottom = rect1.yMax < rect2.yMax and rect1.yMax or rect2.yMax

    local x = math.min(rect1.x, rect2.x)
    local y = math.min(rect1.y, rect2.y)
    return Rect(x, y, math.max(rect1.xMax, rect2.xMax) - x, math.max(rect1.yMax, rect2.yMax) - y)
end

---@param rect Love2DEngine.Rect
---@param flip FairyGUI.FlipType
function ToolSet.FlipRect(rect, flip)
    if flip == FlipType.Horizontal or flip == FlipType.Both then
        rect.xMin, rect.xMax = rect.xMax, rect.xMin
    end
    if flip == FlipType.Vertical or flip == FlipType.Both then
        rect.yMin, rect.yMax = rect.yMax, rect.yMin
    end
end

---@param sourceWidth number
---@param sourceHeight number
---@param rect Love2DEngine.Rect
---@param flip FairyGUI.FlipType
function ToolSet.FlipInnerRect(sourceWidth, sourceHeight, rect, flip)
    if flip == FlipType.Horizontal or flip == FlipType.Both then
        rect.x = sourceWidth - rect.xMax
        rect.xMax = rect.x + rect.width
    end

    if flip == FlipType.Vertical or flip == FlipType.Both then
        rect.y = sourceHeight - rect.yMax
        rect.yMax = rect.y + rect.height
    end
end

---@param uvSrc Love2DEngine.Vector2[]
---@param uvDest Love2DEngine.Vector2[]
---@param min number
---@param max number
function ToolSet.uvLerp(uvSrc, uvDest, min, max)
    local uMin = math.fmaxval
    local uMax = math.fminval
    local vMin = math.fmaxval
    local vMax = math.fminval
    for i, v in ipairs(uvSrc) do
        if v.x < uMin then
            uMin = v.x
        end
        if v.x > uMax then
            uMax = v.x
        end
        if v.y < vMin then
            vMin = v.y
        end
        if v.y > vMax then
            vMax = v.y
        end
    end
    local uLen = uMax - uMin
    local vLen = vMax - vMin
    for i, v in ipairs(uvSrc) do
        v.x = (v.x - uMin) / uLen
        v.y = (v.y - vMin) / vLen
        uvDest[i] = v
    end
end

---@param t Love2DEngine.Transform
---@param parent Love2DEngine.Transform
function ToolSet.SetParent(t, parent)
    if t.parent == parent then
        return
    end
    t:SetParent(parent, false)
end

---@param matrix Love2DEngine.Matrix4x4
---@param skewX number
---@param skewY number
function ToolSet.SkewMatrix(matrix, skewX, skewY)
    skewX = skewX - skewX * math.Deg2Rad
    skewY = skewY - skewY * math.Deg2Rad
    local sinX = math.sin(skewX)
    local cosX = math.cos(skewX)
    local sinY = math.sin(skewY)
    local cosY = math.cos(skewY)

    local e11 = matrix.e11 * cosY - matrix.e21 * sinX
    local e21 = matrix.e11 * sinY + matrix.e21 * cosX
    local e12 = matrix.e12 * cosY - matrix.e22 * sinX
    local e22 = matrix.e12 * sinY + matrix.e22 * cosX
    local e13 = matrix.e13 * cosY - matrix.e23 * sinX
    local e23 = matrix.e13 * sinY + matrix.e23 * cosX

    matrix.e11 = e11
    matrix.e21 = e21
    matrix.e12 = e12
    matrix.e22 = e22
    matrix.e13 = e13
    matrix.e23 = e23
end

---@param p Love2DEngine.Vector2 @ref p
---@param a Love2DEngine.Vector2 @ref a
---@param b Love2DEngine.Vector2 @ref b
---@param c Love2DEngine.Vector2 @ref c
function ToolSet.IsPointInTriangle(p, a, b, c)
    local v0x = c.x - a.x
    local v0y = c.y - a.y
    local v1x = b.x - a.x
    local v1y = b.y - a.y
    local v2x = p.x - a.x
    local v2y = p.y - a.y

    local dot00 = v0x * v0x + v0y * v0y
    local dot01 = v0x * v1x + v0y * v1y
    local dot02 = v0x * v2x + v0y * v2y
    local dot11 = v1x * v1x + v1y * v1y
    local dot12 = v1x * v2x + v1y * v2y

    local invDen = 1.0 / (dot00 * dot11 - dot01 * dot01)
    local u = (dot11 * dot02 - dot01 * dot12) * invDen
    local v = (dot00 * dot12 - dot01 * dot02) * invDen

    return (u >= 0) and (v >= 0) and (u + v < 1)
end


Utils.ToolSet = ToolSet
return ToolSet