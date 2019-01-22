--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:30
--

local Class = require('libs.Class')

local DisplayObject = FairyGUI.DisplayObject

---@type FairyGUI.Shape
local Shape = Class.inheritsFrom('Shape', nil, DisplayObject)

FairyGUI.Shape = Shape
return Shape