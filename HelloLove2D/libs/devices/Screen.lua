--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 16:41
--
local graphics = love.graphics

---@class Screen @ 屏幕封装类
local Screen = {}

--- 获取屏幕相对位置
---@param rw number @ 宽度百分比
---@param rw number @ 高度百分比
function Screen.pos(rw, rh)
    return Screen.w * rw, Screen.h * rh
end

function Screen.updateHW()
    Screen.w = graphics.getWidth()
    Screen.h = graphics.getHeight()
end

Screen.updateHW()

return Screen