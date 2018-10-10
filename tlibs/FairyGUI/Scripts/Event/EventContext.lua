--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 18:06
--
local Class = require('libs.Class')
local lua_type = type

---@class FairyGUI.EventContext:ClassType
---@field public sender FairyGUI.EventDispatcher
---@field public initiator any
---@field public inputEvent FairyGUI.InputEvent
---@field public type string
---@field public data any
---@field public _defaultPrevented boolean
---@field public _stopsPropagation boolean
---@field public _touchCapture boolean
---@field public callChain FairyGUI.EventBridge[]
local EventContext = Class.inheritsFrom('EventContext')

function EventContext:__ctor(...)
    self.callChain = {}
end

function EventContext:StopPropagation()
    self._stopsPropagation = true
end

function EventContext:PreventDefault()
    self._defaultPrevented = true
end

function EventContext:CaptureTouch()
    self._touchCapture = true
end

--================= static ========================
---@type FairyGUI.EventContext[]
EventContext.pool = {}

---@return FairyGUI.EventContext
function EventContext.Get()
    local pool = EventContext.pool
    if #pool > 0 then
        ---@type FairyGUI.EventContext
        local context = table.remove(pool)
        context._stopsPropagation = false
        context._defaultPrevented = false
        context._touchCapture = false
        return context
    else
        return EventContext.new()
    end
end

---@param val FairyGUI.EventContext
function EventContext.Return()
    local pool = EventContext.pool
    table.insert(pool, val)
end


--===============属性访问器================
local get = Class.init_get(EventContext)

---@param self FairyGUI.EventContext
get.isDefaultPrevented = function(self)
    return self._defaultPrevented
end

FairyGUI.EventContext = EventContext
return EventContext