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

--TODO: FairyGUI.CaptureCamera

FairyGUI.CaptureCamera = CaptureCamera
return CaptureCamera