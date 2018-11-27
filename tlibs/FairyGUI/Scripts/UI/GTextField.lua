--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 15:56
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local ITextColorGear = FairyGUI.ITextColorGear

---@class FairyGUI.GTextField:FairyGUI.GObject @implement FairyGUI.ITextColorGear
---@field public text string
---@field public templateVars table<string, string>
---@field public textFormat FairyGUI.TextFormat
---@field public color Love2DEngine.Color
---@field public align FairyGUI.AlignType
---@field public verticalAlign FairyGUI.VertAlignType
---@field public singleLine boolean
---@field public stroke number
---@field public strokeColor Love2DEngine.Color
---@field public shadowOffset Love2DEngine.Vector2
---@field public UBBEnabled boolean
---@field public autoSize FairyGUI.AutoSizeType
---@field public textWidth number
---@field public textHeight number
---@field protected _textField FairyGUI.TextField
---@field protected _text string
---@field protected _ubbEnabled boolean
---@field protected _updatingSize boolean
---@field protected _templateVars table<string, string>
local GTextField = Class.inheritsFrom('GTextField', nil, GObject, {ITextColorGear})

function GTextField:__ctor()
    GObject.__ctor(self)
end

function GTextField:CreateDisplayObject()
end

function GTextField:SetTextFieldText()

end

function GTextField:GetTextFieldText()

end

---@param name string
---@param value string
function GTextField:SetVar(name, value)

end

function GTextField:FlushVars()

end

function GTextField:ParseTemplate(template)

end

function GTextField:UpdateSize()
    
end

function GTextField:HandleSizeChanged()
end

function GTextField:Setup_BeforeAdd(buffer, beginPos)
end

function GTextField:Setup_AfterAdd(buffer, beginPos)
end

--TODO: FairyGUI.GTextField

local __get = Class.init_get(GTextField)
local __set = Class.init_set(GTextField)

---@param self FairyGUI.GTextField
__get.text = function(self) end

---@param self FairyGUI.GTextField
---@param val string
__set.text = function(self, val) end

---@param self FairyGUI.GTextField
__get.textFormat = function(self) end

---@param self FairyGUI.GTextField
---@param val FairyGUI.TextFormat
__set.textFormat = function(self, val) end

---@param self FairyGUI.GTextField
__get.color = function(self) end

---@param self FairyGUI.GTextField
---@param val Love2DEngine.Color
__set.color = function(self, val) end

---@param self FairyGUI.GTextField
__get.align = function(self) end

---@param self FairyGUI.GTextField
---@param val FairyGUI.AlignType
__set.align = function(self, val) end

---@param self FairyGUI.GTextField
__get.verticalAlign = function(self) end

---@param self FairyGUI.GTextField
---@param val FairyGUI.VertAlignType
__set.verticalAlign = function(self, val) end

---@param self FairyGUI.GTextField
__get.singleLine = function(self) end

---@param self FairyGUI.GTextField
---@param val boolean
__set.singleLine = function(self, val) end

---@param self FairyGUI.GTextField
__get.stroke = function(self) end

---@param self FairyGUI.GTextField
---@param val number
__set.stroke = function(self, val) end

---@param self FairyGUI.GTextField
__get.strokeColor = function(self) end

---@param self FairyGUI.GTextField
---@param val Love2DEngine.Color
__set.strokeColor = function(self, val) end

---@param self FairyGUI.GTextField
__get.shadowOffset = function(self) end

---@param self FairyGUI.GTextField
---@param val Love2DEngine.Vector2
__set.shadowOffset = function(self, val) end

---@param self FairyGUI.GTextField
__get.UBBEnabled = function(self) end

---@param self FairyGUI.GTextField
---@param val boolean
__set.UBBEnabled = function(self, val) end

---@param self FairyGUI.GTextField
__get.autoSize = function(self) end

---@param self FairyGUI.GTextField
---@param val FairyGUI.AutoSizeType
__set.autoSize = function(self, val) end

---@param self FairyGUI.GTextField
__get.textWidth = function(self) end

---@param self FairyGUI.GTextField
---@param val number
__set.textWidth = function(self, val) end

---@param self FairyGUI.GTextField
__get.textHeight = function(self) end

---@param self FairyGUI.GTextField
---@param val number
__set.textHeight = function(self, val) end


FairyGUI.GTextField = GTextField
return GTextField