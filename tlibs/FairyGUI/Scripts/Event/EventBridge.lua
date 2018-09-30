--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 13:59
--

local Class = require('libs.Class')
local functor = require('Utils.functor')
local init_get = Class.init_get
local EventCallback0 = FairyGUI.EventCallback0
local EventCallback1 = FairyGUI.EventCallback1

---@class FairyGUI.EventBridge : ClassType
---@field public isEmpty boolean
local EventBridge = {
    ---@type FairyGUI.EventDispatcher
    owner = nil,
    ---@type FairyGUI.EventCallback0
    _callback0 = EventCallback0.newCls(),
    ---@type FairyGUI.EventCallback1
    _callback1 = FairyGUI.EventCallback1.newCls(),
    ---@type FairyGUI.EventCallback1
    _captureCallback = EventCallback1.newCls(),
    _dispatching = false,
}
EventBridge = Class.class('EventBridge', EventBridge)

---@param owner FairyGUI.EventDispatcher
function EventBridge:__ctor(owner)
    self.owner = owner
end

---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function EventBridge:AddCapture(callback, obj)
    self._captureCallback:Add(callback, obj)
end

---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function EventBridge:RemoveCapture(callback, obj)
    self._captureCallback:Remove(callback, obj)
end

---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function EventBridge:Add(callback, obj)
    if callback:isa(EventCallback0) then
        self._callback0:Add(callback, obj)
    elseif callback:isa(EventCallback1) then
        self._callback1:Add(callback, obj)
    end
    assert(false, "type mismatch")
end

---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function EventBridge:Remove(callback)
    if callback:isa(EventCallback0) then
        self._callback0:Remove(callback, obj)
    elseif callback:isa(EventCallback1) then
        self._callback1:Remove(callback, obj)
    end
    assert(false, "type mismatch")
end

function EventBridge:Clear()
    self._callback0:Clear()
    self._callback1:Clear()
    self._captureCallback:Clear()
end

---@param self FairyGUI.EventBridge
---@param context FairyGUI.EventContext
local function _pCallInternal(self, context)
    if not self._callback1.isEmpty then
        self._callback1(context)
    end
    if not self._callback0.isEmpty then
        self._callback0()
    end
end

---@param context FairyGUI.EventContext
function EventBridge:CallInternal(context)
    self._dispatching = true
    context.sender = self.owner
    local func = functor(_pCallInternal)
    func(self, context)
    self._dispatching = false
end

---@param self FairyGUI.EventBridge
---@param context FairyGUI.EventContext
function _pCallCaptureInternal(self, context)
    self._captureCallback(context)
end

---@param context FairyGUI.EventContext
function EventBridge:CallCaptureInternal(context)
    if self._captureCallback.isEmpty then return end
    self._dispatching = true
    local func = functor(_pCallInternal)
    func(self, context)
    self._dispatching = false
end

--==============属性访问器================
local get = init_get(EventBridge)

---@param self FairyGUI.EventBridge
get.isEmpty = function(self)
    return self._callback1.isEmpty and self._callback0.isEmpty and self._captureCallback.isEmpty
end

FairyGUI.EventBridge = EventBridge
return EventBridge