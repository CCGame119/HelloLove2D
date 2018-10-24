--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:23
--

local Class = require('libs.Class')

local Debug = Love2DEngine.Debug
local GComboBox = FairyGUI.GComboBox
local RichTextField = FairyGUI.RichTextField
local EventCallback0 = FairyGUI.EventCallback0
local IHtmlObject = Utils.HtmlElement

---@class Utils.HtmlSelect:Utils.IHtmlObject
---@field public comboBox FairyGUI.GComboBox
---@field public CHANGED_EVENT string
---@field private _owner FairyGUI.RichTextField
---@field private _element Utils.HtmlElement
---@field private _changeHandler FairyGUI.EventCallback0
local HtmlSelect = Class.inheritsFrom('HtmlSelect', {CHANGED_EVENT = 'OnHtmlSelectChanged'}, IHtmlObject)

HtmlSelect.resource = ''

function HtmlSelect:__ctor()
    self._changeHandler = EventCallback0.new()
    if self.resource ~= nil then
        self.comboBox = UIPackage.CreateObjectFromURL(HtmlSelect.resource).asComboBox
        self._changeHandler:Add(function(self)
            self._owner:DispatchEvent(HtmlSelect.CHANGED_EVENT, nil, self)
        end, self)
    else
        Debug.LogWarn("FairyGUI: Set HtmlSelect.resource first")
    end
end

---@param owner FairyGUI.RichTextField
---@param element Utils.HtmlElement
function HtmlSelect:Create(owner, element)
    self._owner = owner
    self._element = element

    if self.comboBox ~= nil then
        return
    end

    self.comboBox.onChanged:Add(self._changeHandler)

    local width = element:GetInt('width', self.comboBox.sourceWidth)
    local height = element:GetInt('height', self.comboBox.sourceHeight)
    self.comboBox:SetSize(width, height)
    self.comboBox.items = element:Get('items')
    self.comboBox.values = element:Get('values')
    self.comboBox.value = element:GetString('value')
end

---@param x number
---@param y number
function HtmlSelect:SetPosition(x, y)
    if self.comboBox ~= nil then
        self.comboBox:SetXY(x, y)
    end
end

function HtmlSelect:Add()
    if self.comboBox ~= nil then
        self._owner:AddChild(self.comboBox.displayObject)
    end
end

function HtmlSelect:Remove()
    if self.comboBox ~= nil and self.comboBox.displayObject.parent ~= nil then
        self._owner:RemoveChild(self.comboBox.displayObject)
    end
end

function HtmlSelect:Release()
    if self.comboBox ~= nil then
        self.comboBox:RemoveEventListeners()
    end

    self._owner = nil
    self._element = nil
end

function HtmlSelect:Dispose()
    if self.comboBox ~= nil then
        self.comboBox:Dispose()
    end
end

local __get = Class.init_get(HtmlSelect)
local __set = Class.init_set(HtmlSelect)

---@param self Utils.HtmlSelect
__get.displayObject = function(self) return self.comboBox.displayObject end

---@param self Utils.HtmlSelect
__get.element = function(self) return self._element end

---@param self Utils.HtmlSelect
__get.width = function(self) return self.comboBox ~= nil and self.comboBox.width or 0 end

---@param self Utils.HtmlSelect
__get.height = function(self) return self.comboBox ~= nil and self.comboBox.height or 0 end


Utils.HtmlSelect = HtmlSelect
return HtmlSelect