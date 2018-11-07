--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:18
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2

local GearBase = FairyGUI.GearBase
local ITweenListener = FairyGUI.ITweenListener
local UIPackage = FairyGUI.UIPackage
local GTween = FairyGUI.GTween

--region GearXYValue
---@class FairyGUI.GearXYValue:ClassType
---@field public x number
---@field public y number
local GearXYValue = Class.inheritsFrom('GearXYValue')

---@param x number
---@param y number
function GearXYValue:__ctor(x, y)
    self.x = x
    self.y = y
end
--endregion

--region GearXY
---@class FairyGUI.GearXY:FairyGUI.GearBase @implement ITweenListener
---@field public _storage table<string, FairyGUI.GearXYValue>
---@field public _default FairyGUI.GearXYValue
local GearXY = Class.inheritsFrom('GearXY', nil, GearBase)

function GearXY:__ctor(owner)
    GearBase.__ctor(self, owner)
end

function GearXY:Init()
    self._default = GearXYValue.new(self._owner.x, self._owner.y)
    self._storage = {}
end

function GearXY:AddStatus(pageId, buffer)
    local gv
    if (self.pageId == nil) then
        gv = self._default
    else
        gv = GearXYValue.new(0, 0)
        self._storage[self.pageId] = gv
    end

    gv.x = buffer:ReadInt()
    gv.y = buffer:ReadInt()
end

function GearXY:Apply()
    local _owner = self._owner
    local _tweenConfig = self._tweenConfig
    local selPId = self._controller.selectedPageId
    local gv = self._storage[selPId]
    if gv == nil then
        gv = self._default
    end

    if (_tweenConfig ~= nil and _tweenConfig.tween and UIPackage._constructing == 0 and not self.disableAllTweenEffect) then
        if (_tweenConfig._tweener ~= nil) then
            if (_tweenConfig._tweener.endValue.x ~= gv.x or _tweenConfig._tweener.endValue.y ~= gv.y) then
                _tweenConfig._tweener:Kill(true)
                _tweenConfig._tweener = nil
            else
                return
            end
        end

        if (_owner.x ~= gv.x or _owner.y ~= gv.y) then
            if (_owner:CheckGearController(0, self._controller)) then
                _tweenConfig._displayLockToken = _owner:AddDisplayLock()
            end

            _tweenConfig._tweener = GTween.To(_owner.xy, Vector2(gv.x, gv.y), _tweenConfig.duration)
                                          :SetDelay(_tweenConfig.delay)
                                          :SetEase(_tweenConfig.easeType)
                                          :SetTarget(self)
                                          :SetListener(self)
        end
    else
        _owner._gearLocked = true
        _owner:SetXY(gv.x, gv.y)
        _owner._gearLocked = false
    end
end

---@param tweener FairyGUI.GTweener
function GearXY:OnTweenStart(tweener) end

---@param tweener FairyGUI.GTweener
function GearXY:OnTweenUpdate(tweener)
    local _owner = self._owner
    _owner._gearLocked = true
    _owner:SetXY(tweener.value.x, tweener.value.y)
    _owner._gearLocked = false

    _owner:InvalidateBatchingState()
end

---@param tweener FairyGUI.GTweener
function GearXY:OnTweenComplete(tweener)
    local _tweenConfig = self._tweenConfig
    local _owner = self._owner

    _tweenConfig._tweener = nil
    if (_tweenConfig._displayLockToken ~= 0) then
        _owner:ReleaseDisplayLock(_tweenConfig._displayLockToken)
        _tweenConfig._displayLockToken = 0
    end
    _owner.OnGearStop:Call(self)
end

function GearXY:UpdateState()
    local _owner = self._owner
    local selPId = self._controller.selectedPageId
    local gv = self._storage[selPId]
    if gv == nil then
        self._storage[selPId] = GearXYValue.new(_owner.x, _owner.y)
    else
        gv.x = _owner.x
        gv.y = _owner.y
    end
end

function GearXY:UpdateFromRelations(dx, dy)
    if (self._controller ~= nil and self._storage ~= nil) then
        for _, gv in pairs(self._storage) do
            gv.x = gv.x + dx
            gv.y = gv.y + dy
        end
        self._default.x = self._default.x + dx
        self._default.y = self._default.y + dy

        self:UpdateState()
    end
end
--endregion

FairyGUI.GearXYValue = GearXYValue
FairyGUI.GearXY = GearXY
return GearXY