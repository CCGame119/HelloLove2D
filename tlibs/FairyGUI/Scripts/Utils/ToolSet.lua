--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 11:46
--

local Class = require('libs.Class')

---@class FairyGUI.ToolSet:ClassType
local ToolSet = Class.inheritsFrom('ToolSet')

---@param t Love2DEngine.Transform
---@param parent Love2DEngine.Transform
function ToolSet.SetParent(t, parent)
    --TODO: ToolSet.SetParent
end

--TODO: FairyGUI.ToolSet

FairyGUI.ToolSet = ToolSet
return ToolSet