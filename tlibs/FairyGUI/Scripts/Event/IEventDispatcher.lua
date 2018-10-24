--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 12:29
--
local Class = require('libs.Class')

---@class FairyGUI.IEventDispatcher : ClassType
local IEventDispatcher = Class.class("IEventDispatcher")

---@param strType string
---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function IEventDispatcher:AddEventListener(strType, callback)end

---@param strType string
---@param callback FairyGUI.EventCallback0|FairyGUI.EventCallback1
function IEventDispatcher:RemoveEventListener(strType, callback)end

FairyGUI.IEventDispatcher = IEventDispatcher
return IEventDispatcher