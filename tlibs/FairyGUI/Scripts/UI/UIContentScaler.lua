--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/1 16:24
--

local Class = require('libs.Class')

local LuaBehaviour = Love2DEngine.LuaBehaviour

---@type FairyGUI.UIContentScaler
local UIContentScaler = Class.inheritsFrom('UIContentScaler', {
    fallbackScreenDPI = 96,
    defaultSpriteDPI = 96,
    constantScaleFactor = 1,
    ignoreOrientation = false,
    scaleFactor = 1,
}, LuaBehaviour)

---@class FairyGUI.UIContentScaler.ScaleMode:enum
local ScaleMode = {
    ConstantPixelSize = 0,
    ScaleWithScreenSize = 1,
    ConstantPhysicalSize = 2,
}

---@class FairyGUI.UIContentScaler.ScreenMatchMode:enum
local ScreenMatchMode = {
    MatchWidthOrHeight = 0,
    MatchWidth = 1,
    MatchHeight = 2,
}

UIContentScaler.ScaleMode = ScaleMode
UIContentScaler.ScreenMatchMode = ScreenMatchMode
FairyGUI.UIContentScaler = UIContentScaler
return UIContentScaler