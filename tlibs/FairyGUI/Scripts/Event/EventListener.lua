--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 13:50
--

local Class = require('libs.Class')

---@class FairyGUI.EventListener:ClassType
---@field public owner FairyGUI.EventDispatcher
---@field public type string
---@field public isEmpty boolean
---@field public isDispatching boolean
---@field private _bridge FairyGUI.EventBridge
---@field private _type string
local EventListener = Class.inheritsFrom('EventListener')

---@param owner FairyGUI.EventDispatcher
---@param type string
function EventListener:__ctor(owner, type)
    self.owner = owner
    self._type = type
end

---@param callback FairyGUI.EventCallback1
function EventListener:AddCapture(callback, obj)
    if nil == self._bridge then
        self._bridge = self.owner:GetEventBridge(self._type)
    end

    self._bridge:AddCapture(callback, obj)
end

---@param callback FairyGUI.EventCallback1
function EventListener:RemoveCapture(callback, obj)
    if nil == self._bridge then
        self._bridge = self.owner:GetEventBridge(self._type)
    end

    self._bridge:RemoveCapture(callback, obj)
end

---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function EventListener:Add(callback, obj)
    if nil == self._bridge then
        self._bridge = self.owner:GetEventBridge(self._type)
    end

    self._bridge:Add(callback, obj)
end

---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function EventListener:Remove(callback, obj)
    if nil == self._bridge then
        self._bridge = self.owner:GetEventBridge(self._type)
    end

    self._bridge:Remove(callback, obj)
end

---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function EventListener:Set(callback, obj)
    if nil == self._bridge then
        self._bridge = self.owner:GetEventBridge(self._type)
    end

    self._bridge:Clear()
    if nil ~= callback then
        self._bridge:Add(callback, obj)
    end
end

function EventListener:Clear()
    if nil == self._bridge then
        self._bridge = self.owner:GetEventBridge(self._type)
    end

    self._bridge:Clear()
end

---@param data any|nil
---@return boolean
function EventListener:Call(data)
    return self.owner:InternalDispatchEvent(self._type, self._bridge, data)
end

---@param data any|nil
---@return boolean
function EventListener:BubbleCall(data)
    return self.owner:BubbleEvent(self._type, data)
end

---@param data any|nil
---@return boolean
function EventListener:BroadcastCall(data)
    return self.owner:BroadcastCall(data)
end

--==============属性访问器================
local __get = Class.init_get(EventListener)

---@param self FairyGUI.EventListener
__get.isEmpty = function(self)
    if nil == self._bridge then
        self._bridge = self.owner:GetEventBridge(self._type)
    end

    return self._bridge == nil or self._bridge.isEmpty
end

---@param self FairyGUI.EventListener
__get.isDispatching = function(self)
    if nil == self._bridge then
        self._bridge = self.owner:GetEventBridge(self._type)
    end

    return self._bridge ~= nil and self._bridge._dispatching
end

FairyGUI.EventListener = EventListener
return EventListener