--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:20
--

local Class = require('libs.Class')
local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

local Vector2 = Love2DEngine.Vector2

local GearBase = FairyGUI.GearBase
local ITweenListener = FairyGUI.ITweenListener
local GTween = FairyGUI.GTween
local UIPackage = FairyGUI.UIPackage

---@class FairyGUI.GearLookValue:ClassType
---@field public alpha number
---@field public rotation number
---@field public grayed boolean
---@field public touchable boolean
local GearLookValue = Class.inheritsFrom('GearLookValue')

---@param alpha number
---@param rotation number
---@param grayed boolean
---@param touchable boolean
function GearLookValue:__ctor(alpha, rotation, grayed, touchable)
    self.alpha = alpha
    self.rotation = rotation
    self.grayed = grayed
    self.touchable = touchable
end

---@class FairyGUI.GearLook:FairyGUI.GearBase @implement ITweenListener
---@field private _storage table<string, FairyGUI.GearLookValue>
---@field private _default FairyGUI.GearLookValue
local GearLook = Class.inheritsFrom('GearLook', nil, GearBase, {ITweenListener})

function GearLook:__ctor(owner)
    GearBase.__ctor(self, owner)
end

function GearLook:Init()
    local _owner = self._owner
    self._default = GearLookValue.new(_owner.alpha, _owner.rotation, _owner.grayed, _owner.touchable)
    self._storage = {}
end

function GearLook:AddStatus(pageId, buffer)
    local gv
    if (pageId == nil) then
        gv = self._default
    else
        gv = GearLookValue.new(0, 0, false, false)
        self._storage[pageId] = gv
    end

    gv.alpha = buffer:ReadFloat()
    gv.rotation = buffer:ReadFloat()
    gv.grayed = buffer:ReadBool()
    gv.touchable = buffer:ReadBool()
end

function GearLook:Apply()
    local _owner = self._owner
    local _tweenConfig = self._tweenConfig
    local selPid = self._controller.selectedPageId
    local gv = self._storage[selPid]
    if nil == gv then
        gv = self._default
    end

    if (_tweenConfig ~= nil and _tweenConfig.tween and UIPackage._constructing == 0 and not self.disableAllTweenEffect) then
        _owner._gearLocked = true
        _owner.grayed = gv.grayed
        _owner.touchable = gv.touchable
        _owner._gearLocked = false

        if (_tweenConfig._tweener ~= nil) then
            if (_tweenConfig._tweener.endValue.x ~= gv.alpha or _tweenConfig._tweener.endValue.y ~= gv.rotation) then
                _tweenConfig._tweener:Kill(true)
                _tweenConfig._tweener = nil
            else
                return
            end
        end

        local a = gv.alpha ~= _owner.alpha
        local b = gv.rotation ~= _owner.rotation
        if (a or b) then
            if (_owner:CheckGearController(0, self._controller)) then
                _tweenConfig._displayLockToken = _owner:AddDisplayLock()
            end

            _tweenConfig._tweener = GTween.To(Vector2(_owner.alpha, _owner.rotation), Vector2(gv.alpha, gv.rotation), _tweenConfig.duration)
                                          :SetDelay(_tweenConfig.delay)
                                          :SetEase(_tweenConfig.easeType)
                                          :SetUserData((a and 1 or 0) + (b and 2 or 0))
                                          :SetTarget(self)
                                          :SetListener(self)
        end
    else
        _owner._gearLocked = true
        _owner.alpha = gv.alpha
        _owner.rotation = gv.rotation
        _owner.grayed = gv.grayed
        _owner.touchable = gv.touchable
        _owner._gearLocked = false
    end
end

---@param tweener FairyGUI.GTweener
function GearLook:OnTweenStart(tweener) end

---@param tweener FairyGUI.GTweener
function GearLook:OnTweenUpdate(tweener)
    local _owner = self._owner
    local flag = tweener.userData
    _owner._gearLocked = true
    if (band(flag, 1) ~= 0) then
        _owner.alpha = tweener.value.x
    end
    if (band(flag, 2) ~= 0) then
        _owner.rotation = tweener.value.y
        _owner:InvalidateBatchingState()
    end
    _owner._gearLocked = false
end

---@param tweener FairyGUI.GTweener
function GearLook:OnTweenComplete(tweener)
    local _owner = self._owner
    local _tweenConfig = self._tweenConfig
    _tweenConfig._tweener = nil
    if (_tweenConfig._displayLockToken ~= 0) then
        _owner:ReleaseDisplayLock(_tweenConfig._displayLockToken)
        _tweenConfig._displayLockToken = 0
    end
    _owner.OnGearStop:Call(self)
end

function GearLook:UpdateState()
    local _owner = self._owner
    local selPid = self._controller.selectedPageId
    local gv = self._storage[selPid]
    if nil == gv then
        self._storage[selPid] = GearLookValue.new(_owner.alpha, _owner.rotation, _owner.grayed, _owner.touchable)
    else
        gv.alpha = _owner.alpha
        gv.rotation = _owner.rotation
        gv.grayed = _owner.grayed
        gv.touchable = _owner.touchable
    end
end


FairyGUI.GearLook = GearLook
return GearLook