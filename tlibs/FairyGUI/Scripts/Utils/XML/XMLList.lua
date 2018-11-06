--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 11:34
--

local Class = require('libs.Class')

---========================Utils.XMLList.Enumerator==============================
---@class Utils.XMLList.Enumerator:ClassType
---@field private _source Utils.XML[]
---@field private _selector string
---@field private _index number
---@field private _total number
---@field private _current Utils.XML
local Enumerator = Class.inheritsFrom('Enumerator')

function Enumerator:__ctor(source, selector)
    self._source = source
    self._selector = selector
    self._index = 1
    if self._source ~= nil then
        self._total = #self._source
    else
        self._total = 0
    end
    self._current = nil
end

---@return boolean
function Enumerator:MoveNext()
    while self._index <= self._total do
        self._current = self._source[self._index]
        if self._selector == nil or self._current.name == self._selector then
            return true
        end
        self._index = self._index + 1
    end
    return false
end

function Enumerator:Reset()
    self._index = 1
end

local get = Class.init_get(Enumerator)

---@param self Utils.XMLList.Enumerator
get.Current = function(self) return self._current end

Enumerator.__call = function(t, source, selector)
    return Enumerator.new(source, selector)
end
---=======================Utils.XMLList==================================

---@class Utils.XMLList:ClassType
---@field public rawList Utils.XML[]
local XMLList = Class.inheritsFrom('XMLList')

---@param list Utils.XML[]|nil
function XMLList:__ctor(list)
    self.rawList = list or {}
end

---@param xml Utils.XML
function XMLList:Add(xml)
    table.insert(self.rawList, xml)
end

function XMLList:Clear()
    self.rawList = {}
end

XMLList._tmpList = {}

---@param selector string
function XMLList:Filter(selector)
    local allFit = true
    XMLList._tmpList = {}
    local cnt = #self.rawList
    for i = 1, cnt do
        local xml = self.rawList[i]
        if xml.name == selector then
            table.insert(XMLList._tmpList, xml)
        else
            allFit = false
        end
    end

    if allFit then
        return self
    end

    local ret = XMLList.new(self._tmpList)
    XMLList._tmpList  = {}
    return ret
end

---@param selector string
function XMLList:Find(selector)
    local cnt = #self.rawList
    for i = 1, cnt do
        local xml = self.rawList[i]
        if xml.name == selector then
            return xml
        end
    end
    return nil
end

---@param selector string|nil
function XMLList:GetEnumerator(selector)
    return Enumerator(self.rawList, selector)
end


local __get = Class.init_get(XMLList, true, true)

---@param self Utils.XMLList
__get.Count = function(self) return #self.rawList end

---@param self Utils.XMLList
---@param idx number
__get.__indexer = function(self, idx) return self.rawList[idx]  end


XMLList.Enumerator = Enumerator
Utils.XMLList = XMLList
setmetatable(Enumerator, Enumerator)
return XMLList