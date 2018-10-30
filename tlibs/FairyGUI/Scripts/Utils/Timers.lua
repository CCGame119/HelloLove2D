--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 19:02
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

---@class FairyGUI.TimerCallback:Delegate @fun(param:any)
local TimerCallback = Delegate.newDelegate('TimerCallback')

---@class FairyGUI.Timers:ClassType
local Timers = Class.inheritsFrom('Timers')

--TODO: FairyGUI.Timers

FairyGUI.Timers = Timers
return Timers