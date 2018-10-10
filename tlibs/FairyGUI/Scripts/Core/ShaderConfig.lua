--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 12:00
--

local Class = require('libs.Class')

---@class FairyGUI.ShaderConfig:ClassType
---@field imageShader string
local ShaderConfig = Class.inheritsFrom('ShaderConfig')

ShaderConfig.imageShader = "FairyGUI/Image"

---@param name string
function ShaderConfig.GetShader(name)
    --TODO: ShaderConfig.GetShader
end

--TODO: FairyGUI.ShaderConfig

FairyGUI.ShaderConfig = ShaderConfig
return ShaderConfig