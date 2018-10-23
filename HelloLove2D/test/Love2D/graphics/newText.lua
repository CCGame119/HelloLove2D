--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/28 17:39
--
local Screen = require('libs.Love2DEngine.Devices.Screen')
local graphics = love.graphics
local font_STLITI = graphics_case.fonts.STLITI
local font_STLITI24 = graphics_case.fonts.STLITI24
local font_STLITI40 = graphics_case.fonts.STLITI40
local txt_a = graphics.newText(font_STLITI, "你好ag，这个是华为隶书！")
local txt_1 = graphics.newText(font_STLITI40, "你")
local txt_2 = graphics.newText(font_STLITI24, "afgAFG")
--txt_2:setf({{1,0,0,1}, "afg你好", {1,0,1,1}, "这是",{1,1,0,1},'测试'}, 200, 'left')
function graphics_case.newText_cases()
    graphics.draw(txt_a, Screen.pos(0.5, 0.5))
    graphics.draw(txt_1, 100, 100)
    graphics.draw(txt_2, 100 + txt_1:getWidth(), 100 - font_STLITI24:getAscent() + font_STLITI40:getAscent())
    graphics.draw(txt_1, 100, 200)
    graphics.draw(txt_2, 100 + txt_1:getWidth(), 200 - txt_2:getHeight() + txt_1:getHeight())
end