--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:28
--

local Class = require('libs.Class')

local EventCallback0 = FairyGUI.EventCallback0
local EventCallback1 = FairyGUI.EventCallback1
local RichTextField = FairyGUI.RichTextField
local SelectionShape = FairyGUI.SelectionShape
local IHtmlObject = Utils.IHtmlObject
local IHtmlObject = Utils.HtmlElement

---@class Utils.HtmlLink:Utils.IHtmlObject
---@field private _owner FairyGUI.RichTextField
---@field private _element Utils.HtmlElement
---@field private _shape FairyGUI.SelectionShape
---@field private _clickHandler FairyGUI.EventCallback1
---@field private _rolloverHandler FairyGUI.EventCallback1
---@field private _rolloutHandler FairyGUI.EventCallback0
local HtmlLink = Class.inheritsFrom('HtmlLink', nil, IHtmlObject)

function HtmlLink:__ctor()
    self._shape = SelectionShape.new()
    self._shape.gameObject.name = "HtmlLink"

    self._clickHandler = EventCallback1.new()
    self._rolloverHandler = EventCallback1.new()
    self._rolloutHandler = EventCallback0.new()

    ---@param self Utils.HtmlLink
    ---@param context FairyGUI.EventContext
    self._clickHandler:Add(function(self, context)
        self._owner.onClickLink:BubbleCall(self._element:GetString('href'))
    end, self)

    ---@param self Utils.HtmlLink
    ---@param context FairyGUI.EventContext
    self._rolloverHandler:Add(function(self, context)
        if self._owner.htmlParseOptions.linkHoverBgColor.a > 0 then
            self._shape.color = self._owner.htmlParseOptions.linkHoverBgColor
        end
    end, self)

    ---@param self Utils.HtmlLink
    self._rolloutHandler:Add(function(self)
        if self._owner.htmlParseOptions.linkHoverBgColor.a > 0 then
            self._shape.color = self._owner.htmlParseOptions.linkBgColor
        end
    end, self)
end

---@param owner FairyGUI.RichTextField
---@param element Utils.HtmlElement
function HtmlLink:Create(owner, element)
    self._owner = owner
    self._element = element
    self._shape.onClick:Add(self._clickHandler)
    self._shape.onRollOver:Add(self._rolloverHandler)
    self._shape.onRollOut:Add(self._rolloutHandler)
    self._shape.color = self._owner.htmlParseOptions.linkBgColor
end

function HtmlLink:SetArea(startLine, startCharX, endLine, endCharX)
    local rects = self._shape.rects
    rects = {}

    if startLine == endLine and startCharX > endCharX then
         local tmp = startCharX
        startCharX = endCharX
        endCharX = tmp
    end
    self._owner.textField:GetLinesShape(startLine, startCharX, endLine, endCharX, true, rects)
    self._shape.rects = rects
end

---@param x number
---@param y number
function HtmlLink:SetPosition(x, y)
    self._shape:SetXY(x, y)
end

function HtmlLink:Add()
    self._owner:AddChildAt(self._shape, 1)
end

function HtmlLink:Remove()
    if self._shape.parent ~= nil then
        self._owner:RemoveChild(self._shape)
    end
end

function HtmlLink:Release()
    self._shape:RemoveEventListeners()

    self._owner = nil
    self._element = nil
end

function HtmlLink:Dispose()
    self._shape:Dispose()
    self._shape = nil
end

local __get = Class.init_get(HtmlLink)

---@param self Utils.HtmlLink
__get.displayObject = function(self)
    return self._shape
end

---@param self Utils.HtmlLink
__get.element = function(self)
    return self._element
end

---@param self Utils.HtmlLink
__get.width = function(self)
    return 0
end

---@param self Utils.HtmlLink
__get.height = function(self)
    return 0
end

Utils.HtmlLink = HtmlLink
return HtmlLink