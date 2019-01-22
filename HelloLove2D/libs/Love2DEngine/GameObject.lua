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
---@field public active boolean
---@field private _components table<T, Love2DEngine.Component[]>
local GameObject = Class.inheritsFrom('GameObject', nil, Object)

--创建的游戏对象，建议都通过pool的方式获取，不允许私自创建
---@type table<string, Love2DEngine.GameObject[]>
GameObject._gameObjectsGroupByName = {}

--- 回调：GameObject
function GameObject:__ctor(...)
    self:init(...)
end

--- 工厂函数
---@generic T : Love2DEngine.GameObject
---@param cls T
---@param name string
---@return T
function GameObject.get(cls, name)
    ---@type Love2DEngine.GameObject
    local gameObject = cls.pool:pop()
    if GameObject._gameObjectsGroupByName[name] == nil then
        GameObject._gameObjectsGroupByName[name] = {}
    end
    table.insert(GameObject._gameObjectsGroupByName[name], gameObject)
    return gameObject:init(name)
end

---@generic T : Love2DEngine.GameObject
---@param obj T
function GameObject.recycle(cls, obj)
    local group = GameObject._gameObjectsGroupByName[obj.name]
    table.removeElement(group, obj)
    cls.pool:push(obj)
end

---@param name string
function GameObject:init(name)
    self.name = name or self.name or 'GameObject'
    self.active = true
    self._components = {}
    self.transform = self:AddComponent(Transform)
    self.transform:SetParent()
    return self
end

---@param active boolean
function GameObject:SetActive(active)
    self.active = active
end

---@generic T:Love2DEngine.Component
---@param t T
---@return T
function GameObject:AddComponent(t)
    local comp = t.new()
    if self._components[t] == nil then self._components[t] = {} end
    table.insert(self._components[t], comp)
    comp.gameObject = self
    return comp
end

---@generic T:Love2DEngine.Component
---@param t T
---@return T
function GameObject:GetComponent(t)
    if self._components[t] == nil then return nil end
    return self._components[t][1]
end

---@param name string
---@return Love2DEngine.GameObject
function GameObject.Find(name)
    if GameObject._gameObjectsGroupByName[name] == nil then
        return nil
    end
    return GameObject._gameObjectsGroupByName[name][1]
end

---@generic T:Love2DEngine.Object
---@param t T
function GameObject.FindObjectOfType(t)
    Object.FindObjectOfType(t)
end

--TODO: Love2DEngine.GameObject

Love2DEngine.GameObject = GameObject
return GameObject