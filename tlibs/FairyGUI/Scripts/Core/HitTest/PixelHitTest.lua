--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 17:54
--

local Class = require('libs.Class')
local bit = require('bit')
local band = bit.band
local rshift = bit.rshift
local floor = math.floor

local IHitTest = FairyGUI.IHitTest


---@class FairyGUI.PixelHitTestData:ClassType
---@field public pixelWidth number
---@field public scale number
---@field public pixels byte[]
---@field public pixelsLength number
---@field public pixelsOffset number
local PixelHitTestData = Class.inheritsFrom('PixelHitTestData')

---@param ba Utils.ByteBuffer
function PixelHitTestData:Load(ba)
    ba:ReadInt()
    self.pixelWidth = ba:ReadInt()
    self.scale = 1 / ba:ReadByte()
    self.pixels = ba.buffer
    self.pixelsLength = ba:ReadInt()
    self.pixelsOffset = ba.position
    ba:Skip(self.pixelsLength)
end

---@class FairyGUI.PixelHitTest:FairyGUI.IHitTest
---@field public offsetX number;
---@field public offsetY number;
---@field public scaleX number;
---@field public scaleX number;
---@field public scaleY number;
---@field private _data FairyGUI.PixelHitTestData;
local PixelHitTest = Class.inheritsFrom('PixelHitTest', nil, IHitTest)

---@param data FairyGUI.PixelHitTestData
---@param offsetX number
---@param offsetY number
function PixelHitTest:__ctor(data, offsetX, offsetY)
    self._data = data
    self.offsetX = offsetX
    self.offsetY = offsetY

    self.scaleX = 1
    self.scaleY = 1
end

---@param val boolean
function PixelHitTest:SetEnabled(val) end

---@param container FairyGUI.Container
---@param localPoint Love2DEngine.Vector2
---@return boolean
function PixelHitTest:HitTest(container, localPoint)
    local pt = container:GetHitTestLocalPoint()
    localPoint:Set(pt)

    local _data = self._data
    local x = floor((localPoint.x / self.scaleX - self.offsetX) * _data.scale)
    local y = floor((localPoint.y / self.scaleY - self.offsetY) * _data.scale)
    if x < 0 or y < 0 or x >= _data.pixelWidth then
        return false
    end

    local pos = y * _data.pixelWidth + x
    local pos2 = math.round(pos / 8)
    local pos3 = pos % 8

    if pos2 >= 0 and pos2 < _data.pixelsLength then
        return band(rshift(_data.pixels[_data.pixelsOffset + pos2], pos3), 0x1) > 0
    end
    return false
end


FairyGUI.PixelHitTestData = PixelHitTestData
FairyGUI.PixelHitTest = PixelHitTest
return PixelHitTest