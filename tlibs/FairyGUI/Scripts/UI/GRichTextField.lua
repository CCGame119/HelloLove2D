--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:35
--

local Class = require('libs.Class')

local GTextField = FairyGUI.GTextField

---@class FairyGUI.GRichTextField:FairyGUI.GTextField
local GRichTextField = Class.inheritsFrom('GRichTextField', nil, GTextField)

--TODO: FairyGUI.GRichTextField

FairyGUI.GRichTextField = GRichTextField
return GRichTextField