--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 13:42
--
local Class = require('libs.Class')
local Sprite = require('libs.Sprite')
local Pool = require('libs.Pool')
local graphics = love.graphics

local t = {x = 0, y = 0, speed = 500, uri = 'assets/textures/bullet.png', img = nil}

---@class Bullet:Sprite @ 子弹类
local Bullet = Class.inheritsFrom('Bullet', t, Sprite)

function Bullet:move(dt)
    self.y = self.y - self.speed * dt
end

Bullet:init()

return Bullet