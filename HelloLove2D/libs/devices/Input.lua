--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 13:17
--

local keyboard = love.keyboard
local mouse = love.mouse

---@class Input:table @虚拟摇杆
local Input = {}

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
function Input:isResetDown()
    return keyboard.isDown('r')
end

return Input