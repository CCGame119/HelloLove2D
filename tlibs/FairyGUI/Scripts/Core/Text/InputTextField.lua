--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:05
--

local Class = require('libs.Class')

local RichTextField = FairyGUI.RichTextField

---@class FairyGUI.InputTextField:FairyGUI.DisplayObject
local InputTextField = Class.inheritsFrom('InputTextField', nil, RichTextField)

--TODO: FairyGUI.InputTextField

FairyGUI.InputTextField = InputTextField
return InputTextField