--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/28 17:39
--
local Screen = require('libs.devices.Screen')
local graphics = love.graphics
local font_STLITI = graphics_case.fonts.STLITI
local txt_a = graphics.newText(font_STLITI, "你好，这个是华为隶书！")

function graphics_case.newText_cases()
    graphics.draw(txt_a, Screen.pos(0.5, 0.5))
end