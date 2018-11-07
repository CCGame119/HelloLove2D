--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:27
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent
local IColorGear = FairyGUI.IColorGear

---@class FairyGUI.GButton:FairyGUI.GComponent @implement IColorGear
local GButton = Class.inheritsFrom('GButton', nil, GComponent, {IColorGear})

--TODO: FairyGUI.GButton

FairyGUI.GButton = GButton
return GButton