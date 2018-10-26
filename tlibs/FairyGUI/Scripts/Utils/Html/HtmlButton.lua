--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:32
--

local Class = require('libs.Class')

local Debug = Love2DEngine.Debug
local GComponent = FairyGUI.GComponent
local RichTextField = FairyGUI.RichTextField
local EventCallback1 = FairyGUI.EventCallback1
local DisplayObject = FairyGUI.DisplayObject
local UIPackage = FairyGUI.UIPackage
local IHtmlObject = Utils.IHtmlObject
local HtmlElement = Utils.HtmlElement

---@class Utils.HtmlButton:Utils.IHtmlObject
---@field public button FairyGUI.GComponent
---@field public CLICK_EVENT string
---@field private _owner FairyGUI.RichTextField
---@field private _element Utils.HtmlElement
---@field private _clickHandler FairyGUI.EventCallback1
local HtmlButton = Class.inheritsFrom('HtmlButton', {CLICK_EVENT = "OnHtmlButtonClick"}, IHtmlObject)

HtmlButton.resource = ''

function HtmlButton:__ctor()
    self._clickHandler = EventCallback1.new()
    if HtmlButton.resource ~= nil then
        self.button = UIPackage.CreateObjectFromURL(HtmlButton.resource).asCom
        
        ---@param self Utils.HtmlButton
        ---@param context FairyGUI.EventContext
        self._clickHandler:Add(function(self, context)  
            self._owner:DispatchEvent(self.CLICK_EVENT, context.data, self)
        end, self)
    else
       Debug.LogWarn('FairyGUI: Set HtmlButton.resource first')
    end
end

---@param owner FairyGUI.RichTextField
---@param element Utils.HtmlElement
function HtmlButton:Create(owner, element)
    self._owner = owner
    self._element = element

    if self.button == nil then
        return
    end

    self.button.onClick:Add(self._clickHandler)
    local width = element:GetInt("width", self.button.sourceWidth)
    local height = element:GetInt("height", self.button.sourceHeight)
    self.button:SetSize(width, height)
    self.button.text = element:GetString("value")

end

---@param x number
---@param y number
function HtmlButton:SetPosition(x, y)
    if self.button ~= nil then
        self.button:SetXY(x, y)
    end
end

function HtmlButton:Add()
    if self.button ~= nil then
        self._owner:AddChild(self.button.displayObject)
    end
end

function HtmlButton:Remove()
    if self.button ~= nil and self.button.displayObject.parent ~= nil then
        self._owner:RemoveChild(self.button.displayObject)
    end
end

function HtmlButton:Release()
    if self.button ~= nil then
        self.button:RemoveEventListeners()
    end
    self._owner = nil
    self._element = nil
end

function HtmlButton:Dispose()
    if self.button ~= nil then
        self.button:Dispose()
    end
end

local __get = Class.init_get(HtmlButton)

---@param self Utils.HtmlButton
__get.displayObject = function(self) return self.button ~= nil and self.button.displayObject or nil end

---@param self Utils.HtmlButton
__get._element = function(self) return self._element end

---@param self Utils.HtmlButton
__get.width = function(self) return self.button ~= nil and self.button.width or 0 end

---@param self Utils.HtmlButton
__get.height = function(self) return self.button ~= nil and self.button.height or 0 end

Utils.HtmlButton = HtmlButton
return HtmlButton