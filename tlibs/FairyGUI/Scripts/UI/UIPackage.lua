--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/25 11:22
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

---@class FairyGUI.UIPackage.CreateObjectCallback:Delegate @fun(result:FairyGUI.GObject)
local CreateObjectCallback = Delegate.newDelegate('CreateObjectCallback')

---@class FairyGUI.UIPackage:ClassType
local UIPackage = Class.inheritsFrom('UIPackage')

--TODO: FairyGUI.UIPackage

UIPackage.CreateObjectCallback = CreateObjectCallback
FairyGUI.UIPackage = UIPackage
return UIPackage