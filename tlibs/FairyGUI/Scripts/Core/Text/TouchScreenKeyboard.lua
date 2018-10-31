--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:03
--

local Class = require('libs.Class')

local IKeyBorad = FairyGUI.IKeyBorad

---@class FairyGUI.TouchScreenKeyboard:FairyGUI.IKeyBorad
local TouchScreenKeyboard = Class.inheritsFrom('TouchScreenKeyboard', nil, IKeyBorad)

--TODO: FairyGUI.TouchScreenKeyboard

FairyGUI.TouchScreenKeyboard = TouchScreenKeyboard
return TouchScreenKeyboard