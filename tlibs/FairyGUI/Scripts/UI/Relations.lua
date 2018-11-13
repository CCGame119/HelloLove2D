--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:50
--

local Class = require('libs.Class')

local RelationItem = FairyGUI.RelationItem

---@class FairyGUI.Relations:ClassType
---@field public handling FairyGUI.GObject
---@field public isEmpty boolean
---@field private _owner FairyGUI.GObject
---@field private _items FairyGUI.RelationItem[]
local Relations = Class.inheritsFrom('Relations')

---@param _owner FairyGUI.GObject
function Relations:__ctor(_owner)
    self._owner = _owner
    self._items = {}
end

---@param target FairyGUI.GObject
---@param relationType FairyGUI.RelationType
---@param usePercent boolean @default: false
function Relations:Add(target, relationType, usePercent)
    usePercent = usePercent or false

    for i, item in ipairs(self._items) do
        if item.target == target then
            item:Add(relationType, usePercent)
            return
        end
    end
    local newItem = RelationItem.new(self._owner)
    newItem.target = target
    newItem:Add(relationType, usePercent)
    table.insert(self._items, newItem)
end

---@param target FairyGUI.GObject
---@param relationType FairyGUI.RelationType
function Relations:Remove(target, relationType)
    for i = #self._items, 1, -1 do
        local item = self._items[i]
        if item.target == target then
            item:Remove(relationType)
            if item.isEmpty then
                item:Dispose()
                table.remove(self._items, i)
            end
        end
    end
end

---@param target FairyGUI.GObject
---@return boolean
function Relations:Contains(target)
    for i, item in ipairs(self._items) do
        if item.target == target then
            return true
        end
    end
    return false
end

---@param target FairyGUI.GObject
function Relations:ClearFor(target)
    for i = #self._items, 1, -1 do
        local item = self._items[i]
        if item.target == target then
            item:Dispose()
            table.remove(self._items, i)
        end
    end
end

function Relations:ClearAll()
    for i, item in ipairs(self._items) do
        item:Dispose()
    end
    self._items = {}
end

---@param source FairyGUI.Relations
function Relations:CopyFrom(source)
    self:ClearAll()

    for i, ri in ipairs(source._items) do
        local item = RelationItem.new(self._owner)
        item:CopyFrom(ri)
        table.insert(self._items, item)
    end
end

function Relations:Dispose()
    self:ClearAll()
end

---@param dWidth number
---@param dHeight number
---@param applyPivot boolean
function Relations:OnOwnerSizeChanged(dWidth, dHeight, applyPivot)
    if #self._items == 0 then
        return
    end

    for i, item in ipairs(self._items) do
        item:ApplyOnSelfSizeChanged(dWidth, dHeight, applyPivot)
    end
end

---@param buffer Utils.ByteBuffer
---@param parentToChild boolean
function Relations:Setup(buffer, parentToChild)
    local _owner = self._owner
    local cnt = buffer:ReadByte()
    local target
    for i = 1, cnt do
        local targetIndex = buffer:ReadShort()
        if (targetIndex == -1) then
            target = _owner.parent
        elseif (parentToChild) then
            target = _owner:GetChildAt(targetIndex)
        else
            target = _owner.parent:GetChildAt(targetIndex)
        end

        local newItem = RelationItem.new(_owner)
        newItem.target = target
        table.insert(self._items, newItem)

        local cnt2 = buffer:ReadByte()
        for j = 1, cnt2 do
            ---@type FairyGUI.RelationType
            local rt = buffer:ReadByte()
            local usePercent = buffer:ReadBool()
            newItem:InternalAdd(rt, usePercent)
        end
    end
end

local __get = Class.init_get(Relations)

---@param self FairyGUI.Relations
__get.isEmpty = function(self) return #self._items == 0 end

FairyGUI.Relations = Relations
return Relations