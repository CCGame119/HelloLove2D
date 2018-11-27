--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:32
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent
local IColorGear = FairyGUI.IColorGear

---@class FairyGUI.GLabel:FairyGUI.GComponent @implement IColorGear
---@field public icon string
---@field public title string
---@field public text string
---@field public editable boolean
---@field public titleColor Love2DEngine.Color
---@field public titleFontSize number
---@field public color Love2DEngine.Color
---@field protected _titleObject FairyGUI.GObject
---@field protected _iconObject FairyGUI.GObject
local GLabel = Class.inheritsFrom('GLabel', nil, GComponent, {IColorGear})

function GLabel:__ctor()
    GComponent.__ctor(self)
end

---@return FairyGUI.GTextField
function GLabel:GetTextField() end

---@param buffer Utils.ByteBuffer
function GLabel:ConstructExtension(buffer) end

function GLabel:Setup_AfterAdd(buffer, beginPos)
end

--TODO: FairyGUI.GLabel

local __get = Class.init_get(GLabel)
local __set = Class.init_set(GLabel)

---@param self FairyGUI.GLabel
__get.icon  = function(self) end

---@param self FairyGUI.GLabel
---@param val string
__set.icon  = function(self, val) end

---@param self FairyGUI.GLabel
__get.title  = function(self) end

---@param self FairyGUI.GLabel
---@param val string
__set.title  = function(self, val) end

---@param self FairyGUI.GLabel
__get.text  = function(self) end

---@param self FairyGUI.GLabel
---@param val string
__set.text  = function(self, val) end

---@param self FairyGUI.GLabel
__get.editable  = function(self) end

---@param self FairyGUI.GLabel
---@param val boolean
__set.editable  = function(self, val) end

---@param self FairyGUI.GLabel
__get.titleColor  = function(self) end

---@param self FairyGUI.GLabel
---@param val Love2DEngine.Color
__set.titleColor  = function(self, val) end

---@param self FairyGUI.GLabel
__get.titleFontSize  = function(self) end

---@param self FairyGUI.GLabel
---@param val number
__set.titleFontSize  = function(self, val) end

---@param self FairyGUI.GLabel
__get.color  = function(self) end

---@param self FairyGUI.GLabel
---@param val Love2DEngine.Color
__set.color  = function(self, val) end


FairyGUI.GLabel = GLabel
return GLabel