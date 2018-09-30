--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 19:45
--
local Class = require('libs.Class')
local DispalyObject = FairyGUI.DisplayObject

---@class FairyGUI.Container : FairyGUI.DisplayObject
local Container = {}
Container = Class.inheritsFrom('Container', Container, DisplayObject)

--TODO: Container

FairyGUI.Container = Container
return Container