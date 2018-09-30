--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 9:54
--
local Class = require('libs.Class')
local init_get = Class.init_get

---@class InputEvent:ClassType
local InputEvent = {
    x = 0,
    y = 0,
    keyCode = '',
    character = '\0',
    modifiers = '',
    mouseWheelDelta = 0,
    touchId = -1,
    button = 0,

    clickCount = 0,
    shiftDown = 0
}
InputEvent = Class.class("InputEvent", InputEvent)


--=======================属性访问器=======================
__get = init_get(InputEvent)

__get.position = function(self)
    return
end

FairyGUI.InputEvent = InputEvent
return InputEvent