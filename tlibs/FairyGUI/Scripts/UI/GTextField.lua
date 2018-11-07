--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 15:56
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local ITextColorGear = FairyGUI.ITextColorGear

---@class FairyGUI.GTextField:FairyGUI.GObject @implement FairyGUI.ITextColorGear
---@field public color Love2DEngine.Color
---@field public strokeColor Love2DEngine.Color
local GTextField = Class.inheritsFrom('GTextField', nil, GObject, {ITextColorGear})

--TODO: FairyGUI.GTextField

FairyGUI.GTextField = GTextField
return GTextField