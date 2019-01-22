--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 12:05
--

local Class = require('libs.Class')

local LuaBehaviour = Love2DEngine.LuaBehaviour

---@type FairyGUI.CaptureCamera
local CaptureCamera = Class.inheritsFrom('CaptureCamera', nil, LuaBehaviour)

FairyGUI.CaptureCamera = CaptureCamera
setmetatable(CaptureCamera, CaptureCamera)
return CaptureCamera