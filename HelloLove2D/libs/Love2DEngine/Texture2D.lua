--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/17 10:05
--

local Class = require('libs.Class')

local Texture = Love2DEngine.Texture

---@class Love2DEngine.Texture2D:Love2DEngine.Texture
local Texture2D = Class.inheritsFrom('Texture2D', nil, Texture)

---@param width number
---@param height number
---@param format Love2DEngine.TextureFormat
---@param mipmap boolean
function Texture2D:__ctor(width, height, format, mipmap)
    --TODO: Texture2D:__ctor
end

---@param x number
---@param y number
---@param color Love2DEngine.Color
function Texture2D:SetPixel(x, y, color)
    --TODO: Texture2D:SetPixel
end

---@param updateMipmaps boolean
---@param makeNoLongerReadable boolean
function Texture2D:Apply(updateMipmaps, makeNoLongerReadable)
    local u = updateMipmaps or true
    local m = makeNoLongerReadable or false
    --TODO: Texture2D:Apply
end

--TODO: Love2DEngine.Texture2D

Love2DEngine.Texture2D = Texture2D
return Texture2D