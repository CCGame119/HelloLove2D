--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 15:57
--

local Class = require('libs.Class')

---@class FairyGUI.IColorGear:ClassType
---@field color Love2DEngine.Color
local IColorGear = Class.inheritsFrom('IColorGear')


---@class FairyGUI.ITextColorGear:FairyGUI.IColorGear
---@field strokeColor Love2DEngine.Color
local ITextColorGear = Class.inheritsFrom('ITextColorGear', nil, IColorGear)


FairyGUI.IColorGear = IColorGear
FairyGUI.ITextColorGear = ITextColorGear
return IColorGear, ITextColorGear