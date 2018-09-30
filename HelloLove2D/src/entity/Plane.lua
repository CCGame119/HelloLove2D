--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/20 14:30
--
require('libs.utils.math_ex')
local Class = require('libs.Class')
local Sprite = require('libs.Sprite')
local Bullet = require('src.entity.Bullet')
local Screen = require('libs.devices.Screen')
local graphics = love.graphics

local t = { x = 200, y = 710, speed = 150, uri = 'assets/textures/plane.png', img = nil}

---@class Plane : Sprite @ 飞机类
local Plane = Class.class('Plane', t, Sprite)

function Plane:move(rx, ry, dt)
    self.x = self.x + rx * dt * self.speed
    self.y = self.y + ry * dt * self.speed

    local half_w, half_h = self.w / 2, self.h / 2
    self.x = math.clamp(self.x, -half_w, Screen.w - half_w)
    self.y = math.clamp(self.y, -half_h, Screen.h - half_h)
end

function Plane:bulletSpawnPoint()
    return self.x + self.w / 2 - Bullet.w / 2, self. y
end

return Plane