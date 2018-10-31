--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 10:59
--

local Class = require('libs.Class')

local EventDispather = FairyGUI.EventDispatcher

---@class FairyGUI.SwipeGesture:FairyGUI.EventDispatcher
local SwipeGesture = Class.inheritsFrom('SwipeGesture', nil, EventDispather)

--TODO: FairyGUI.SwipeGesture

FairyGUI.SwipeGesture = SwipeGesture
return SwipeGesture