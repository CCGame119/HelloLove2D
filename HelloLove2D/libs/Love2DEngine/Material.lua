--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 15:17
--

local Class = require('libs.Class')

local Object = Love2DEngine.Object

---@class Love2DEngine.Material:Love2DEngine.Object
---@field mainTexture Love2DEngine.Texture
local Material = Class.inheritsFrom('Material', nil, Object)

---@overload fun(name:string)
---@param id number
---@param value Love2DEngine.Texture
function Material:SetTexture(id, value)
    --TODO: Material:SetTexture
end

---@param keyword string
function Material:EnableKeyword(keyword)
    --TODO: Material:EnableKeyword
end

--TODO: Love2DEngine.Material

Love2DEngine.Material = Material
return Material