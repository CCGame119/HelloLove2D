--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 19:45
--
local Class = require('libs.Class')
local DispalyObject = FairyGUI.DisplayObject

---@class FairyGUI.Container : FairyGUI.DisplayObject
---@field public numChildren number
---@field public renderMode Love2DEngine.RenderMode
local Container = Class.inheritsFrom('Container', nil, DisplayObject)

--TODO: FairyGUI.Container

---@param index number
---@return FairyGUI.DisplayObject
function Container:GetChildAt(index)
    --TODO: FairyGUI.Container:GetChildAt
end

---@return Love2DEngine.Camera
function Container:GetRenderCamera()
    --TODO: FairyGUI.Container:GetRenderCamera
end

FairyGUI.Container = Container
return Container