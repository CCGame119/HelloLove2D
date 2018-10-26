--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 11:46
--

local Class = require('libs.Class')

---@class Utils.ToolSet:ClassType
local ToolSet = Class.inheritsFrom('ToolSet')

---@param t Love2DEngine.Transform
---@param parent Love2DEngine.Transform
function ToolSet.SetParent(t, parent)
    --TODO: ToolSet.SetParent
end

---@param rect1 Love2DEngine.Rect
---@param rect2 Love2DEngine.Rect
---@return Love2DEngine.Rect
function ToolSet.Intersection(rect1, rect2)
    --TODO: ToolSet.Intersection
end

--TODO: Utils.ToolSet

Utils.ToolSet = ToolSet
return ToolSet