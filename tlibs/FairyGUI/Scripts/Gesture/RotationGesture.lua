--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 10:57
--

local Class = require('libs.Class')

local EventDispatcher = FairyGUI.EventDispatcher

---@class FairyGUI.RotationGesture:FairyGUI.EventDispatcher
local RotationGesture = Class.inheritsFrom('RotationGesture', nil, EventDispatcher)

--TODO: FairyGUI.RotationGesture

FairyGUI.RotationGesture = RotationGesture
return RotationGesture