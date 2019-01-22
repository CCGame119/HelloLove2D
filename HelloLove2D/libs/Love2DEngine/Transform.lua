--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 13:37
--

local Class = require('libs.Class')
local Quaternion = Love2DEngine.Quaternion
local Vector2 = Love2DEngine.Vector2
local Vector3 = Love2DEngine.Vector3
local Matrix4x4 = Love2DEngine.Matrix4x4

---@class Love2DEngine.Transform:Love2DEngine.Component
---@field public position Love2DEngine.Vector3
---@field public localPosition Love2DEngine.Vector3
---@field public eulerAngles Love2DEngine.Vector3
---@field public localEulerAngles Love2DEngine.Vector3
---@field public right Love2DEngine.Vector3
---@field public forward Love2DEngine.Vector3
---@field public up Love2DEngine.Vector3
---@field public rotation Love2DEngine.Quaternion
---@field public localRotation Love2DEngine.Quaternion
---@field public localScale Love2DEngine.Vector3
---@field public parent Love2DEngine.Transform
---@field public localToWorldMatrix Love2DEngine.Matrix4x4
---@field public x number local position x
---@field public y number local position y
---@field public z number local position z
---@field public rx number local EulerAngles rx
---@field public ry number local EulerAngles ry
---@field public rz number local EulerAngles rz
---@field public rx number local Scale sx
---@field public ry number local Scale sy
---@field public rz number local Scale sz
---@field public childs Love2DEngine.Transform[]
local Transform = Class.inheritsFrom('Transform', {
    x = 0, y = 0, z = 0,
    rx = 0, ry = 0, rz = 0,
    sx = 1, sy = 1, sz = 1,
})

function Transform:__ctor(...)
    self.childs = {}
    if Transform.root then
        self:SetParent(Transform.root)
    end
end

---Transforms position from local space to world space
---@param x_v number|Love2DEngine.Vector3
---@param y number
---@param z number
function Transform:TransformPoint(x_v, y, z)
    local pos = Vector3()
    if type(x_v) == 'number' then
        pos:Set(x_v, y, z)
    else
        pos:Assign(x_v)
    end

    return pos:Add(self.position)
end

---Transforms position from world space to local space.
---@param x_v number|Love2DEngine.Vector3
---@param y number
---@param z number
function Transform:InverseTransformPoint(x_v, y, z)
    local pos = Vector3()
    if type(x_v) == 'number' then
        pos:Set(x_v, y, z)
    else
        pos:Assign(x_v)
    end

    return pos:Sub(self.position)
end

---@param parent Love2DEngine.Transform
---@param worldPositionStays boolean @default: true
function Transform:SetParent(parent, worldPositionStays)
    parent = parent or Transform.root
    local p = self.localPosition
    local s = self.localScale
    local q = self.localRotation
    if self.parent then
        self.parent:RemoveChild(self)
    end
    self.parent = parent
    self.parent:AddChild(self)
    if not worldPositionStays then
        self.localPosition = p
        self.localScale = s
        self.localRotation = q
    end
end

---@param child Love2DEngine.Transform
function Transform:AddChild(child)
    table.insert(self.childs, child)
end

function Transform:RemoveChild(child)
    table.removeElement(self.childs, child)
end

--TODO: Love2DEngine.Transform
---===============属性访问器======================
local __get = Class.init_get(Transform)
local __set = Class.init_set(Transform)

---@param self Love2DEngine.Transform
__get.position = function(self)
    local pos = self.localPosition
    local p = self.parent
    while p do
        local ppos = p.localPosition
        pos:Add(ppos)
        p = p.parent
    end
    return pos
end

---@param self Love2DEngine.Transform
---@param val Love2DEngine.Vector3
__set.position = function(self, val)
    local pos = val:Clone()
    local p = self.parent
    while p do
        local ppos = p.localPosition
        pos:Add(ppos)
        p = p.parent
    end
    pos:Sub(ppos)
    self.x, self.y, self.z = pos.x, pos.y, pos.z
end

---@param self Love2DEngine.Transform
__get.localPosition = function(self)
    local pos = Vector3(self.x, self.y, self.z)
    return pos
end

---@param self Love2DEngine.Transform
---@param val Love2DEngine.Vector3
__set.localPosition = function(self, val)
    self.x, self.y, self.z = val.x, val.y, val.z
end

---@param self Love2DEngine.Transform
__get.localEulerAngles = function(self)
    return self.localRotation.eulerAngles
end

---@param self Love2DEngine.Transform
---@param val Love2DEngine.Vector3
__set.localEulerAngles = function(self, val)
    self.rx, self.ry, self.rz = val.x, val.y, val.z
end

---@param self Love2DEngine.Transform
__get.localRotation = function(self)
    return Quaternion.Euler(self.rx, self.ry, self.rz)
end

---@param self Love2DEngine.Transform
__get.localScale = function(self)
    local scale = Vector3(self.sx, self.sy, self.sz)
    return scale
end

---@param self Love2DEngine.Transform
---@param val Love2DEngine.Vector3
__set.localScale = function(self, val)
    self.sx, self.sy, self.sz = val.x, val.y, val.z
end

---@param self Love2DEngine.Transform
__get.localToWorldMatrix = function(self)
    local mat = Matrix4x4.Translate(self.position)
    return mat
end

---虚拟根节点
Transform.root = Transform.new()

Love2DEngine.Transform = Transform
return Transform