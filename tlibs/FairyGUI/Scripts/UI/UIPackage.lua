--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/25 11:22
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

---@class FairyGUI.UIPackage.CreateObjectCallback:Delegate @fun(result:FairyGUI.GObject):string
local CreateObjectCallback = Delegate.newDelegate('CreateObjectCallback')

---@class FairyGUI.UIPackage.LoadResource:Delegate @fun(name:string, extension:string, type:Love2DEngine.AssetType):FairyGUI.DestroyMethod|any
local LoadResource = Delegate.newDelegate('LoadResource')

---@type FairyGUI.UIPackage.AtlasSprite
local AtlasSprite = Class.inheritsFrom('AtlasSprite')

---@type FairyGUI.UIPackage
local UIPackage = Class.inheritsFrom('UIPackage')

UIPackage.AtlasSprite = AtlasSprite
UIPackage.LoadResource = LoadResource
UIPackage.CreateObjectCallback = CreateObjectCallback
FairyGUI.UIPackage = UIPackage
return UIPackage