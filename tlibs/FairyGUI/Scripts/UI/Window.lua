--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:58
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent

---@class FairyGUI.Window:FairyGUI.GComponent
local Window = Class.inheritsFrom('Window', nil, GComponent)

FairyGUI.GComponent = GComponent
return GComponent