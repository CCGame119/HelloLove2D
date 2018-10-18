--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 12:05
--

local Class = require('libs.Class')

local LuaBehaviour = Love2DEngine.LuaBehaviour

---@class FairyGUI.CaptureCamera:Love2DEngine.LuaBehaviour
---@field hiddenLayer number
local CaptureCamera = Class.inheritsFrom('CaptureCamera', nil, LuaBehaviour)

---@param width number
---@param height number
---@param stencilSupport boolean
---@return Love2DEngine.RenderTexture
function CaptureCamera.CreateRenderTexture(width, height, stencilSupport)
    --TODO: CaptureCamera.CreateRenderTexture
end

--TODO: FairyGUI.CaptureCamera

FairyGUI.CaptureCamera = CaptureCamera
return CaptureCamera