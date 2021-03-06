--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 13:17
--
local Class = require('libs.Class')

local keyboard = love.keyboard
local mouse = love.mouse

---@class Love2DEngine.TouchPhase:enum
local TouchPhase = {
    Began = 0,
    Moved = 1,
    Stationary = 2,
    Ended = 3,
    Canceled = 4,
}

---@class Love2DEngine.Input:ClassType @虚拟摇杆
local Input = Class.inheritsFrom('Input')

--- 获取摇杆水平和垂直输入比值
---@return number, number @rx: 水平输入比值，ry: 垂直输入比值
function Input.getJoyStickInput()
    local rx, ry = 0, 0

    --- virtical input
    if keyboard.isDown('left', 'a') then rx = -1 end
    if keyboard.isDown('right', 'd') then rx = rx + 1 end

    --- horizontal input
    if keyboard.isDown('up', 'w') then ry = -1 end
    if keyboard.isDown('down', 's') then ry = ry + 1 end

    return rx, ry
end

--- 射击按钮
function Input.isFireKeyDown()
    return keyboard.isDown('space', 'rctrl', 'lctrl') or mouse.isDown(1)
end

--- 重置按钮
function Input.isResetDown()
    return keyboard.isDown('r')
end

---@param keyCode Love2DEngine.KeyCode
function Input.GetKeyUp(keyCode)
    return not keyboard.isDown()
end

---@param keyCode Love2DEngine.KeyCode
function Input.GetKeyDown(keyCode)
    return keyboard.isDown()
end

local __get = Class.init_get(Input, true)

__get.touchCount = function(self)
    local touches = love.touch.getTouches()
    return #touches
end

Love2DEngine.TouchPhase = TouchPhase
Love2DEngine.Input = Input
setmetatable(Input, Input)
return Input