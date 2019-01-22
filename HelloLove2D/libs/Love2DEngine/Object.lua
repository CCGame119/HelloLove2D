--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/17 10:13
--

local Class = require('libs.Class')
local Pool = require('libs.Pool')

local HideFlags = Love2DEngine.HideFlags

local GameObject = Love2DEngine.GameObject

---@class Love2DEngine.Object:ClassType
---@field public name string
---@field public hideFlags number @default Love2DEngine.HideFlags.None
---@field protected pool Pool @class static
local Object = Class.inheritsFrom('Object', {hideFlags = HideFlags.None})

--- 回调：类类型构造函数
---@generic T:Love2DEngine.Object
---@param cls:T
function Object.__cls_ctor(cls)
    cls.pool = Pool.new(cls)
end

--- 工厂函数
---@generic T : Love2DEngine.Object
---@param cls T
---@return T
function Object.get(cls)
    return cls.pool:pop()
end

---@generic T : Love2DEngine.Object
---@param obj T
function Object.recycle(cls, obj)
    cls.pool:push(obj)
end


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
    t = t or 0
    --TODO: Object.Destroy
    if obj:isa(GameObject) then
        GameObject.recycle(obj)
    end
end

---@generic T:Love2DEngine.Object
---@param t T
function Object.FindObjectOfType(t)
    --TODO: Object.FindObjectOfType
end

---@param t Love2DEngine.Object
function Object.DontDestroyOnLoad(t)
    --TODO: Object.DontDestroyOnLoad
end

--TODO: Love2DEngine.Object

Love2DEngine.Object = Object
return Object