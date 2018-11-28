--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 15:54
--

local Class = require('libs.Class')

local GTextField = FairyGUI.GTextField
local InputTextField = FairyGUI.InputTextField
local EventListener = FairyGUI.EventListener
local AutoSizeType = FairyGUI.AutoSizeType

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

    self.onFocusIn = EventListener.new(self, "onFocusIn")
    self.onFocusOut = EventListener.new(self, "onFocusOut")
    self.onChanged = EventListener.new(self, "onChanged")
    self.onSubmit = EventListener.new(self, "onSubmit")

    self.focusable = true
    self._textField.autoSize = AutoSizeType.None
    self._textField.wordWrap = false
end

---@param start number
---@param length number
function GTextInput:SetSelection(start, length)
    self.inputTextField:SetSelection(start, length);
end

---@param value string
function GTextInput:ReplaceSelection(value)
    self.inputTextField:ReplaceSelection(value)
end

function GTextInput:SetTextFieldText()
    self.inputTextField.text = self._text
end

function GTextInput:GetTextFieldText()
    self._text = self.inputTextField.text
end

function GTextInput:CreateDisplayObject()
    self.inputTextField = InputTextField.new()
    self.inputTextField.gOwner = self
    self.displayObject = self.inputTextField

    self._textField = self.inputTextField.textField
end

function GTextInput:Setup_BeforeAdd(buffer, beginPos)
    GTextField.Setup_BeforeAdd(self, buffer, beginPos)

    local inputTextField = self.inputTextField

    buffer:Seek(beginPos, 4)

    local str = buffer:ReadS()
    if (str ~= nil) then
        inputTextField.promptText = str
    end

    str = buffer:ReadS()
    if (str ~= nil) then
        inputTextField.restrict = str
    end

    local iv = buffer:ReadInt()
    if (iv ~= 0) then
        inputTextField.maxLength = iv
    end
    iv = buffer:ReadInt()
    if (iv ~= 0) then
        inputTextField.keyboardType = iv
    end
    if (buffer:ReadBool()) then
        inputTextField.displayAsPassword = true
    end
end


local __get = Class.init_get(GTextInput)
local __set = Class.init_set(GTextInput)

---@param self FairyGUI.GTextInput
__get.editable = function(self) return self.inputTextField.editable end

---@param self FairyGUI.GTextInput
---@param val boolean
__set.editable = function(self, val) self.inputTextField.editable = val end

---@param self FairyGUI.GTextInput
__get.hideInput = function(self) return self.inputTextField.hideInput end

---@param self FairyGUI.GTextInput
---@param val boolean
__set.hideInput = function(self, val) self.inputTextField.hideInput = val end

---@param self FairyGUI.GTextInput
__get.maxLength = function(self) return self.inputTextField.maxLength end

---@param self FairyGUI.GTextInput
---@param val number
__set.maxLength = function(self, val) self.inputTextField.maxLength = val end

---@param self FairyGUI.GTextInput
__get.restrict = function(self) return self.inputTextField.restrict end

---@param self FairyGUI.GTextInput
---@param val string
__set.restrict = function(self, val) self.inputTextField.restrict = val end

---@param self FairyGUI.GTextInput
__get.displayAsPassword = function(self) return self.inputTextField.displayAsPassword end

---@param self FairyGUI.GTextInput
---@param val boolean
__set.displayAsPassword = function(self, val) self.inputTextField.displayAsPassword = val end

---@param self FairyGUI.GTextInput
__get.caretPosition = function(self) return self.inputTextField.caretPosition end

---@param self FairyGUI.GTextInput
---@param val number
__set.caretPosition = function(self, val) self.inputTextField.caretPosition = val end

---@param self FairyGUI.GTextInput
__get.promptText = function(self) return self.inputTextField.promptText end

---@param self FairyGUI.GTextInput
---@param val string
__set.promptText = function(self, val) self.inputTextField.promptText = val end

---@param self FairyGUI.GTextInput
__get.keyboardInput = function(self) return self.inputTextField.keyboardInput end

---@param self FairyGUI.GTextInput
---@param val boolean
__set.keyboardInput = function(self, val) self.inputTextField.keyboardInput = val end

---@param self FairyGUI.GTextInput
__get.keyboardType = function(self) return self.inputTextField.keyboardType end

---@param self FairyGUI.GTextInput
---@param val number
__set.keyboardType = function(self, val) self.inputTextField.keyboardType = val end

---@param self FairyGUI.GTextInput
__get.emojies = function(self) return self.inputTextField.emojies end

---@param self FairyGUI.GTextInput
---@param val string<number, FairyGUI.Emoji>
__set.emojies = function(self, val) self.inputTextField.emojies = val end


FairyGUI.GTextInput = GTextInput
return GTextInput