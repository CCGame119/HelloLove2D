--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 12:05
--
local Class = require('libs.Class')
local functor = require('libs.functor')

---@class Delegate:ClassType @C#委托模拟
---@field public isEmpty boolean
---@field private _funcs table<_xpcall, _xpcall>
---@field private _count number
---@field private deleg_name string
local Delegate = Class.inheritsFrom('Delegate', {deleg_name = 'Delegate'})

---@param func fun()
---@param obj any
function Delegate:__ctor(func, obj)
    self._count = 0
    self._funcs = {}
    if nil ~= func then
        self:Add(func, obj)
    end
end

---@param deleg_name string
---@param t table @ 初始化列表
function Delegate.newDelegate(deleg_name, t)
    local delegate = Class.inheritsFrom(deleg_name, t, Delegate)
    delegate.deleg_name = deleg_name
    delegate.__call = Delegate.__call
    return delegate
end

---@param func fun()
---@param obj any
function Delegate:Add(func, obj)
    assert(func, 'func is nil')
    local func = functor(func, obj)
    self._funcs[func] = func
    self._count = self._count + 1
end

---@param func fun()
---@param obj any
function Delegate:Remove(func, obj)
    assert(func, 'func is nil')
    local func = functor(func, obj)
    for _, v in pairs(self._funcs) do
        if v == func then
            self._funcs[v] = nil
            self._count = self._count - 1
        end
    end
end

function Delegate:Invoke(...)
    if self._count <= 0  then return nil end

    local retTable
    for _, v in pairs(self._funcs) do
        retTable = {v(...)}
    end
    if #retTable > 0 then
        return unpack(retTable)
    end
    return nil
end

---@generic T:Delegate
---@return T
function Delegate:Clone()
    ---@type Delegate
    local delegate = self:class().new()
    delegate._count = self._count
    for k, v in pairs(self._funcs) do
        delegate._funcs[k] = v
    end
    return delegate
end

Delegate.__call = Delegate.Invoke

function Delegate:Clear()
    self._funcs = {}
    self._count = 0
end

--==============属性访问器================
local __get = Class.init_get(Delegate)

__get.isEmpty = function(self)
    return self._count == 0
end

return Delegate