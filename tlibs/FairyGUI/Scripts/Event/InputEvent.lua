--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 9:54
--
local Class = require('libs.Class')
local Vector2 = require('MathLibs.Vector2')
local init_get = Class.init_get
local EventModifiers = FairyGUI.EventModifiers

---@class FairyGUI.InputEvent:ClassType
---@field public touchId number
local InputEvent = {
    x = 0,
    y = 0,
    keyCode = '',
    character = '\0',
    modifiers = 0,
    mouseWheelDelta = 0,
    touchId = -1,
    button = 0,

    clickCount = 0,
    shiftDown = 0
}
InputEvent = Class.class("InputEvent", InputEvent)

---InputEvent() constructor
InputEvent.__call = function(t) return InputEvent.new() end

local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

--=======================属性访问器=======================
local get = init_get(InputEvent)

---@param self InputEvent
get.position = function(self)
    return Vector2(self.x, self.y)
end

---@param self InputEvent
get.isDoubleClick = function(self)
    return self.clickCount > 1
end

---@param self InputEvent
get.ctrl = function(self)
    --keyboard.isDown('rctrl', 'lctrl')
    return 0 ~= band(self.modifiers, EventModifiers.Control)
end

---@param self InputEvent
get.shift = function(self)
    --keyboard.isDown('rshift', 'lshift')
    return self.shiftDown
end

---@param self InputEvent
get.alt = function(self)
    --keyboard.isDown('ralt', 'lalt')
    return 0 ~= band(self.modifiers, EventModifiers.Alt)
end


FairyGUI.InputEvent = InputEvent
return InputEvent