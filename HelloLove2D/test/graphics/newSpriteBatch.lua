--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/28 17:31
--

local Screen = require('libs.Love2DEngine.Devices.Screen')
local graphics = love.graphics

local img_logo = graphics.newImage('assets/textures/O.png')
local img_w, img_h = img_logo:getDimensions()

local maxsprites = 100
local spriteBatch = graphics.newSpriteBatch(img_logo, maxsprites)
for i = 1, maxsprites do
    spriteBatch:add(math.random(0, Screen.w), math.random(0, Screen.h))
end
spriteBatch:add( x, y, r, sx, sy, ox, oy, kx, ky )
function graphics_case.newSpriteBatch_cases()
    graphics.draw(spriteBatch)
end