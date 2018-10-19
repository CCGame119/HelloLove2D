--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:30
--

local Class = require('libs.Class')

local DisplayObject = FairyGUI.DisplayObject

---@class FairyGUI.Shape:FairyGUI.DisplayObject
local Shape = Class.inheritsFrom('Shape', nil, DisplayObject)

--TODO: FairyGUI.Shape

FairyGUI.Shape = Shape
return Shape