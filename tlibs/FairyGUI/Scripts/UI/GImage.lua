--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:26
--
local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local IColorGear = FairyGUI.IColorGear

---@class FairyGUI.GImage:FairyGUI.GObject @implement IColorGear
local GImage = Class.inheritsFrom('GImage', nil, GObject)

--TODO: FairyGUI.GImage

FairyGUI.GImage = GImage
return GImage