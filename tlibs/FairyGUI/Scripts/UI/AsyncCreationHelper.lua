--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/8 15:44
--

local Class = require('libs.Class')

local Timers = FairyGUI.Timers
local Stats = FairyGUI.Stats
local UIConfig = FairyGUI.UIConfig

---@class FairyGUI.AsyncCreationHelper:ClassType
local AsyncCreationHelper = Class.inheritsFrom('AsyncCreationHelper')

---@param item FairyGUI.PackageItem
---@param callback FairyGUI.UIPackage.CreateObjectCallback
function AsyncCreationHelper.CreateObject(item, callback)
    Timers.inst:StartCoroutine(AsyncCreationHelper._CreateObject(item, callback))
end

---@param item FairyGUI.PackageItem
---@param callback FairyGUI.UIPackage.CreateObjectCallback
function AsyncCreationHelper:_CreateObject(item, callback)
    Stats.LatestGraphicsCreation = 0
    Stats.LatestObjectCreation = 0

    local frameTime = UIConfig.frameTimeForAsyncUIConstruction
end

--TODO: FairyGUI.AsyncCreationHelper

FairyGUI.AsyncCreationHelper = AsyncCreationHelper
return AsyncCreationHelper