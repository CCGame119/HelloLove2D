--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 10:52
--

local Class = require('libs.Class')

---@class FairyGUI.PackageItem:ClassType
---@field public owner FairyGUI.UIPackage
---@field public type FairyGUI.PackageItemType
---@field public objectType FairyGUI.ObjectType
---@field public id string
---@field public name string
---@field public width number
---@field public height number
---@field public file string
---@field public exported boolean
---@field public texture FairyGUI.NTexture
---@field public rawData Utils.ByteBuffer
---@image
---@field public scale9Grid Love2DEngine.Rect
---@field public scaleByTile bool
---@field public tileGridIndice number
---@field public pixelHitTestData FairyGUI.PixelHitTestData
---@movieclip
---@field public numbererval number
---@field public repeatDelay number
---@field public swing bool
---@field public frames FairyGUI.MovieClip.Frame[]
---@component
---@field public translated bool
---@field public extensionCreator FairyGUI.UIObjectFactory.GComponentCreator
---@font
---@field public bitmapFont FairyGUI.BitmapFont
---@sound
---@field public audioClip FairyGUI.NAudioClip
local PackageItem = Class.inheritsFrom('PackageItem')

function PackageItem:__ctor()
    return self.owner:GetItemAsset(self)
end

FairyGUI.PackageItem = PackageItem
return PackageItem