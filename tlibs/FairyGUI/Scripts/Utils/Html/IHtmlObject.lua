--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:01
--

local Class = require('libs.Class')

---@class Utils.IHtmlObject:ClassType
---@field public width number
---@field public height number
---@field public displayObject FairyGUI.DisplayObject
---@field public element Utils.HtmlElement
local IHtmlObject = Class.inheritsFrom('IHtmlObject')

---@param owner FairyGUI.RichTextField
---@param element Utils.HtmlElement
function IHtmlObject:Create(owner, element) end

---@param x number
---@param y number
function IHtmlObject:SetPosition(x, y) end

function IHtmlObject:Add() end
function IHtmlObject:Remove() end
function IHtmlObject:Release() end
function IHtmlObject:Dispose() end

Utils.IHtmlObject = IHtmlObject
return IHtmlObject