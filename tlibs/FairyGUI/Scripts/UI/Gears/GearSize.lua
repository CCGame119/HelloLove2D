--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:21
--

local Class = require('libs.Class')

local GearBase = FairyGUI.GearBase
local ITweenListener = FairyGUI.ITweenListener

---@class FairyGUI.GearSize:FairyGUI.GearBase @implement ITweenListener
local GearSize = Class.inheritsFrom('GearSize', nil, GearBase)

--TODO: FairyGUI.GearSize

FairyGUI.GearSize = GearSize
return GearSize