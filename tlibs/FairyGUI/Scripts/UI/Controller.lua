--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:39
--

local Class = require('libs.Class')

local EventDispatcher = FairyGUI.EventDispatcher

---@class FairyGUI.Controller:FairyGUI.EventDispatcher
---@field public selectedPageId string
local Controller = Class.inheritsFrom('Controller', nil, EventDispatcher)

--TODO: FairyGUI.Controller

FairyGUI.Controller = Controller
return Controller