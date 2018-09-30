--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 15:29
--
local Class = require('libs.Class')
local Pool = require('libs.Pool')
local Sprite = require('libs.Sprite')

local t = { x = 0, y = 0, speed = 200, uri = 'assets/textures/enemy.png', img = nil}

---@class Enemy : Sprite @ 敌人类
local Enemy = Class.class('Enemy', t, Sprite)

function Enemy:move(dt)
    self.y = self.y + self.speed * dt
end

return Enemy