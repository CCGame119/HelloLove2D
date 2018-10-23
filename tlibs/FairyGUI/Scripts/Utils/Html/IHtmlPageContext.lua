--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:21
--

local Class = require('libs.Class')

---@class Utils.IHtmlPageContext:ClassType
local IHtmlPageContext = Class.inheritsFrom('IHtmlPageContext')

---@param owner FairyGUI.RichTextField
---@param element Utils.HtmlElement
---@return Utils.IHtmlObject
function IHtmlPageContext:CreateObject(owner, element) end

---@param obj Utils.IHtmlObject
function IHtmlPageContext:FreeObject(obj) end

---@param image Utils.HtmlImage
function IHtmlPageContext:GetImageTexture(image) end

---@param image Utils.HtmlImage
---@param texture FairyGUI.NTexture
function IHtmlPageContext:FreeImageTexture(image, texture) end

Utils.IHtmlPageContext = IHtmlPageContext
return IHtmlPageContext