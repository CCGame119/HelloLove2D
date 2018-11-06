--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 12:00
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

local Shader = Love2DEngine.Shader
local Debug = Love2DEngine.Debug
local DisplayOptions = Love2DEngine.DisplayOptions

---@class FairyGUI.ShaderConfig:ClassType
---@field imageShader string
local ShaderConfig = Class.inheritsFrom('ShaderConfig')

---@class FairyGUI.ShaderConfig.GetFunction:Delegate @fun(name:string):Love2DEngine.Shader
ShaderConfig.GetFunction = Delegate.newDelegate('GetFunction')

ShaderConfig.Get = Shader.Find

ShaderConfig.imageShader = "FairyGUI/Image"
ShaderConfig.textShader = "FairyGUI/Image"
ShaderConfig.textBrighterShader = "FairyGUI/Image"
ShaderConfig.bmFontShader = "FairyGUI/Image"

---@param name string
function ShaderConfig.GetShader(name)
    local shader = Shader.Get(name)
    if nil == shader then
        Debug.LogWarn("FairyGUI: shader not found: " .. name)
        shader = Shader.Find("UI/Default")
    end
    shader.hideFlags = DisplayOptions.hideFlags
    return shader
end


FairyGUI.ShaderConfig = ShaderConfig
return ShaderConfig