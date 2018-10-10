--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 16:41
--

local Class = require('libs.Class')

local setmetatable = setmetatable
local graphics = love.graphics

---@class Love2DEngine.Screen @ 屏幕封装类
---@field height number
---@field width number
---@field w number
---@field h number
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

local __get = Class.init_get(Screen)

__get.width = function(self)
    return self.w
end

__get.height = function(self)
    return self.h
end

Screen.updateHW()

Love2DEngine.Screen = Screen
setmetatable(Screen, Screen)
return Screen