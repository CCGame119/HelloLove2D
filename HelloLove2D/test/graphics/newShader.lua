--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/28 16:43
--
local Screen = require('libs.devices.Screen')
local graphics = love.graphics

local img_logo = graphics.newImage('assets/textures/O.png')
local img_w, img_h = img_logo:getDimensions()

local shader = love.graphics.newShader('assets/shaders/demo.shader')

function graphics_case.newShader_cases()
    love.graphics.setShader(shader)
    graphics.draw(img_logo, Screen.pos(0.2, 0.2))
    love.graphics.setShader()
    graphics.draw(img_logo, Screen.pos(0.4, 0.4))
end
