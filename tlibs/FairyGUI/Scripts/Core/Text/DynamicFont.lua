--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:23
--

local Class = require('libs.Class')

local BaseFont = FairyGUI.BaseFont

---@class FairyGUI.DynamicFont:FairyGUI.BaseFont
local DynamicFont = Class.inheritsFrom('DynamicFont', nil, BaseFont)

--TODO: FairyGUI.DynamicFont

FairyGUI.DynamicFont = DynamicFont
return DynamicFont