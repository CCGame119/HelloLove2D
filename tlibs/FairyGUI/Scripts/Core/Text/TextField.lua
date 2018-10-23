--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 14:56
--

local Class = require('libs.Class')
require('Utils.Html.HtmlElement')

local DisplayObject = FairyGUI.DisplayObject

---@class FairyGUI.TextField:FairyGUI.DisplayObject
local TextField = Class.inheritsFrom('TextField', nil, DisplayObject)

--TODO: FairyGUI.TextField

FairyGUI.TextField = TextField
return TextField