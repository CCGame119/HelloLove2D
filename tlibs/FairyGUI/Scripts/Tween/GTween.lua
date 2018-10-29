--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 19:37
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2
local Vector3 = Love2DEngine.Vector3
local Vector4 = Love2DEngine.Vector4
local Color = Love2DEngine.Color
local GTweener = FairyGUI.GTweener
local TweenManager = FairyGUI.TweenManager
local TweenPropType = FairyGUI.TweenPropType

---@class FairyGUI.GTween:ClassType
local GTween = Class.inheritsFrom('GTween')

GTween.catchCallbackExceptions = true

---@param startValue number|Love2DEngine.Vector2|Love2DEngine.Vector3|Love2DEngine.Vector4|Love2DEngine.Color
---@param endValue number|Love2DEngine.Vector2|Love2DEngine.Vector3|Love2DEngine.Vector4|Love2DEngine.Color
---@param duration number
---@return FairyGUI.GTweener
function GTween.To(startValue, endValue, duration)
    return TweenManager.CreateTween():_To(startValue, endValue, duration)
end

---@param startValue number
---@param endValue number
---@param duration number
---@return FairyGUI.GTweener
function GTween.ToDouble(startValue, endValue, duration)
    return TweenManager.CreateTween():_To(startValue, endValue, duration)
end

---@param delay number
function GTween.DelayCall(delay)
    return TweenManager.CreateTween():SetDelay(delay)
end

---@param startValue Love2DEngine.Vector3
---@param amplitude number
---@param duration number
---@return FairyGUI.GTweener
function GTween.Shake(startValue, amplitude, duration)
    return TweenManager.CreateTween():_Shake(startValue, amplitude, duration)
end

---@param target any
---@param propType FairyGUI.TweenPropType @default: TweenPropType.None
---@return boolean
function GTween.IsTweening(target, propType)
    return TweenManager.IsTweening(target, propType or TweenPropType.None)
end

---@param target any
---@param propType FairyGUI.TweenPropType @default: TweenPropType.None
---@param complete boolean @default: false
function GTween.Kill(target, propType, complete)
    if type(propType) == 'boolean' then
        complete = propType
    end
    TweenManager.KillTweens(target, propType or TweenPropType.None, complete or false)
end

---@param target any
---@param propType FairyGUI.TweenPropType
---@return FairyGUI.GTweener
function GTween.GetTween(target, propType)
    return TweenManager.GetTween(target, propType)
end

function GTween.Clean()
    TweenManager.Clean()
end

FairyGUI.GTween = GTween
return GTween