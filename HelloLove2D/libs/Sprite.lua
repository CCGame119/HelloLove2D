--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 14:14
--

local Class = require('libs.Class')
local Pool = require('libs.Pool')
local graphics = love.graphics

local t = { x = 0, y = 0, speed = 0, uri = '', img = nil, __get={}}

---@class Sprite:Class @ 精灵类
---@field public x number @ 坐标x
---@field public y number @ 坐标y
---@field public speed number @ 速度
---@field public uri number @ 资源uri
---@field private img number @ 资源
---@field private pool Pool @ 对象池
local Sprite = Class.inheritsFrom('Sprite', t)

--- 回调：构造函数
function Sprite:__ctor(...)
    self:init()
end

--- 回调：类类型构造函数
---@generic T:Sprite
---@param cls T
function Sprite.__cls_ctor(cls)
    cls.pool = Pool.new(cls)
end

--- 初始化精灵
---@param x number @ 坐标x
---@param y number @ 坐标y
---@param speed number @ 速度speed
---@param uri number @ 资源uri
function Sprite:init(x, y, speed, uri)
    self.x = x or self.x
    self.y = y or self.y
    self.speed = speed or self.speed
    self.uri = uri or self.uri
    self.img = graphics.newImage(self.uri)
    self:updateWH()
    return self
end

--- 渲染精灵
function Sprite:onDraw()
    if self.img then
        graphics.draw(self.img, self.x, self.y)
    end
end

--- 更新宽高
function Sprite:updateWH()
    if self.img then
        self.w = self.img:getWidth()
        self.h = self.img:getHeight()
    else
        self.w, self.h = 0, 0
    end
end

--- 返回精灵包围盒
---@return number, number, number, number @x,y,w,h
function Sprite:bound()
    return self.x, self.y, self.w, self.h
end

--- 工厂函数
---@generic T : Sprite
---@param cls T
---@return T
function Sprite.get(cls)
    return cls.pool:pop()
end

---@generic T : Sprite
---@param obj T
function Sprite.recycle(cls, obj)
    cls.pool:push(obj)
end

local __get = Class.init_get(Sprite)
__get.name = function (self)
    return 'Sprite'
end

return Sprite