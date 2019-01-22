--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 10:22
--

local Class = require('libs.Class')

local Object = Love2DEngine.Object

---@class Love2DEngine.Shader:Love2DEngine.Object
---@field public hideFlags Love2DEngine.HideFlags
---@field private _Shaders table<string, Love2DEngine.Shader> @所有的Shader列表
local Shader = Class.inheritsFrom('Shader', nil, Object)

--region Love2DEngine.Shader 静态成员
Shader._Shaders = {}
--endregion

---@param name string
---@return Love2DEngine.Shader
function Shader.Find(name)
    --TODO: Shader.Find
    local shader = Shader._Shaders[name]
    if nil == shader then
        shader = Shader.new()
        Shader._Shaders[name] = shader
    end
    return shader
end

--TODO: Love2DEngine.Shader

Love2DEngine.Shader = Shader
return Shader