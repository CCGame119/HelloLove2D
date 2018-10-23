--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:25
--

local Class = require('libs.Class')

local Color32 = Love2DEngine.Color32
local Color = Love2DEngine.Color

---@class Utils.HtmlParseOptions:ClassType
---@field public linkUnderline boolean
---@field public linkColor Love2DEngine.Color
---@field public linkBgColor Love2DEngine.Color
---@field public linkHoverBgColor Love2DEngine.Color
---@field public ignoreWhiteSpace boolean
local HtmlParseOptions = Class.inheritsFrom('HtmlParseOptions')

HtmlParseOptions.DefaultLinkUnderline = true
HtmlParseOptions.DefaultLinkColor = Color32(0x3A, 0x67, 0xCC, 0xFF)
HtmlParseOptions.DefaultLinkBgColor = Color.clear
HtmlParseOptions.DefaultLinkHoverBgColor = Color.clear

function HtmlParseOptions:__ctor()
    self.linkUnderline = HtmlParseOptions.DefaultLinkUnderline;
    self.linkColor = HtmlParseOptions.DefaultLinkColor;
    self.linkBgColor = HtmlParseOptions.DefaultLinkBgColor;
    self.linkHoverBgColor = HtmlParseOptions.DefaultLinkHoverBgColor;
end

Utils.HtmlParseOptions = HtmlParseOptions
return HtmlParseOptions