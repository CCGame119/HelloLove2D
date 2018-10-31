--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:32
--

local Class = require('libs.Class')

local GearBase = FairyGUI.GearBase

---@class FairyGUI.GearAnimationValue:ClassType
local GearAnimationValue = Class.inheritsFrom('GearAnimationValue')

---@class FairyGUI.GearAnimation:FairyGUI.GearBase
local GearAnimation = Class.inheritsFrom('GearAnimation', nil, GearBase)

--TODO: FairyGUI.GearAnimation

FairyGUI.GearAnimationValue = GearAnimationValue
FairyGUI.GearAnimation = GearAnimation
return GearAnimation