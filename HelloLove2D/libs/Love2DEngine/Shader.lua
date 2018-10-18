--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 10:22
--

local Class = require('libs.Class')

local Object = Love2DEngine.Object

---@class Love2DEngine.Shader:Love2DEngine.Object
local Shader = Class.inheritsFrom('Shader', nil, Object)

--TODO: Love2DEngine.Shader

Love2DEngine.Shader = Shader
return Shader