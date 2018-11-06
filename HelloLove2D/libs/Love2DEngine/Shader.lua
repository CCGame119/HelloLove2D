--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 10:22
--

local Class = require('libs.Class')

local Object = Love2DEngine.Object

---@class Love2DEngine.Shader:Love2DEngine.Object
local Shader = Class.inheritsFrom('Shader', nil, Object)

---@param name string
---@return Love2DEngine.Shader
function Shader.Find(name)
    --TODO: Shader.Find
end

--TODO: Love2DEngine.Shader

Love2DEngine.Shader = Shader
return Shader