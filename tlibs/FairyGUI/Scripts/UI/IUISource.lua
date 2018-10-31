--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:45
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

---@class FairyGUI.UILoadCallback:Delegate @fun()
local UILoadCallback = Delegate.newDelegate('UILoadCallback')

---@class FairyGUI.IUISource:ClassType
local IUISource = Class.inheritsFrom('IUISource')

--TODO: FairyGUI.IUISource

FairyGUI.UILoadCallback = UILoadCallback
FairyGUI.IUISource = IUISource
return IUISource