--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 15:54
--

local Class = require('libs.Class')

local GTextField = FairyGUI.GTextField

---@class FairyGUI.GTextInput:FairyGUI.GTextField
local GTextInput = Class.inheritsFrom('GTextInput', nil, GTextField)

--TODO: FairyGUI.GTextInput

FairyGUI.GTextInput = GTextInput
return GTextInput