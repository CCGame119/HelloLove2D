--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 16:20
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

---@class FairyGUI.UIObjectFactory.GComponentCreator:Delegate @fun():FairyGUI.GComponent
local GComponentCreator = Delegate.newDelegate('GComponentCreator')

---@class FairyGUI.UIObjectFactory.GLoaderCreator:Delegate @fun():FairyGUI.GLoader
local GLoaderCreator = Delegate.newDelegate('GLoaderCreator')

---@type FairyGUI.UIObjectFactory
local UIObjectFactory = Class.inheritsFrom('UIObjectFactory')

UIObjectFactory.GComponentCreator = GComponentCreator
UIObjectFactory.GLoaderCreator = GLoaderCreator
FairyGUI.UIObjectFactory = UIObjectFactory
return UIObjectFactory