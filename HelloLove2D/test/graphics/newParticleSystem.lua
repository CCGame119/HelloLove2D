--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/28 15:10
--

--- 粒子系统

local Screen = require('libs.devices.Screen')
local graphics = love.graphics

local img_logo = graphics.newImage('assets/textures/O.png')
local img_w, img_h = img_logo:getWidth(), img_logo:getHeight()


psystem = graphics.newParticleSystem(img_logo, 64)
psystem:setParticleLifetime(2, 5) -- Particles live at least 2s and at most 5s.
psystem:setEmissionRate(10)
psystem:setSizeVariation(0.5)
psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.

function graphics_case.newParticleSystem_cases()
    -- Draw the particle system at the center of the game window.
    psystem:moveTo(love.mouse:getPosition())
    graphics.draw(psystem, Screen.pos(0, 0))
end