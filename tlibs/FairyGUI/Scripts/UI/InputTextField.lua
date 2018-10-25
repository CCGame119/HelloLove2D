--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 16:26
--

local Class = require('libs.Class')

local RichTextField = FairyGUI.RichTextField

---@class FairyGUI.InputTextField:FairyGUI.RichTextField
local InputTextField = Class.inheritsFrom('InputTextField', nil, RichTextField)

--TODO: FairyGUI.InputTextField

FairyGUI.InputTextField = InputTextField
return InputTextField