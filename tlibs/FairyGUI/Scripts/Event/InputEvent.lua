--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 9:54
--
local Class = require('libs.Class')
local Vector2 = Love2DEngine.Vector2
local EventModifiers = FairyGUI.EventModifiers

---@class FairyGUI.InputEvent:ClassType
---@field public x number
---@field public y number
---@field public keyCode string
---@field public character string
---@field public modifiers FairyGUI.EventModifiers
---@field public mouseWheelDelta number
---@field public touchId number
---@field public button number @-1-none,0-left,1-right,2-middle
---@field public clickCount number
---@field public shiftDown boolean @class field
local InputEvent = Class.inheritsFrom("InputEvent", {button = -1,
                                              clickCount = 0,})

---================= static ========================
InputEvent.shiftDown = false

function InputEvent:__ctor(...)
    self.touchId = -1
    self.x, self.y = 0, 0
    self.clickCount = 0
    self.keyCode = ''
    self.character = '\0'
    self.modifiers = 0
    self.mouseWheelDelta = 0
end

---InputEvent() constructor
local mt = getmetatable(InputEvent)
mt.__call = function(t) return InputEvent.new() end

local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

--=======================属性访问器=======================
local get = Class.init_get(InputEvent)

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
    return InputEvent.shiftDown
end

---@param self InputEvent
get.alt = function(self)
    --keyboard.isDown('ralt', 'lalt')
    return 0 ~= band(self.modifiers, EventModifiers.Alt)
end


FairyGUI.InputEvent = InputEvent
return InputEvent