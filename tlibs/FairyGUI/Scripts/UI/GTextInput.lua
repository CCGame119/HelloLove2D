--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 15:54
--

local Class = require('libs.Class')

local GTextField = FairyGUI.GTextField

---@class FairyGUI.GTextInput:FairyGUI.GTextField
---@field public onFocusIn FairyGUI.EventListener
---@field public onFocusOut FairyGUI.EventListener
---@field public onChanged FairyGUI.EventListener
---@field public onSubmit FairyGUI.EventListener
---@field public editable boolean
---@field public hideInput boolean
---@field public maxLength number
---@field public restrict string
---@field public displayAsPassword boolean
---@field public caretPosition number
---@field public promptText string
---@field public keyboardInput boolean
---@field public keyboardType number
---@field public emojies table<number, FairyGUI.Emoji>
local GTextInput = Class.inheritsFrom('GTextInput', nil, GTextField)

function GTextInput:__ctor()
    GTextField.__ctor(self)
end

---@param start number
---@param lenght number
function GTextInput:SetSelection(start, lenght)

end

---@param value string
function GTextInput:ReplaceSelection(value)

end

function GTextInput:SetTextFieldText()
end

function GTextInput:GetTextFieldText()
end

function GTextInput:CreateDisplayObject()
end

function GTextInput:Setup_BeforeAdd(buffer, beginPos)
end

--TODO: FairyGUI.GTextInput

local __get = Class.init_get(GTextInput)
local __set = Class.init_set(GTextInput)

---@param self FairyGUI.GTextInput
__get.editable = function(self) end

---@param self FairyGUI.GTextInput
---@param val boolean
__set.editable = function(self, val) end

---@param self FairyGUI.GTextInput
__get.hideInput = function(self) end

---@param self FairyGUI.GTextInput
---@param val boolean
__set.hideInput = function(self, val) end

---@param self FairyGUI.GTextInput
__get.maxLength = function(self) end

---@param self FairyGUI.GTextInput
---@param val number
__set.maxLength = function(self, val) end

---@param self FairyGUI.GTextInput
__get.restrict = function(self) end

---@param self FairyGUI.GTextInput
---@param val string
__set.restrict = function(self, val) end

---@param self FairyGUI.GTextInput
__get.displayAsPassword = function(self) end

---@param self FairyGUI.GTextInput
---@param val boolean
__set.displayAsPassword = function(self, val) end

---@param self FairyGUI.GTextInput
__get.caretPosition = function(self) end

---@param self FairyGUI.GTextInput
---@param val number
__set.caretPosition = function(self, val) end

---@param self FairyGUI.GTextInput
__get.promptText = function(self) end

---@param self FairyGUI.GTextInput
---@param val string
__set.promptText = function(self, val) end

---@param self FairyGUI.GTextInput
__get.keyboardInput = function(self) end

---@param self FairyGUI.GTextInput
---@param val boolean
__set.keyboardInput = function(self, val) end

---@param self FairyGUI.GTextInput
__get.keyboardType = function(self) end

---@param self FairyGUI.GTextInput
---@param val number
__set.keyboardType = function(self, val) end

---@param self FairyGUI.GTextInput
__get.emojies = function(self) end

---@param self FairyGUI.GTextInput
---@param val string<number, FairyGUI.Emoji>
__set.emojies = function(self, val) end


FairyGUI.GTextInput = GTextInput
return GTextInput