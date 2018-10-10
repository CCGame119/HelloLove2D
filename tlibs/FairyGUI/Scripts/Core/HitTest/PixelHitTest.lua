--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 17:54
--

local Class = require('libs.Class')

local IHitTest = FairyGUI.IHitTest
local ByteBuffer = FairyGUI.ByteBuffer

---@class FairyGUI.PixelHitTestData:ClassType
---@field public pixelWidth number
---@field public scale number
---@field public pixels byte[]
---@field public pixelsLength number
---@field public pixelsOffset number
local PixelHitTestData = Class.inheritsFrom('PixelHitTestData')

---@param ba FairyGUI.ByteBuffer
function PixelHitTestData:Load(ba)
    ba:ReadInt()
    self.pixelWidth = ba:ReadInt()
    self.scale = 1 / ba:ReadByte()
    self.pixels = ba.buffer
    self.pixelsLength = ba.ReadInt()
    self.pixelsOffset = ba.position
    ba.Skip(self.pixelsLength)
end

---@class FairyGUI.PixelHitTest
local PixelHitTest = Class.inheritsFrom('PixelHitTest', nil, IHitTest)

--TODO: FairyGUI.PixelHitTest

FairyGUI.PixelHitTestData = PixelHitTestData
FairyGUI.PixelHitTest = PixelHitTest
return PixelHitTest