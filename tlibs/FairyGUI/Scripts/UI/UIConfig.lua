--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/17 15:38
--

local Class = require('libs.Class')

local LuaBehavior = Love2DEngine.LuaBehaviour

---@class FairyGUI.UIConfig:Love2DEngine.LuaBehaviour
local UIConfig = Class.inheritsFrom('UIConfig', nil, LuaBehavior)

UIConfig.depthSupportForPaintingMode = false

--TODO: FairyGUI.UIConfig

FairyGUI.UIConfig = UIConfig
return UIConfig