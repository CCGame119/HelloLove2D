--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 14:07
--
local Class = require('libs.Class')

local IEventDispatcher = FairyGUI.IEventDispatcher

---@type FairyGUI.EventDispatcher
local EventDispatcher = Class.inheritsFrom('EventDispatcher', nil, IEventDispatcher)

FairyGUI.EventDispatcher = EventDispatcher
return EventDispatcher