--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 15:24
--

local Class = require('libs.Class')

---@class Love2DEngine.Matrix4x4
---@field identity Love2DEngine.Matrix4x4
local Matrix4x4 = {}
Matrix4x4 = Class.inheritsFrom('Matrix4x4', Matrix4x4)

---@param pos Love2DEngine.Vector3
---@param q Love2DEngine.Quaternion
---@param s Love2DEngine.Vector3
---@return Love2DEngine.Matrix4x4
function Matrix4x4.TRS(pos, q, s)
    --TODO: Matrix4x4.TRS
    return nil
end

---@param point Love2DEngine.Vector3
function Matrix4x4:MultiplyPoint(point)
    --TODO: Matrix4x4:MultiplyPoint
    return nil
end

--TODO: Love2DEngine.Matrix4x4

Love2DEngine.Matrix4x4 = Matrix4x4
return Matrix4x4