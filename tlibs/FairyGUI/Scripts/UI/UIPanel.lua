--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/20 14:05
--

local Class = require('libs.Class')

local LuaBehaviour = Love2DEngine.LuaBehaviour

local EMRenderTarget = FairyGUI.EMRenderTarget

---@class FairyGUI.UIPanel:Love2DEngine.LuaBehaviour
local UIPanel = Class.inheritsFrom('UIPanel', nil, LuaBehaviour, {EMRenderTarget})

--TODO: FairyGUI.EMRenderTarget

FairyGUI.UIPanel = UIPanel
return UIPanel