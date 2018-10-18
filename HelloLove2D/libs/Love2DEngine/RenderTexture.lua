--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/17 15:42
--

local Class = require('libs.Class')

local Texture = Love2DEngine.Texture

---@class Love2DEngine.RenderTexture:Love2DEngine.Texture
local RenderTexture = Class.inheritsFrom('RenderTexture', nil, Texture)

--TODO: Love2DEngine.RenderTexture

Love2DEngine.RenderTexture = RenderTexture
return RenderTexture