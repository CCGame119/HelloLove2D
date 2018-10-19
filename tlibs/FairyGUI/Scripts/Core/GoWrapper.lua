--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:22
--

local Class = require('libs.Class')

local DisplayObject = FairyGUI.DisplayObject

---@class FairyGUI.GoWrapper:FairyGUI.DisplayObject @GoWrapper is class for wrapping common gameobject into UI display list
local GoWrapper = Class.inheritsFrom('GoWrapper', nil, DisplayObject)

--TODO: FairyGUI.GoWrapper

FairyGUI.GoWrapper = GoWrapper
return GoWrapper