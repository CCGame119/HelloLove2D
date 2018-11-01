--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 12:29
--
local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

--========================= 声明回调委托=========================
---@class FairyGUI.EventCallback0:Delegate @fun()
local EventCallback0 = Delegate.newDelegate("EventCallback0")
---@class FairyGUI.EventCallback1:Delegate @fun(context:FairyGUI.EventContext)
local EventCallback1 = Delegate.newDelegate("EventCallback1")

---@class FairyGUI.IEventDispatcher : ClassType
local IEventDispatcher = Class.inheritsFrom("IEventDispatcher")

---@param strType string
---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function IEventDispatcher:AddEventListener(strType, callback)end

---@param strType string
---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function IEventDispatcher:RemoveEventListener(strType, callback)end

FairyGUI.EventCallback0 = EventCallback0
FairyGUI.EventCallback1 = EventCallback1
FairyGUI.IEventDispatcher = IEventDispatcher
return IEventDispatcher