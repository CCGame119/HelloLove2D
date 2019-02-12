--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/17 10:05
--

local Class = require('libs.Class')

local Texture = Love2DEngine.Texture
local AssetItem = Love2DEngine.AssetItem

---@class Love2DEngine.Texture2D:Love2DEngine.Texture
---@field public width number
---@field public height number
---@field private _img Love2DEngine.AssetItem
---@field private _width number
---@field private _height number
---@field private _format Love2DEngine.TextureFormat
local Texture2D = Class.inheritsFrom('Texture2D', nil, Texture)

---@overload fun(img:Love2DEngine.AssetItem)
---@param width number
---@param height number
---@param format Love2DEngine.TextureFormat
function Texture2D:__ctor(width, height, format)
    if Class.isa(width, AssetItem) then
        self._img = width
        self._width = self._img.width
        self._height = self._img.height
        self._format = self._img.format
    else
        self._width = width
        self._height = height
        self._format = format
    end
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

local __get = Class.init_get(Texture2D)
local __set = Class.init_set(Texture2D)

---@param self Love2DEngine.Texture2D
__get.width = function(self)
    return self._width
end

---@param self Love2DEngine.Texture2D
__get.height = function(self)
    return self._height
end

---@param self Love2DEngine.Texture2D
__get.format = function(self)
    return self._format
end

Love2DEngine.Texture2D = Texture2D
return Texture2D