--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:32
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent
local IColorGear = FairyGUI.IColorGear

---@class FairyGUI.GLabel:FairyGUI.GComponent @implement IColorGear
local GLabel = Class.inheritsFrom('GLabel', nil, GComponent)

--TODO: FairyGUI.GLabel

FairyGUI.GLabel = GLabel
return GLabel