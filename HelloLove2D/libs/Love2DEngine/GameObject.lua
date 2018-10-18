--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 13:27
--

local Class = require('libs.Class')
local Pool = require('libs.Pool')
local Transform = Love2DEngine.Transform
local Object = Love2DEngine.Object

---@generic T:Love2DEngine.Component
---@class Love2DEngine.GameObject:Love2DEngine.Object
---@field public transform Love2DEngine.Transform
---@field public layer number
---@field private _active boolean
---@field private _components table<T, Love2DEngine.Component[]>
local GameObject = Class.inheritsFrom('GameObject', nil, Object)

--- 回调：构造函数
function Sprite:__ctor(...)
    self.transform = Transform.new()
    self:init(...)
end

--- 回调：类类型构造函数
---@generic T:GameObject
---@param cls T
function GameObject.__cls_ctor(cls)
    cls.pool = Pool.new(cls)
end

--- 工厂函数
---@generic T : GameObject
---@param cls T
---@return T
function GameObject.get(cls, ...)
    local gameObject = cls.pool:pop()
    return gameObject:init(...)
end

---@generic T : GameObject
---@param obj T
function GameObject.recycle(cls, obj)
    cls.pool:push(obj)
end

---@param name string
function GameObject:init(name)
    self.name = name or self.name
    return self
end

---@param active boolean
function GameObject:SetActive(active)
    self._active = active
end

---@generic T:Love2DEngine.Component
---@param t T
---@return T
function GameObject:AddComponent(t)
    local comp = t.new()
    if self._components[t] == nil then self._components[t] = {} end
    table.insert(self._components[t], comp)
    return comp
end
--TODO: Love2DEngine.GameObject

Love2DEngine.GameObject = GameObject
return GameObject