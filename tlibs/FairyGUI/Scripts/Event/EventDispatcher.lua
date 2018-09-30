--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 14:07
--
local Class = require('libs.Class')
local Delegate = require('Utils.Delegate')
local IEventDispatcher = FairyGUI.IEventDispatcher
local EventBridge = FairyGUI.EventBridge
local InputEvent = FairyGUI.InputEvent

--========================= 声明回调委托=========================
---@class FairyGUI.EventCallback0:Delegate
FairyGUI.EventCallback0 = Delegate.newDelegate("EventCallback0")
---@class FairyGUI.EventCallback1:Delegate
FairyGUI.EventCallback1 = Delegate.newDelegate("EventCallback1")


--========================= FairyGUI.EventDispatcher ===========
---@class FairyGUI.EventDispatcher:FairyGUI.IEventDispatcher
local EventDispatcher = {
    ---@type table<string, FairyGUI.EventBridge>
    _dic = {},
}
EventDispatcher = Class.inheritsFrom('EventDispatcher', EventDispatcher, IEventDispatcher)

---@param strType string
---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function EventDispatcher:AddEventListener(strType, callback, obj)
    assert(strType, "event type cant be null")
    local bridge = self._dic[strType]
    if nil == bridge then
        bridge = EventBridge.new()
        self._dic[strType] = bridge
    end
    bridge:Add(callback, obj)
end

---@param strType string
---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function EventDispatcher:RemoveEventListener(strType, callback, obj)
    if nil == self._dic then return end

    local bridge = self._dic[strType]
    if bridge then
        bridge:Remove(callback, obj)
    end
end

---@param strType string|nil
function EventDispatcher:RemoveEventListeners(strType)
    if nil == self._dic then return end

    if nil ~= strType then
        local bridge = self._dic[strType]
        if bridge then bridge:Clear() end
        return
    end

    for k, v in pairs(self._dic) do
        v:Clear()
    end
end

---@param self FairyGUI.EventDispatcher
---@param strType string
local function TryGetEventBridge(self, strType)
    if nil == self._dic then return nil end

    local bridge = self._dic[strType]
    if nil == bridge then
        bridge = EventBridge.new()
        self._dic[strType] = bridge
    end
    return bridge
end

---@param self FairyGUI.EventDispatcher
---@param strType string
local function GetEventBridge(self, strType)
    if nil == self._dic then self._dic = {} end

    local bridge = self._dic[strType]
    if nil == bridge then
        bridge = EventBridge.new()
    end

    return bridge
end

EventDispatcher.sCurrentInputEvent = InputEvent()
local function InternalDispatchEvent(strType, bridge, data, initiator)
    if bridge ==
end

---@param strType string
---@param data any
---@param initiator any
---@return boolean
function EventDispatcher:DispatchEvent(strType, data, initiator)
    return InternalDispatchEvent(strType, null, data, initiator)
end

FairyGUI.EventDispatcher = EventDispatcher
return EventDispatcher