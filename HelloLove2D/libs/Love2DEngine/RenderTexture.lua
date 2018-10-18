--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/17 15:42
--

local Class = require('libs.Class')

local Texture = Love2DEngine.Texture

---@class Love2DEngine.TextureWrapMode:enum
local TextureWrapMode =
{
    Repeat = 0,
    Clamp = 1,
    Mirror = 2,
    MirrorOnce = 3,
}

---@class Love2DEngine.FilterMode:enum
local FilterMode =
{
    Point = 0,
    Bilinear = 1,
    Trilinear = 2,
}

---@class Love2DEngine.RenderTexture:Love2DEngine.Texture
local RenderTexture = Class.inheritsFrom('RenderTexture', nil, Texture)

--TODO: Love2DEngine.RenderTexture

Love2DEngine.TextureWrapMode = TextureWrapMode
Love2DEngine.FilterMode = FilterMode
Love2DEngine.RenderTexture = RenderTexture
return RenderTexture