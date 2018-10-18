--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 14:02
--

local Class = require('libs.Class')

local Behaviour = Love2DEngine.Behaviour
local Ray = Love2DEngine.Ray

---@class Love2DEngine.Camera:Love2DEngine.Behaviour
local Camera = Class.inheritsFrom('Camera', nil , Behaviour)

---@param position Love2DEngine.Vector3
function Camera:ScreenToWorldPoint(position)
    --TODO: Camera:ScreenToWorldPoint
    return position
end

---@param position Love2DEngine.Vector3
function Camera:WorldToScreenPoint(position)
    --TODO: Camera:WorldToScreenPoint
    return position
end

---@param position Love2DEngine.Vector3
function Camera:ScreenPointToRay(position)
    --TODO: Camera:ScreenPointToRay
    return Ray(position, position)
end

--TODO: Love2DEngine.Camera

Love2DEngine.Camera = Camera
return Camera