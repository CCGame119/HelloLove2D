--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:20
--

local Class = require('libs.Class')

local GearBase = FairyGUI.GearBase
local ITweenListener = FairyGUI.ITweenListener

---@class FairyGUI.GearLook:FairyGUI.GearBase @implement ITweenListener
local GearLook = Class.inheritsFrom('GearLook', nil, GearBase)

--TODO: FairyGUI.GearLook

FairyGUI.GearLook = GearLook
return GearLook