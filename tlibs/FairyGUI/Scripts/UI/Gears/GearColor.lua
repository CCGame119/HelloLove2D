--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:31
--

local Class = require('libs.Class')

local Color = Love2DEngine.Color

local GearBase = FairyGUI.GearBase
local ITweenListener = FairyGUI.ITweenListener
local ITextColorGear = FairyGUI.ITextColorGear
local UIPackage = FairyGUI.UIPackage
local GTween = FairyGUI.GTween

---@class FairyGUI.GearColorValue:ClassType
---@field private color Love2DEngine.Color
---@field private strokeColor Love2DEngine.Color
local GearColorValue = Class.inheritsFrom('GearColorValue')

---@param color Love2DEngine.Color
---@param strokeColor Love2DEngine.Color
function GearColorValue:__ctor(color, strokeColor)
    self.color = color or Color.white
    self.strokeColor = strokeColor or Color.white
end

---@class FairyGUI.GearColor:FairyGUI.GearBase @implement FairyGUI.ITweenListener
---@field private _storage table<string, FairyGUI.GearColorValue>
---@field private _default FairyGUI.GearColorValue
local GearColor = Class.inheritsFrom('GearColor', nil, GearBase, {ITweenListener})

function GearColor:__ctor(owner)
    GearBase.__ctor(self, owner)
end

function GearColor:Init()
    self._default = GearColorValue.new()
    self._default.color = self._owner.color
    if self._owner:isa(ITextColorGear) then
        self._default.strokeColor = self._owner.strokeColor
    end
    self._storage = {}
end

function GearColor:AddStatus(pageId, buffer)
    local gv
    if (pageId == nil) then
        gv = self._default
    else
        gv = GearColorValue.new(Color.black, Color.black)
        self._storage[pageId] = gv
    end

    gv.color = buffer:ReadColor()
    gv.strokeColor = buffer:ReadColor()
end

function GearColor:Apply()
    local _tweenConfig = self._tweenConfig
    local _owner = self._owner
    local selPId = self._controller.selectedPageId
    local gv = self._storage[selPId]
    if nil == gv then
        gv = self._default
    end

    if (_tweenConfig ~= nil and _tweenConfig.tween and UIPackage._constructing == 0 and not self.disableAllTweenEffect) then
        if _owner:isa(ITextColorGear) and gv.strokeColor.a > 0 then
            _owner._gearLocked = true
            _owner.strokeColor = gv.strokeColor
            _owner._gearLocked = false
        end

        if (_tweenConfig._tweener ~= nil) then
            if (_tweenConfig._tweener.endValue.color ~= gv.color) then
                _tweenConfig._tweener:Kill(true)
                _tweenConfig._tweener = nil
            else
                return
            end
        end

        if _owner.color ~= gv.color then
            if _owner:CheckGearController(0, self._controller) then
                _tweenConfig._displayLockToken = _owner:AddDisplayLock()
            end

            _tweenConfig._tweener = GTween.To(_owner.color, gv.color, _tweenConfig.duration)
                                          :SetDelay(_tweenConfig.delay)
                                          :SetEase(_tweenConfig.easeType)
                                          :SetTarget(self)
                                          :SetListener(self)
        end
    else
        _owner._gearLocked = true
        _owner.color = gv.color
        if _owner:isa(ITextColorGear) and gv.strokeColor.a > 0 then
            _owner.strokeColor = gv.strokeColor
        end
        _owner._gearLocked = false
    end
end

---@param tweener FairyGUI.GTweener
function GearColor:OnTweenStart(tweener) end

---@param tweener FairyGUI.GTweener
function GearColor:OnTweenUpdate(tweener)
    local _owner = self._owner

    _owner._gearLocked = true
    _owner.color = tweener.value.color
    _owner._gearLocked = false

    _owner:InvalidateBatchingState()
end

---@param tweener FairyGUI.GTweener
function GearColor:OnTweenComplete(tweener)
    local _tweenConfig = self._tweenConfig
    local _owner = self._owner

    _tweenConfig._tweener = nil
    if (_tweenConfig._displayLockToken ~= 0) then
        _owner:ReleaseDisplayLock(_tweenConfig._displayLockToken)
        _tweenConfig._displayLockToken = 0
    end
    _owner.OnGearStop:Call(self)
end

function GearColor:UpdateState()
    local selPId = self._controller.selectedPageId
    local gv = self._storage[selPId]
    if nil == gv then
        gv = GearColorValue.new()
        self._storage[selPId] = gv
    end

    gv.color = self._owner.color
    if self._owner:isa(ITextColorGear) then
        gv.strokeColor = self._owner.strokeColor
    end
end


FairyGUI.GearColorValue = GearColorValue
FairyGUI.GearColor = GearColor
return GearColor