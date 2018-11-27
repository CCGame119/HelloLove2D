--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:35
--

local Class = require('libs.Class')

local GTextField = FairyGUI.GTextField

---@class FairyGUI.GRichTextField:FairyGUI.GTextField
---@field public richTextField FairyGUI.RichTextField
---@field public emojies table<number, FairyGUI.Emoji>
local GRichTextField = Class.inheritsFrom('GRichTextField', nil, GTextField)

function GRichTextField:__ctor()
    GTextField.__ctor(self)
end

function GRichTextField:CreateDisplayObject()
end

function GRichTextField:SetTextFieldText()
end

function GRichTextField:GetTextFieldText()
end

--TODO: FairyGUI.GRichTextField

local __get = Class.init_get(GRichTextField)
local __set = Class.init_set(GRichTextField)

---@param self FairyGUI.GRichTextField
__get.emojies = function(self) end

---@param self FairyGUI.GRichTextField
---@param val table<number, FairyGUI.Emoji>
__set.emojies = function(self, val) end


FairyGUI.GRichTextField = GRichTextField
return GRichTextField