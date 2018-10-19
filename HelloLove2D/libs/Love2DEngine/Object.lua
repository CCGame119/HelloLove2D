--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/17 10:13
--

local Class = require('libs.Class')

local GameObject = Love2DEngine.GameObject

---@class Love2DEngine.Object:ClassType
---@field public name string
---@field public hideFlags Love2DEngine.HideFlags
local Object = Class.inheritsFrom('Object')

---@generic T:Love2DEngine.Object
---@param obj T
---@param allowDestroyingAssets boolean
function Object.DestroyImmediate(obj, allowDestroyingAssets)
    --TODO: Object.DestroyImmediate
    if obj:isa(GameObject) then
        GameObject.recycle(obj)
    end
end

---@generic T:Love2DEngine.Object
---@param obj T
---@param t number
function Object.Destroy(obj, t)
    --TODO: Object.Destroy
    if obj:isa(GameObject) then
        GameObject.recycle(obj)
    end
end

--TODO: Love2DEngine.Object

Love2DEngine.Object = Object
return Object