--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:29
--

local Class = require('libs.Class')

local Color = Love2DEngine.Color
local GTextInput = FairyGUI.GTextInput
local RichTextField = FairyGUI.RichTextField
local Shape = FairyGUI.Shape
local ToolSet = Utils.ToolSet
local UIObjectFactory = FairyGUI.UIObjectFactory
local ObjectType = FairyGUI.ObjectType
local VertAlignType = FairyGUI.VertAlignType
local DisplayObject = FairyGUI.DisplayObject
local IHtmlObject = Utils.IHtmlObject
local HtmlElement = Utils.HtmlElement

---@class Utils.HtmlInput:Utils.IHtmlObject
---@field public textInput FairyGUI.GTextInput
---@field private _owner FairyGUI.RichTextField
---@field private _element Utils.HtmlElement
---@field private _hidden boolean
---@field private _border FairyGUI.Shape
---@field private _borderSize number
local HtmlInput = Class.inheritsFrom('HtmlInput', nil, IHtmlObject)

HtmlInput.defaultBorderSize = 2
HtmlInput.defaultBorderColor = ToolSet.ColorFromRGB(0xA9A9A9)

function HtmlInput:__ctor()
    self.textInput = UIObjectFactory.NewObject(ObjectType.InputText)
    self.textInput.gameObjectName = "HtmlInput"
    self.textInput.verticalAlign = VertAlignType.Middle

    self._border = Shape.new()
    self._border.graphics.dontClip = true
    ---@type FairyGUI.InputTextField
    local inputTextField = self.textInput.displayObject
    inputTextField:AddChildAt(self._border, 1)
end

---@param owner FairyGUI.RichTextField
---@param element Utils.HtmlElement
function HtmlInput:Create(owner, element)
    self._owner = owner
    self._element = element

    local type = element:GetString('type')
    if type ~= nil then
        type = string.lower(type)
    end

    self._hidden = type == 'hidden'
    if not self._hidden then
        local width = element:GetInt('width', 0)
        local height = element:GetInt('height', 0)
        self._borderSize = element:GetInt('border', HtmlInput.defaultBorderSize)
        local borderColor = element:GetColor('border-color', HtmlInput.defaultBorderSize)

        if width == 0 then
            width = element.space
            if width > self._owner.width / 2 or width < 100 then
                 width = self._owner.width / 2
            end
        end
        if height == 0 then
            height = element.format.size + 10 + self._borderSize * 2
        end

        self.textInput.textFormat = element.format
        self.textInput.displayAsPassword = type == "password"
        self.textInpu:SetSize(width - self._borderSize * 2, height - self._borderSize * 2)
        self.textInput.maxLength = element.GetInt("maxlength", int.MaxValue)

        self._border:SetXY(-self._borderSize, -self._borderSize)
        self._border:SetSize(width, height)
        self._border:DrawRect(self._borderSize, borderColor, Color(0, 0, 0, 0))
    end
    self.textInput.text = element:GetString('value')
end

---@param x number
---@param y number
function HtmlInput:SetPosition(x, y)
    if not self._hidden then
        self.textInput:SetXY(x + self._borderSize, y + self._borderSize)
    end
end

function HtmlInput:Add()
    if not self._hidden then
        self._owner:AddChild(self.textInput.displayObject)
    end
end

function HtmlInput:Remove()
    if not self._hidden and self.textInput.displayObject.parent ~= nil then
        self._owner:RemoveChild(self.textInput.displayObject)
    end
end

function HtmlInput:Release()
    self.textInput:RemoveEventListeners()
    self.textInput.text = nil

    self._owner = nil
    self._element = nil
end

function HtmlInput:Dispose()
    self.textInput:Dispose()
end


local __get = Class.init_get(HtmlInput)
local __set = Class.init_set(HtmlInput)

---@param self Utils.HtmlInput
__get.displayObject = function(self)
    return self.textInput.displayObject
end

---@param self Utils.HtmlInput
__get.element = function(self)
    return self._element
end

---@param self Utils.HtmlInput
__get.width = function(self)
    return self._hidden and 0 or self._border.width
end

---@param self Utils.HtmlInput
__get.height = function(self)
    return self._hidden and 0 or self._border.height
end

Utils.HtmlInput = HtmlInput
return HtmlInput