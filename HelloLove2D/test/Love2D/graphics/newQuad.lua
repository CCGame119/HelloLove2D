--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/28 16:30
--

---quad 可以用来绘制图集中的指定区域，用途：绘制图集序列帧动画等

local Screen = require('libs.Love2DEngine.Devices.Screen')
local graphics = love.graphics

local img_logo = graphics.newImage('assets/textures/O.png')
local img_w, img_h = img_logo:getDimensions()

function graphics_case.newQuad_cases()
    local top_left = love.graphics.newQuad(0, 0, 32, 32, img_w, img_h)
    local bottom_left = love.graphics.newQuad(0, 32, 32, 32, img_w, img_h)

    love.graphics.draw(img_logo, top_left, 50, 50)
    love.graphics.draw(img_logo, bottom_left, 50, 200)
end