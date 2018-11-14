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
---@field public fileName string
---@field private loaded boolean
local IUISource = Class.inheritsFrom('IUISource')

---@param callback FairyGUI.UILoadCallback
function IUISource:Load(callback) end

FairyGUI.UILoadCallback = UILoadCallback
FairyGUI.IUISource = IUISource
return IUISource