--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:35
--

local Class = require('libs.Class')

local UBBParser = Utils.UBBParser

local GTextField = FairyGUI.GTextField
local RichTextField = FairyGUI.RichTextField

---@class FairyGUI.GRichTextField:FairyGUI.GTextField
---@field public richTextField FairyGUI.RichTextField
---@field public emojies table<number, FairyGUI.Emoji>
local GRichTextField = Class.inheritsFrom('GRichTextField', nil, GTextField)

function GRichTextField:__ctor()
    GTextField.__ctor(self)
end

function GRichTextField:CreateDisplayObject()
    self.richTextField = RichTextField.new()
    self.richTextField.gOwner = self
    self.displayObject = self.richTextField

    self._textField = self.richTextField.textField
end

function GRichTextField:SetTextFieldText()
    local str = self._text
    if (self._templateVars ~= nil) then
        str = self:ParseTemplate(str)
    end

    if (self._ubbEnabled) then
        self.richTextField.htmlText = UBBParser.inst:Parse(str)
    else
        self.richTextField.htmlText = str
    end
end

function GRichTextField:GetTextFieldText()
    self._text = self.richTextField.text
end


local __get = Class.init_get(GRichTextField)
local __set = Class.init_set(GRichTextField)

---@param self FairyGUI.GRichTextField
__get.emojies = function(self) return self.richTextField.emojies end

---@param self FairyGUI.GRichTextField
---@param val table<number, FairyGUI.Emoji>
__set.emojies = function(self, val) self.richTextField.emojies = val end


FairyGUI.GRichTextField = GRichTextField
return GRichTextField