--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:23
--

local Class = require('libs.Class')

local IHtmlObject = Utils.HtmlElement

---@class Utils.HtmlSelect:Utils.IHtmlObject
local HtmlSelect = Class.inheritsFrom('HtmlSelect', nil, IHtmlObject)

--TODO: Utils.HtmlSelect

Utils.HtmlSelect = HtmlSelect
return HtmlSelect