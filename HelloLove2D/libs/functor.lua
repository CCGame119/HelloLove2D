--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 13:33
--

local Debug = Love2DEngine.Debug

local traceback = function(msg)
    Debug.LogError(msg)
    Debug.LogError(debug.traceback())
end

---@class _xpcall
local _xpcall = {}

_xpcall.__call = function(self, ...)
    if jit then
        if nil == self.obj then
            return xpcall(self.func, Debug.traceback or traceback, ...)
        else
            return xpcall(self.func, Debug.traceback or traceback, self.obj, ...)
        end
    else
        local args = {...}

        if nil == self.obj then
            local func = function() self.func(unpack(args)) end
            return xpcall(func, traceback)
        else
            local func = function() self.func(self.obj, unpack(args)) end
            return xpcall(func, traceback)
        end
    end
end

_xpcall.__eq = function(lhs, rhs)
    return lhs.func == rhs.func and lhs.obj == rhs.obj
end

---@param func fun()
---@param obj any
---@return _xpcall
local function xfunctor(func, obj)
    return setmetatable({func = func, obj = obj}, _xpcall)
end

return xfunctor