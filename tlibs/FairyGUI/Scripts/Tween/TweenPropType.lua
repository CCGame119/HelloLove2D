--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:02
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject

---@class FairyGUI.TweenPropType:enum
local TweenPropType = {
    None = 0 ,
    X = 1 ,
    Y = 2 ,
    Z = 3 ,
    XY = 4 ,
    Position = 5 ,
    Width = 6 ,
    Height = 7 ,
    Size = 8 ,
    ScaleX = 9 ,
    ScaleY = 10,
    Scale = 11,
    Rotation = 12,
    RotationX = 13,
    RotationY = 14,
    Alpha = 15,
    Progress = 16,
}

---@class FairyGUI.TweenPropTypeUtils:ClassType
local TweenPropTypeUtils = Class.inheritsFrom('TweenPropTypeUtils')
local m = TweenPropType

---@generic T:FairyGUI.GObject
---@param target T
---@param propType FairyGUI.TweenPropType
---@param val FairyGUI.TweenValue
function TweenPropTypeUtils.SetProps(target, propType, val)
    if not target:isa(GObject) then
        return
    end

    local g = target

    if propType == m.X then
        g.x = val
    elseif propType == m.Y then
        g.y = val.x
    elseif propType == m.Z then
        g.z = val.x
    elseif propType == m.XY then
        g.xy:Assign(val.vec2)
    elseif propType == m.Position then
        g.position:Assign(val.vec3)
    elseif propType == m.Width then
        g.width = val.x
    elseif propType == m.Height then
        g.height = val.x
    elseif propType == m.Size then
        g.size:Assign(val.vec2)
    elseif propType == m.ScaleX then
        g.scaleX = val.x
    elseif propType == m.ScaleY then
        g.scaleY = val.x
    elseif propType == m.Scale then
        g.scale:Assign(val.vec2)
    elseif propType == m.Rotation then
        g.rotation = val.x
    elseif propType == m.RotationX then
        g.rotationX = val.x
    elseif propType == m.RotationY then
        g.rotationY = val.x
    elseif propType == m.Alpha then
        g.alpha = val.x
    elseif propType == m.Progress then
        g.asProgress:Update(val.d)
    end
end

FairyGUI.TweenPropTypeUtils = TweenPropTypeUtils
FairyGUI.TweenPropType = TweenPropType
return TweenPropType