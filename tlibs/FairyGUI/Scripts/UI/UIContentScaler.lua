--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/1 16:24
--

local Class = require('libs.Class')

local LuaBehaviour = Love2DEngine.LuaBehaviour

---@class FairyGUI.UIContentScaler:Love2DEngine.LuaBehaviour
local UIContentScaler = Class.inheritsFrom('UIContentScaler', nil, LuaBehaviour)

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

--TODO: FairyGUI.UIContentScaler

UIContentScaler.ScaleMode = ScaleMode
UIContentScaler.ScreenMatchMode = ScreenMatchMode
FairyGUI.UIContentScaler = UIContentScaler
return UIContentScaler