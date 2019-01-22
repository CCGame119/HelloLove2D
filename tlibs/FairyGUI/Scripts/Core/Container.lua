--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 19:45
--
local Class = require('libs.Class')

local DisplayObject = FairyGUI.DisplayObject

---@type FairyGUI.Container
local Container = Class.inheritsFrom('Container', nil, DisplayObject)

FairyGUI.Container = Container
return Container