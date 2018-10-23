--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:37
--

local Class = require('libs.Class')

local Container = FairyGUI.Container

---@class FairyGUI.RichTextField:FairyGUI.Container
local RichTextField = Class.inheritsFrom('RichTextField', nil, Container)

--TODO: FairyGUI.RichTextField

FairyGUI.RichTextField = RichTextField
return RichTextField