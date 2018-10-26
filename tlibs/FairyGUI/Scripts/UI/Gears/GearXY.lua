--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:18
--

local Class = require('libs.Class')

local GearBase = FairyGUI.GearBase
local ITweenListener = FairyGUI.ITweenListener

---@class FairyGUI.GearXY:FairyGUI.GearBase @implement ITweenListener
local GearXY = Class.inheritsFrom('GearXY', nil, GearBase)

--TODO: FairyGUI.GearXY

FairyGUI.GearXY = GearXY
return GearXY