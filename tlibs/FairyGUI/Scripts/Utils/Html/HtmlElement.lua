--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 14:47
--

local Class = require('libs.Class')

---@class Utils.HtmlElementType:enum
local HtmlElementType =  {
    Text = 0,
    Link = 1,
    Image = 2,
    Input = 3,
    Select = 4,
    Object = 5,
    --internal
    LinkEnd = 6,
}

---@class Utils.HtmlElement:ClassType
local HtmlElement = Class.inheritsFrom('HtmlElement')

--TODO: FairyGUI.Utils.HtmlElement

Utils.HtmlElementType = HtmlElementType
Utils.HtmlElement = HtmlElement
return HtmlElement