--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:21
--

local Class = require('libs.Class')
local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

local Vector4 = Love2DEngine.Vector4

local GearBase = FairyGUI.GearBase
local ITweenListener = FairyGUI.ITweenListener
local UIPackage = FairyGUI.UIPackage
local GTween = FairyGUI.GTween

---@class FairyGUI.GearSizeValue:ClassType
---@field public width number
---@field public height number
---@field public scaleX number
---@field public scaleY number
local GearSizeValue = Class.inheritsFrom('GearSizeValue')

---@param width number
---@param height number
---@param scaleX number
---@param scaleY number
function GearSizeValue:__ctor(width, height, scaleX, scaleY)
    self.width = width
    self.height = height
    self.scaleX = scaleX
    self.scaleY = scaleY
end

---@class FairyGUI.GearSize:FairyGUI.GearBase @implement ITweenListener
---@field private _storage table<string, FairyGUI.GearSizeValue>
---@field private _default FairyGUI.GearSizeValue
local GearSize = Class.inheritsFrom('GearSize', nil, GearBase)

function GearSize:__ctor(owner)
    GearBase.__ctor(self, owner)
end

function GearSize:Init()
    local _owner = self._owner
    self._default = GearSizeValue.new(_owner.width, _owner.height, _owner.scaleX, _owner.scaleY)
    self._storage = {}
end

function GearSize:AddStatus(pageId, buffer)
    local gv
    if (self.pageId == nil) then
        gv = self._default
    else
        gv = GearSizeValue.new(0, 0, 1, 1)
        self._storage[pageId] = gv
    end


    gv.width = buffer:ReadInt()
    gv.height = buffer:ReadInt()
    gv.scaleX = buffer:ReadFloat()
    gv.scaleY = buffer:ReadFloat()
end

function GearSize:Apply()
    local _owner = self._owner
    local _tweenConfig = self._tweenConfig
    local selPId = self._controller.selectedPageId
    local gv = self._storage[selPId]
    if gv == nil then
        gv = self._default
    end

    if (_tweenConfig ~= nil and _tweenConfig.tween and UIPackage._constructing == 0 and not self.disableAllTweenEffect) then
        if (_tweenConfig._tweener ~= nil) then
            if (_tweenConfig._tweener.endValue.x ~= gv.width or _tweenConfig._tweener.endValue.y ~= gv.height
                    or _tweenConfig._tweener.endValue.z ~= gv.scaleX or _tweenConfig._tweener.endValue.w ~= gv.scaleY) then
                _tweenConfig._tweener:Kill(true)
                _tweenConfig._tweener = nil
            else
                return
            end
        end

        local a = gv.width ~= _owner.width or gv.height ~= _owner.height
        local b = gv.scaleX ~= _owner.scaleX or gv.scaleY ~= _owner.scaleY
        if a or b then
            if _owner:CheckGearController(0, self._controller) then
                _tweenConfig._displayLockToken = _owner:AddDisplayLock()
            end

            _tweenConfig._tweener = GTween.To(Vector4(_owner.width, _owner.height, _owner.scaleX, _owner.scaleY),
                    Vector4(gv.width, gv.height, gv.scaleX, gv.scaleY), _tweenConfig.duration)
                                          :SetDelay(_tweenConfig.delay)
                                          :SetEase(_tweenConfig.easeType)
                                          :SetUserData((a and 1 or 0) + (b and 2 or 0))
                                          :SetTarget(self)
                                          :SetListener(self)
        end
    else
        _owner._gearLocked = true
        _owner:SetSize(gv.width, gv.height, _owner:CheckGearController(1, self._controller))
        _owner:SetScale(gv.scaleX, gv.scaleY)
        _owner._gearLocked = false
    end
end

---@param tweener FairyGUI.GTweener
function GearSize:OnTweenStart(tweener) end

---@param tweener FairyGUI.GTweener
function GearSize:OnTweenUpdate(tweener)
    self._owner.self._gearLocked = true
    ---@type number
    local flag = tweener.userData
    if (band(flag, 1) ~= 0) then
        self._owner:SetSize(tweener.value.x, tweener.value.y, self._owner:CheckGearController(1, self._controller))
    end
    if (band(flag, 2) ~= 0) then
        self._owner:SetScale(tweener.value.z, tweener.value.w)
    end
    self._owner.self._gearLocked = false

    self._owner:InvalidateBatchingState()
end

---@param tweener FairyGUI.GTweener
function GearSize:OnTweenComplete(tweener)
    self._tweenConfig.self._tweener = nil
    if (self._tweenConfig.self._displayLockToken ~= 0) then
        self._owner:ReleaseDisplayLock(self._tweenConfig.self._displayLockToken)
        self._tweenConfig.self._displayLockToken = 0
    end
    self._owner.OnGearStop:Call(this)
end

function GearSize:UpdateState()
    local _owner = self._owner
    local selPId = self._controller.selectedPageId
    local gv = self._storage[selPId]
    if gv == nil then
        self._storage[selPId] = GearSizeValue.new(_owner.width, _owner.height, _owner.scaleX, _owner.scaleY)
    else
        gv.width = _owner.width
        gv.height = _owner.height
        gv.scaleX = _owner.scaleX
        gv.scaleY = _owner.scaleY
    end
end

function GearSize:UpdateFromRelations(dx, dy)
    if (self._controller ~= nil and self._storage ~= nil) then
        for _, gv in pairs(self._storage) do
            gv.width = gv.width + dx
            gv.height = gv.height + dy
        end
        self._default.width = self._default.width + dx
        self._default.height = self._default.height + dy

        self:UpdateState()
    end
end


FairyGUI.GearSizeValue = GearSizeValue
FairyGUI.GearSize = GearSize
return GearSize