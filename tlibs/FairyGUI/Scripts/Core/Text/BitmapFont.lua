--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:20
--

local Class = require('libs.Class')

local BaseFont = FairyGUI.BaseFont

---@class FairyGUI.BitmapFont:FairyGUI.BaseFont
local BitmapFont = Class.inheritsFrom('BitmapFont', nil, BaseFont)

--TODO: FairyGUI.BitmapFont

FairyGUI.BitmapFont = BitmapFont
return BitmapFont