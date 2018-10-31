--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 10:55
--

local Class = require('libs.Class')

local EventDispatcher = FairyGUI.EventDispatcher

---@class FairyGUI.LongPressGesture:FairyGUI.EventDispatcher
local LongPressGesture = Class.inheritsFrom('LongPressGesture', nil, EventDispatcher)

--TODO: FairyGUI.LongPressGesture

FairyGUI.LongPressGesture = LongPressGesture
return LongPressGesture