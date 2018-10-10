--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 15:30
--

local Class = require('libs.Class')

local Rect = Love2DEngine.Rect
local IHitTest = FairyGUI.IHitTest

---@class FairyGUI.RectHitTest:FairyGUI.IHitTest
---@field rect Love2DEngine.Rect
local RectHitTest = Class.inheritsFrom('RectHitTest', nil, IHitTest)

function RectHitTest:__ctor(...)
    self._rect = Rect.new()
end

---@param container FairyGUI.Container
---@param localPoint Love2DEngine.Vector2
function RectHitTest:HitTest(container, localPoint)
    local pt = container:GetHitTestLocalPoint()
    localPoint:Set(pt.x, pt.y)
    return self.rect:Contains(localPoint)
end

local __get = Class.init_get(RectHitTest)
local __set = Class.init_set(RectHitTest)

---@param self FairyGUI.RectHitTest
__get.rect = function(self)
    return self._rect:Clone()
end

---@param self FairyGUI.RectHitTest
---@param val Love2DEngine.Rect
__set.rect = function(self, val)
    self._rect:Set(val.x, val.y, val.width, val.height)
end

FairyGUI.RectHitTest = RectHitTest
return RectHitTest