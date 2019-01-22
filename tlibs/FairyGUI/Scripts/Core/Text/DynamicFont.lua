--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:23
--

local Class = require('libs.Class')

local BaseFont = FairyGUI.BaseFont

---@class FairyGUI.DynamicFont.RenderInfo:ClassType
---@field public yIndent number @越大，字显示越偏下
---@field public height number
local RenderInfo = Class.inheritsFrom('RenderInfo')

---@class FairyGUI.DynamicFont:FairyGUI.BaseFont
---@field protected _font love.Object.Font
---@field protected _renderInfo table<number, FairyGUI.DynamicFont.RenderInfo>
---@field private lastRenderInfo FairyGUI.DynamicFont.RenderInfo
---@field private lastFontSize int
---@field private size int
---@field private style Love2DEngine.FontStyle
local DynamicFont = Class.inheritsFrom('DynamicFont', nil, BaseFont)


--TODO: FairyGUI.DynamicFont

FairyGUI.DynamicFont = DynamicFont
return DynamicFont