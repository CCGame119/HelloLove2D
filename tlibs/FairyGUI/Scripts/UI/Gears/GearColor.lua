--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:31
--

local Class = require('libs.Class')

local GearBase = FairyGUI.GearBase
local ITweenListener = FairyGUI.ITweenListener

---@class FairyGUI.GearColorValue:ClassType
local GearColorValue = Class.inheritsFrom('GearColorValue')

---@class FairyGUI.GearColor:FairyGUI.GearBase @implement FairyGUI.ITweenListener
local GearColor = Class.inheritsFrom('GearColor', nil, GearBase)

--TODO: FairyGUI.GearColor

FairyGUI.GearColorValue = GearColorValue
FairyGUI.GearColor = GearColor
return GearColor