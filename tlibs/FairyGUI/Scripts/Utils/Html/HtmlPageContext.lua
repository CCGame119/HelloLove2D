--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:27
--

local Class = require('libs.Class')

local IHtmlPageContext = Utils.IHtmlPageContext

---@class Utils.HtmlPageContext:Utils.IHtmlPageContext
local HtmlPageContext = Class.inheritsFrom('HtmlPageContext', nil, IHtmlPageContext)

--TODO: Utils.HtmlPageContext

Utils.HtmlPageContext = HtmlPageContext
return HtmlPageContext