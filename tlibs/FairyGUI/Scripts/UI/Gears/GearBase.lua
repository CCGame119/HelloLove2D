--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:19
--

local Class = require('libs.Class')

local EaseType = FairyGUI.EaseType

--region GearTweenConfig
---@class FairyGUI.GearTweenConfig:ClassType
---@field public tween boolean @Use tween to apply change.
---@field public easeType FairyGUI.EaseType @Ease type.
---@field public duration number @Tween duration in seconds.
---@field public delay number @Tween delay in seconds.
---@field public _displayLockToken number
---@field public _tweener FairyGUI.GTweener
local GearTweenConfig = Class.inheritsFrom('GearTweenConfig')

function GearTweenConfig:__ctor()
    self.tween = true
    self.easeType = EaseType.QuadOut
    self.duration = 0.3
    self.delay = 0
end
--endregion

--region GearBase
---@class FairyGUI.GearBase:ClassType
---@field public controller FairyGUI.Controller
---@field public tweenConfig FairyGUI.GearTweenConfig
---@field protected _owner FairyGUI.GObject
---@field protected _controller FairyGUI.Controller
---@field protected _tweenConfig FairyGUI.GearTweenConfig
local GearBase = Class.inheritsFrom('GearBase')

GearBase.disableAllTweenEffect = false

---@param owner FairyGUI.GObject
function GearBase:__ctor(owner)
    self._owner = owner
end

---@param buffer Utils.ByteBuffer
function GearBase:Setup(buffer)
    self._controller = self._owner.parent:GetControllerAt(buffer:ReadShort())
    self:Init()

    if self:isa(GearDisplay) then
        local cnt = buffer:ReadShort()
        local pages = {}
        for i = 1, cnt do
            pages[i] = buffer:ReadS()
        end
        self.pages = pages
    else
        local cnt = buffer:ReadShort()
        for i = 1, cnt do
            local page = buffer:ReadS()
            if (page == nil) then
                --continue
            else
                self:AddStatus(page, buffer)
            end
        end

        if buffer:ReadBool() then
            self:AddStatus(nil, buffer)
        end
    end

    if buffer:ReadBool() then
        self._tweenConfig = GearTweenConfig.new()
        self._tweenConfig.easeType = buffer:ReadByte()
        self._tweenConfig.duration = buffer:ReadFloat()
        self._tweenConfig.delay = buffer:ReadFloat()
    end
end

---@param dx number
---@param dy number
function GearBase:UpdateFromRelations(dx, dy)

end

---@param pageId string
---@param buffer Utils.ByteBuffer
function GearBase:AddStatus(pageId, buffer) end

function GearBase:Init() end

function GearBase:Apply() end

function GearBase:UpdateState() end

local __get = Class.init_get(GearBase)
local __set = Class.init_set(GearBase)

---@param self FairyGUI.GearBase
__get.controller = function(self) return self._controller end

---@param self FairyGUI.GearBase
---@param val FairyGUI.Controller
__set.controller = function(self, val)
    if self._controller ~= val then
        self._controller = val
        if self._controller ~= nil then
            self:Init()
        end
    end
end

---@param self FairyGUI.GearBase
__get.tweenConfig = function(self)
    if self._tweenConfig == nil then
        self._tweenConfig = GearTweenConfig.new()
        return self._tweenConfig
    end
end
--endregion

FairyGUI.GearTweenConfig = GearTweenConfig
FairyGUI.GearBase = GearBase
return GearBase