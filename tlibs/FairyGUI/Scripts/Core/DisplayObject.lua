--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 17:56
--

local Class = require('libs.Class')
local EventDispatcher = FairyGUI.EventDispatcher

---@class FairyGUI.DisplayObject : FairyGUI.EventDispatcher
local DisplayObject = {

}
DisplayObject = Class.inheritsFrom('DisplayObject', DisplayObject, EventDispatcher)

--TODO: DisplayObject

FairyGUI.DisplayObject = DisplayObject
return DisplayObject
