--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 10:35
--
local Class = require('libs.Class')

local GObject = FairyGUI.GObject

---@type FairyGUI.GComponent
local GComponent = Class.inheritsFrom('GComponent', nil, GObject)

FairyGUI.GComponent = GComponent
return GComponent