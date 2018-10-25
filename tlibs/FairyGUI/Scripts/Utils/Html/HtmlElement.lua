--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 14:47
--

local Class = require('libs.Class')
local Pool = require('libs.Pool')

local Vector2 = Love2DEngine.Vector2
local TextFormat = FairyGUI.TextFormat
local ToolSet = FairyGUI.ToolSet
local IHtmlObject = Utils.IHtmlObject
local XMLIterator = Utils.XMLIterator

---@class Utils.HtmlElementType:enum
local HtmlElementType =  {
    Text = 0,
    Link = 1,
    Image = 2,
    Input = 3,
    Select = 4,
    Object = 5,
    --internal
    LinkEnd = 6,
}

---@class Utils.HtmlElement:ClassType
---@field public type Utils.HtmlElementType
---@field public name string
---@field public text string
---@field public format FairyGUI.TextFormat
---@field public charIndex number
---@field public htmlObject Utils.IHtmlObject
---@field public status  number @1 hidden 2 clipped 4 added
---@field public space number
---@field public position Love2DEngine.Vector2
---@field private attributes table<any, any>
local HtmlElement = Class.inheritsFrom('HtmlElement')

function HtmlElement:__ctor()
    self.format = TextFormat.new()
end

---@param attrName string
---@return any
function HtmlElement:Get(attrName)
    if self.attributes == nil then
        return nil
    end
    return attributes[attrName]
end

---@param attrName string
---@param attrValue any
function HtmlElement:Set(attrName, attrValue)
    if self.attributes ==  nil then
        self.attributes = {}
    end
    self.attributes[attrName] = attrValue
end

---@param attrName string
---@param defValue string
---@return string
function HtmlElement:GetString(attrName, defValue)
    if self.attributes == nil then
        return nil
    end
    local defValue = defValue or nil
    local ret = self.attributes[attrName]
    if nil ~= ret then
        return tostring(ret)
    end
    return defValue
end

---@param attrName string
---@param defValue number
---@return number
function HtmlElement:GetInt(attrName, defValue)
    local defValue = defValue or 0
    local value = self:GetString(attrName)
    if value == nil or string.len(value) == 0 then
        return defValue
    end

    local ret
    local len = #value
    local j = value[len] == '%' and len - 1 or len
    ret = tonumber(string.sub(value, 1, j))
    return ret ~= nil and ret or defValue
end

HtmlElement.GetFloat = HtmlElement.GetInt

---@param attrName string
---@param defValue boolean
---@return boolean
function HtmlElement:GetBool(attrName, defValue)
    local defValue = defValue or false
    local value = self:GetString(attrName)
    if value == nil or string.len(value) == 0 then
        return defValue
    end

    value = string.lower(value)
    if value == 'true' then
        return true
    end
    if value == 'false' then
        return false
    end
    return defValue
end

---@param attrName string
---@param defValue Love2DEngine.Color
---@return Love2DEngine.Color
function HtmlElement:GetColor(attrName, defValue)
    local value = self:GetString(attrName)
    if value == nil or string.len(value) == 0 then
        return defValue
    end

    return ToolSet.ConvertFromHtmlColor(value)
end

function HtmlElement:FetchAttributes()
    self.attributes = XMLIterator.GetAttributes(self.attributes)
end

HtmlElement.elementPool = Pool.new(HtmlElement)

---@param type Utils.HtmlElementType
---@return Utils.HtmlElement
function HtmlElement.GetElement(type)
    local ret
    if HtmlElement.elementPool.count > 0 then
        ret = HtmlElement.elementPool:pop()
    else
        ret = HtmlElement.new()
    end
    ret.type = type

    if type ~= HtmlElementType.Text and ret.attributes == nil then
        ret.attributes = {}
    end
    return ret
end

---@param element Utils.HtmlElement
function HtmlElement.ReturnElement(element)
    element.name = nil
    element.text = nil
    element.htmlObject = nil
    element.status = 0
    if element.attributes ~= nil then
        element.attributes = {}
    end
    HtmlElement.elementPool:push(element)
end

---@param elements Utils.HtmlElement[]
function HtmlElement.ReturnElements(elements)
    local count = #elements
    for i = count, 1, -1 do
        local element = table.remove(elements, i)
        HtmlElement.ReturnElement(element)
    end
end

local __get = Class.init_get(HtmlElement)

---@param self Utils.HtmlElement
__get = function(self)
    return self.type == HtmlElementType.Image or self.type == HtmlElementType.Select or
            self.type == HtmlElementType.Input or self.type == HtmlElementType.Object
end

Utils.HtmlElementType = HtmlElementType
Utils.HtmlElement = HtmlElement
return HtmlElement