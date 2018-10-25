--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 11:32
--

local Class = require('libs.Class')
local Stack = require('libs.Pool')

local Vector2 = Love2DEngine.Vector2
local ToolSet = FairyGUI.ToolSet
local XMLList = Utils.XMLList
local XMLIterator = Utils.XMLIterator
local XMLTagType = Utils.XMLTagType

---@class Utils.XML:ClassType
---@field public name string
---@field public text string
---@field private _attributes table<string, string>
---@field private _children Utils.XMLList
local XML = Class.inheritsFrom('XML')

---@param text string
function XML:__ctor(text)
    assert(nil ~= text, "Param: text is nil")
    self:Parse(text)
end

---@param attrName string
---@return boolean
function XML:HasAttribute(attrName)
    if self._attributes == nil then
        return false
    end
    return self._attributes[attrName] ~= nil
end

---@param attrName string
---@param defValue string
---@return string
function XML:GetAttribute(attrName, defValue)
    if self._attributes == nil then
        return defValue
    end

    local ret = self._attributes[attrName]
    if nil == ret then
       return defValue
    end
    return ret
end

---@param attrName string
---@param defValue string
---@return number
function XML:GetAttributeInt(attrName, defValue)
    defValue = defValue or 0
    local value = self:GetAttribute(attrName)
    if value == nil or string.len(value) == 0 then
        return defValue
    end

    local ret = tonumber(value)
    if nil == ret then
        return defValue
    end
    return ret
end

XML.GetAttributeFloat = XML.GetAttributeInt

---@param attrName string
---@param defValue number
---@return boolean
function XML:GetAttributeBool(attrName, defValue)
    defValue = defValue or false
    local value = self:GetAttribute(attrName)
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
---@param sep string
---@return table
function XML:GetAttributeArray(attrName, sep)
    sep = sep or ','
    local value = self:GetAttribute(attrName)
    if value ~= nil then
        if string.len(value) == 0 then
            return {}
        else
            return string.split(value, sep)
        end
    end

    return nil
end

---@param attrName string
---@param defValue Love2DEngine.Color
---@return number
function XML:GetAttributeColor(attrName, defValue)
    local value = self:GetAttribute(attrName)
    if value == nil or string.len(value) == 0 then
        return defValue
    end

    return ToolSet.ConvertFromHtmlColor(value)
end

---@param attrName string
---@return number
function XML:GetAttributeVector(attrName)
    local value = self:GetAttribute(attrName)
    if value ~= nil then
        local arr = string.split(value, ',')
        return Vector2(tonumber(arr[1], arr[2]))
    end

    return Vector2.zero
end

---@param attrName string
---@param attrValue string
function XML:SetAttribute(attrName, attrValue)
    if self._attributes == nil then
        self._attributes = {}
    end
    self._attributes[attrName] = attrValue
end

---@param selector string
---@return Utils.XML
function XML:GetNode(selector)
    if self._children == nil then
        return nil
    end
    return self._children:Find(selector)
end

---@return Utils.XMLList
function XML:Elements()
    if self._children == nil then
        self._children = XMLList.new()
    end
    return self._children
end

---@param selector string
---@return Utils.XMLList.Enumerator
function XML:GetEnumerator(selector)
    if self._children == nil then
        return XMLList.Enumerator(nil, selector)
    end
    return XMLList.Enumerator(self._children.rawList, selector)
end

XML.sNodeStack = Stack.new(XML)

function XML:Parse(aSource)
    ---@type Utils.XML
    local lastOpenNode = nil

    XML.sNodeStack:clear()

    XMLIterator.Begin(aSource)
    while XMLIterator.NextTag() do
        if XMLIterator.tagType == XMLTagType.Start or XMLIterator.tagType == XMLTagType.Void then
            ---@type Utils.XML
            local childNode

            if lastOpenNode ~= nil then
                childNode = XML.new()
            else
                if self.name ~= nil then
                    self:Cleanup()
                    error("Invalid xml format - no root node.")
                end
                childNode = self
            end

            childNode.name = XMLIterator.tagName
            childNode._attributes = XMLIterator.GetAttributes(childNode._attributes)

            if lastOpenNode ~= nil then
                if XMLIterator.tagType ~= XMLTagType.Void then
                    XML.sNodeStack:push(lastOpenNode)
                end
                if lastOpenNode._children == nil then
                    lastOpenNode._children = XMLList.new()
                end
                lastOpenNode._children:Add(childNode)
            end
            if XMLIterator.tagType ~= XMLTagType.Void then
                lastOpenNode = childNode
            end
        elseif XMLIterator.tagType == XMLTagType.End then
            if (lastOpenNode == nil or lastOpenNode.name ~= XMLIterator.tagName) then
                self:Cleanup()
                error("Invalid xml format - <" + XMLIterator.tagName + "> dismatched.")
            end

            if (lastOpenNode._children == nil or lastOpenNode._children.Count == 0) then
                lastOpenNode.text = XMLIterator.GetText()
            end

            if (XML.sNodeStack.count > 0) then
                lastOpenNode = XML.sNodeStack.pop()
            else
                lastOpenNode = nil
            end
        end
    end
end

function XML:Cleanup()
    self.name = nil
    if self._attributes ~= nil then
        self._attributes = {}
    end
    if self._children ~= nil then
        self._children:Clear()
    end
    self.text = nil
end


Utils.XML = XML
return XML