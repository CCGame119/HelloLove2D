--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/17 9:58
--

local Class = require('libs.Class')

local Object = Love2DEngine.Object

---@class Love2DEngine.Texture:Love2DEngine.Object
---@field public width number
---@field public height number
local Texture = Class.inheritsFrom('Texture', nil, Object)

--TODO: Love2DEngine.Texture

Love2DEngine.Texture = Texture
return Texture