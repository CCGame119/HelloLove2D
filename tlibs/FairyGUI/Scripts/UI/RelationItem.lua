--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:48
--

local Class = require('libs.Class')

local Vector4 = Love2DEngine.Vector4

local RelationType = FairyGUI.RelationType
local EventCallback1 = FairyGUI.EventCallback1


---@class FairyGUI.RelationDef:ClassType
---@field public percent boolean
---@field public type FairyGUI.RelationType
---@field public axis number
local RelationDef = Class.inheritsFrom('RelationDef')

---@param source
function RelationDef:copyFrom(source)
    self.percent = source.percent
    self.type = source.type
    self.axis = source.axis
end

---@class FairyGUI.RelationItem:ClassType
---@field public target FairyGUI.GObject
---@field public isEmpty boolean
---@field private _owner FairyGUI.GObject
---@field private _target FairyGUI.GObject
---@field private _defs FairyGUI.RelationDef[]
---@field private _targetData Love2DEngine.Vector4
local RelationItem = Class.inheritsFrom('RelationItem')

---@param owner FairyGUI.GObject
function RelationItem:__ctor(owner)
    self._targetData = Vector4.zero

    self._owner = owner
    self._defs = {}

    self.__targetXYChangedDelegate = EventCallback1.new(self.__targetXYChanged, self)
    self.__targetSizeChangedDelegate = EventCallback1.new(self.__targetSizeChanged, self)
end

---@param relationType FairyGUI.RelationType
---@param usePercent boolean
function RelationItem:Add(relationType, usePercent)
    if relationType == RelationType.Size then
        self:Add(RelationType.Width, usePercent)
        self:Add(RelationType.Height, usePercent)
        return
    end

    for i, def in ipairs(self._defs) do
        if def.type == relationType then
            return
        end
    end

    self:InternalAdd(relationType, usePercent)
end

---@param relationType FairyGUI.RelationType
---@param usePercent boolean
function RelationItem:InternalAdd(relationType, usePercent)
    if relationType == RelationType.Size then
        self:InternalAdd(RelationType.Width, usePercent)
        self:InternalAdd(RelationType.Height, usePercent)
        return
    end

    local info = RelationDef.new()
    info.percent = usePercent
    info.type = relationType
    info.axis = (relationType <= RelationType.Right_Right or
            relationType == RelationType.Width or
            relationType >= RelationType.LeftExt_Left and
            relationType <= RelationType.RightExt_Right) and 0 or 1
    table.insert(self._defs, info)

    --当使用中线关联时，因为需要除以2，很容易因为奇数宽度/高度造成小数点坐标；当使用百分比时，也会造成小数坐标；
    --所以设置了这类关联的对象，自动启用pixelSnapping

    if (usePercent or
            relationType == RelationType.Left_Center or
            relationType == RelationType.Center_Center or
            relationType == RelationType.Right_Center or
            relationType == RelationType.Top_Middle or
            relationType == RelationType.Middle_Middle or
            relationType == RelationType.Bottom_Middle) then
        self._owner.pixelSnapping = true
    end
end

---@param relationType FairyGUI.RelationType
function RelationItem:Remove(relationType)
    if relationType == RelationType.Size then
        self:Remove(RelationType.Width)
        self:Remove(RelationType.Height)
        return
    end

    for i = #self._defs, 1, -1 do
        if self._defs[i].type == relationType then
            table.remove(self._defs, i)
            break
        end
    end
end

---@param source FairyGUI.RelationItem
function RelationItem:CopyFrom(source)
    self.target = source.target

    self._defs = {}

    for i, def in ipairs(source._defs) do
        local info2 = RelationDef.new()
        info2:copyFrom(def)
        table.insert(self._defs, info2)
    end
end

function RelationItem:Dispose()
    if self._target ~= nil then
        self:ReleaseRefTarget(self._target)
        self._target = nil
    end
end

---@param dWidth number
---@param dHeight number
---@param applyPivot boolean
function RelationItem:ApplyOnSelfSizeChanged(dWidth, dHeight, applyPivot)
    local cnt = #self._defs
    if cnt == 0 then
        return
    end

    local _owner = self._owner

    local ox = _owner.x
    local oy = _owner.y

    for i, info in ipairs(self._defs) do
        local type = info.type
        if type == RelationType.Center_Center then
            _owner.x = _owner.x - (0.5 - (applyPivot and _owner.pivotX or 0)) * dWidth
        elseif type == RelationType.Right_Center or
                type == RelationType.Right_Left or
                type == RelationType.Right_Right then
            _owner.x = _owner.x - (1 - (applyPivot and _owner.pivotX or 0)) * dWidth
        elseif type == RelationType.Middle_Middle then
            _owner.y = _owner.y - (0.5 - (applyPivot and _owner.pivotY or 0)) * dHeight
        elseif type == RelationType.Bottom_Middle or
                type == RelationType.Bottom_Top or
                type == RelationType.Bottom_Bottom then
            _owner.y = _owner.y - (1 - (applyPivot and _owner.pivotY or 0)) * dHeight
        end
    end

    if not math.Approximately(ox, _owner.x) or not math.Approximately(oy, _owner.y) then
        ox = _owner.x - ox
        oy = _owner.y - oy

        _owner:UpdateGearFromRelations(1, ox, oy)

        if _owner.parent ~= nil then
            for i, trans in ipairs(_owner.parent._transitions) do
                trans:UpdateFromRelations(_owner.id, ox, oy)
            end
        end
    end
end

---@param info FairyGUI.RelationDef
---@param dx number
---@param dy number
function RelationItem:ApplyOnXYChanged(info, dx, dy)
    local tmp
    local type = info.type
    local _owner = self._owner

    if type == RelationType.Left_Left or
            type == RelationType.Left_Center or
            type == RelationType.Left_Right or
            type == RelationType.Center_Center or
            type == RelationType.Right_Left or
            type == RelationType.Right_Center or
            type == RelationType.Right_Right then
        _owner.x = _owner.x + dx
    elseif type == RelationType.Top_Top or
            type == RelationType.Top_Middle or
            type == RelationType.Top_Bottom or
            type == RelationType.Middle_Middle or
            type == RelationType.Bottom_Top or
            type == RelationType.Bottom_Middle or
            type == RelationType.Bottom_Bottom then
        _owner.y = _owner.y + dy
    elseif type == RelationType.Width or type == RelationType.Height then
    elseif type == RelationType.LeftExt_Left or
            type == RelationType.LeftExt_Right then
        tmp = _owner.xMin
        _owner.width = _owner._rawWidth - dx
        _owner.xMin = tmp + dx
    elseif type == RelationType.RightExt_Left or
            type == RelationType.RightExt_Right then
        tmp = _owner.xMin
        _owner.width = _owner._rawWidth + dx
        _owner.xMin = tmp
    elseif type == RelationType.TopExt_Top or
            type == RelationType.TopExt_Bottom then
        tmp = _owner.yMin
        _owner.height = _owner._rawHeight - dy
        _owner.yMin = tmp + dy
    elseif type == RelationType.BottomExt_Top or
            type == RelationType.BottomExt_Bottom then
        tmp = _owner.yMin
        _owner.height = _owner._rawHeight + dy
        _owner.yMin = tmp
    end
end

---@param info FairyGUI.RelationDef
function RelationItem:ApplyOnSizeChanged(info)
    local _owner = self._owner
    local _target = self._target
    local _targetData = self._targetData


    local pos, pivot, delta = 0, 0, 0
    if (info.axis == 0) then
        if (_target ~= _owner.parent) then
            pos = _target.x
            if (_target.pivotAsAnchor) then
                pivot = _target.pivotX
            end
        end

        if (info.percent) then
            if (_targetData.z ~= 0) then
                delta = _target._width / _targetData.z
            end
        else
            delta = _target._width - _targetData.z
        end
    else
        if (_target ~= _owner.parent) then
            pos = _target.y
            if (_target.pivotAsAnchor) then
                pivot = _target.pivotY
            end
        end

        if (info.percent) then
            if (_targetData.w ~= 0) then
                delta = _target._height / _targetData.w
            end
        else
            delta = _target._height - _targetData.w
        end
    end

    local v, tmp
    local type = info.type
    local percent = info.percent

    if type == RelationType.Left_Left then
        if percent then
            _owner.xMin = pos + (_owner.xMin - pos) * delta
        elseif (pivot ~= 0) then
            _owner.x = _owner.x + delta * (-pivot)
        end
    elseif type == RelationType.Left_Center then
        if percent then
            _owner.xMin = pos + (_owner.xMin - pos) * delta
        else
            _owner.x = _owner.x + delta * (0.5 - pivot)
        end
    elseif type == RelationType.Left_Right then
        if percent then
            _owner.xMin = pos + (_owner.xMin - pos) * delta
        else
            _owner.x = _owner.x + delta * (1 - pivot)
        end
    elseif type == RelationType.Center_Center then
        if percent then
            _owner.xMin = pos + (_owner.xMin + _owner._rawWidth * 0.5 - pos) * delta - _owner._rawWidth * 0.5
        else
            _owner.x = _owner.x + delta * (0.5 - pivot)
        end
    elseif type == RelationType.Right_Left then
        if percent then
            _owner.xMin = pos + (_owner.xMin + _owner._rawWidth - pos) * delta - _owner._rawWidth
        elseif (pivot ~= 0) then
            _owner.x = _owner.x + delta * (-pivot)
        end
    elseif type == RelationType.Right_Center then
        if percent then
            _owner.xMin = pos + (_owner.xMin + _owner._rawWidth - pos) * delta - _owner._rawWidth
        else
            _owner.x = _owner.x + delta * (0.5 - pivot)
        end
    elseif type == RelationType.Right_Right then
        if percent then
            _owner.xMin = pos + (_owner.xMin + _owner._rawWidth - pos) * delta - _owner._rawWidth
        else
            _owner.x = _owner.x + delta * (1 - pivot)
        end
    elseif type == RelationType.Top_Top then
        if percent then
            _owner.yMin = pos + (_owner.yMin - pos) * delta
        elseif (pivot ~= 0) then
            _owner.y = _owner.y + delta * (-pivot)
        end
    elseif type == RelationType.Top_Middle then
        if percent then
            _owner.yMin = pos + (_owner.yMin - pos) * delta
        else
            _owner.y = _owner.y + delta * (0.5 - pivot)
        end
    elseif type == RelationType.Top_Bottom then
        if percent then
            _owner.yMin = pos + (_owner.yMin - pos) * delta
        else
            _owner.y = _owner.y + delta * (1 - pivot)
        end
    elseif type == RelationType.Middle_Middle then
        if percent then
            _owner.yMin = pos + (_owner.yMin + _owner._rawHeight * 0.5 - pos) * delta - _owner._rawHeight * 0.5
        else
            _owner.y = _owner.y + delta * (0.5 - pivot)
        end
    elseif type == RelationType.Bottom_Top then
        if percent then
            _owner.yMin = pos + (_owner.yMin + _owner._rawHeight - pos) * delta - _owner._rawHeight
        elseif (pivot ~= 0) then
            _owner.y = _owner.y + delta * (-pivot)
        end
    elseif type == RelationType.Bottom_Middle then
        if percent then
            _owner.yMin = pos + (_owner.yMin + _owner._rawHeight - pos) * delta - _owner._rawHeight
        else
            _owner.y = _owner.y + delta * (0.5 - pivot)
        end
    elseif type == RelationType.Bottom_Bottom then
        if percent then
            _owner.yMin = pos + (_owner.yMin + _owner._rawHeight - pos) * delta - _owner._rawHeight
        else
            _owner.y = _owner.y + delta * (1 - pivot)
        end
    elseif type == RelationType.Width then
        if (_owner.underConstruct and _owner == _target.parent) then
            v = _owner.sourceWidth - _target.initWidth
        else
            v = _owner._rawWidth - _targetData.z
        end
        if percent then
            v = v * delta
        end
        if (_target == _owner.parent) then
            if (_owner.pivotAsAnchor) then
                tmp = _owner.xMin
                _owner:SetSize(_target._width + v, _owner._rawHeight, true)
                _owner.xMin = tmp
            else
                _owner:SetSize(_target._width + v, _owner._rawHeight, true)
            end
        else
            _owner.width = _target._width + v
        end
    elseif type == RelationType.Height then
        if (_owner.underConstruct and _owner == _target.parent) then
            v = _owner.sourceHeight - _target.initHeight
        else
            v = _owner._rawHeight - _targetData.w
        end
        if percent then
            v = v * delta
        end
        if (_target == _owner.parent) then
            if (_owner.pivotAsAnchor) then
                tmp = _owner.yMin
                _owner:SetSize(_owner._rawWidth, _target._height + v, true)
                _owner.yMin = tmp
            else
                _owner:SetSize(_owner._rawWidth, _target._height + v, true)
            end
        else
            _owner.height = _target._height + v
        end
    elseif type == RelationType.LeftExt_Left then
        tmp = _owner.xMin
        if percent then
            v = pos + (tmp - pos) * delta - tmp
        else
            v = delta * (-pivot)
        end
        _owner.width = _owner._rawWidth - v
        _owner.xMin = tmp + v
    elseif type == RelationType.LeftExt_Right then
        tmp = _owner.xMin
        if percent then
            v = pos + (tmp - pos) * delta - tmp
        else
            v = delta * (1 - pivot)
        end
        _owner.width = _owner._rawWidth - v
        _owner.xMin = tmp + v
    elseif type == RelationType.RightExt_Left then
        tmp = _owner.xMin
        if percent then
            v = pos + (tmp + _owner._rawWidth - pos) * delta - (tmp + _owner._rawWidth)
        else
            v = delta * (-pivot)
        end
        _owner.width = _owner._rawWidth + v
        _owner.xMin = tmp
    elseif type == RelationType.RightExt_Right then
        tmp = _owner.xMin
        if percent then
            if (_owner == _target.parent) then
                if (_owner.underConstruct) then
                    _owner.width = pos + _target._width - _target._width * pivot +
                            (_owner.sourceWidth - pos - _target.initWidth + _target.initWidth * pivot) * delta
                else
                    _owner.width = pos + (_owner._rawWidth - pos) * delta
                end
            else
                v = pos + (tmp + _owner._rawWidth - pos) * delta - (tmp + _owner._rawWidth)
                _owner.width = _owner._rawWidth + v
                _owner.xMin = tmp
            end
        else
            if (_owner == _target.parent) then
                if (_owner.underConstruct) then
                    _owner.width = _owner.sourceWidth + (_target._width - _target.initWidth) * (1 - pivot)
                else
                    _owner.width = _owner._rawWidth + delta * (1 - pivot)
                end
            else
                v = delta * (1 - pivot)
                _owner.width = _owner._rawWidth + v
                _owner.xMin = tmp
            end
        end
    elseif type == RelationType.TopExt_Top then
        tmp = _owner.yMin
        if percent then
            v = pos + (tmp - pos) * delta - tmp
        else
            v = delta * (-pivot)
        end
        _owner.height = _owner._rawHeight - v
        _owner.yMin = tmp + v
    elseif type == RelationType.TopExt_Bottom then
        tmp = _owner.yMin
        if percent then
            v = pos + (tmp - pos) * delta - tmp
        else
            v = delta * (1 - pivot)
        end
        _owner.height = _owner._rawHeight - v
        _owner.yMin = tmp + v
    elseif type == RelationType.BottomExt_Top then
        tmp = _owner.yMin
        if percent then
            v = pos + (tmp + _owner._rawHeight - pos) * delta - (tmp + _owner._rawHeight)
        else
            v = delta * (-pivot)
        end
        _owner.height = _owner._rawHeight + v
        _owner.yMin = tmp
    elseif type == RelationType.BottomExt_Bottom then
        tmp = _owner.yMin
        if percent then
            if (_owner == _target.parent) then
                if (_owner.underConstruct) then
                    _owner.height = pos + _target._height - _target._height * pivot +
                            (_owner.sourceHeight - pos - _target.initHeight + _target.initHeight * pivot) * delta
                else
                    _owner.height = pos + (_owner._rawHeight - pos) * delta
                end
            else
                v = pos + (tmp + _owner._rawHeight - pos) * delta - (tmp + _owner._rawHeight)
                _owner.height = _owner._rawHeight + v
                _owner.yMin = tmp
            end
        else
            if (_owner == _target.parent) then
                if (_owner.underConstruct) then
                    _owner.height = _owner.sourceHeight + (_target._height - _target.initHeight) * (1 - pivot)
                else
                    _owner.height = _owner._rawHeight + delta * (1 - pivot)
                end
            else
                v = delta * (1 - pivot)
                _owner.height = _owner._rawHeight + v
                _owner.yMin = tmp
            end
        end
    end
end

---@param target FairyGUI.GObject
function RelationItem:AddRefTarget(target)
    local _owner = self._owner
    local _target = self._target
    local _targetData = self._targetData

    if (target ~= _owner.parent) then
        target.onPositionChanged:Add(self.__targetXYChangedDelegate)
    end
    target.onSizeChanged:Add(self.__targetSizeChangedDelegate)
    _targetData.x = _target.x
    _targetData.y = _target.y
    _targetData.z = _target._width
    _targetData.w = _target._height
end

---@param target FairyGUI.GObject
function RelationItem:ReleaseRefTarget(target)
    target.onPositionChanged:Remove(self.__targetSizeChangedDelegate)
    target.onSizeChanged:Remove(self.__targetSizeChangedDelegate)
end

---@param context FairyGUI.EventContext
function RelationItem:__targetXYChanged(context)
    local _owner = self._owner
    local _target = self._target
    local _targetData = self._targetData

    if (_owner.relations.handling ~= nil
            or _owner.group ~= nil and _owner.group._updating ~= 0) then
        _targetData.x = _target.x
        _targetData.y = _target.y
        return
    end

    _owner.relations.handling = context.sender

    local ox = _owner.x
    local oy = _owner.y
    local dx = _target.x - _targetData.x
    local dy = _target.y - _targetData.y

    for i, info in ipairs(self._defs) do
        self:ApplyOnXYChanged(info, dx, dy)
    end

    _targetData.x = _target.x
    _targetData.y = _target.y

    if (not math.Approximately(ox, _owner.x) or not math.Approximately(oy, _owner.y)) then
        ox = _owner.x - ox
        oy = _owner.y - oy

        _owner:UpdateGearFromRelations(1, ox, oy)

        if (_owner.parent ~= nil) then
            for i, trans in ipairs(_owner.parent._transitions) do
                trans:UpdateFromRelations(_owner.id, ox, oy)
            end
        end
    end

    _owner.relations.handling = nil
end

---@param context FairyGUI.EventContext
function RelationItem:__targetSizeChanged(context)
    local _owner = self._owner
    local _target = self._target
    local _targetData = self._targetData

    if (_owner.relations.handling ~= nil
            or _owner.group ~= nil and _owner.group._updating ~= 0) then
        _targetData.z = _target._width
        _targetData.w = _target._height
        return
    end

    _owner.relations.handling = context.sender

    local ox = _owner.x
    local oy = _owner.y
    local ow = _owner._rawWidth
    local oh = _owner._rawHeight

    local cnt = self._defs.Count
    for i, info in ipairs(self._defs) do
        self:ApplyOnSizeChanged(info)
    end

    _targetData.z = _target._width
    _targetData.w = _target._height

    if (not math.Approximately(ox, _owner.x) or not math.Approximately(oy, _owner.y)) then
        ox = _owner.x - ox
        oy = _owner.y - oy

        _owner:UpdateGearFromRelations(1, ox, oy)

        if (_owner.parent ~= nil) then
            for i, trans in ipairs(_owner.parent._transitions) do
                trans:UpdateFromRelations(_owner.id, ox, oy)
            end
        end
    end

    if (not math.Approximately(ow, _owner._rawWidth) or not math.Approximately(oh, _owner._rawHeight)) then
        ow = _owner._rawWidth - ow
        oh = _owner._rawHeight - oh

        _owner:UpdateGearFromRelations(2, ow, oh)
    end

    _owner.relations.handling = nil
end


local __get = Class.init_get(RelationItem)
local __set = Class.init_set(RelationItem)

---@param self FairyGUI.RelationItem
__get.target = function(self) return self._target end

---@param self FairyGUI.RelationItem
---@param val FairyGUI.GObject
__set.target = function(self, val)
    if self._target ~= val then
        if self._target ~= nil then
            self:ReleaseRefTarget(self._target)
        end
        self._target = val
        if self._target ~= nil then
            self:AddRefTarget(self._target)
        end
    end
end

---@param self FairyGUI.RelationItem
__get.isEmpty = function(self) return #self._defs == 0 end


FairyGUI.RelationDef = RelationDef
FairyGUI.RelationItem = RelationItem
return RelationItem