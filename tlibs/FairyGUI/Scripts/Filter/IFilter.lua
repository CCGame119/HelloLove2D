--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 14:43
--

local Class = require('libs.Class')
local DisplayObject = FairyGUI.DisplayObject

---@class FairyGUI.IFilter:ClassType
---@field public target FairyGUI.DisplayObject
local IFilter = Class.inheritsFrom('IFilter')

function IFilter:Update() end
function IFilter:Dispose() end

FairyGUI.IFilter = IFilter
return IFilter