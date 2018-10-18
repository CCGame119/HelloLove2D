--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 14:09
--
local getmetatable = getmetatable
local setmetatable = setmetatable
local type = type
local rawset = rawset
local rawget = rawget
local rawequal = rawequal
local error = error

---@class Class @ Lua 类构造类
local Class = {}
local __index = nil
local __newindex = nil
local __index_with_get = nil
local __newindex_with_set = nil

---为类cls初始化属性访问器__get表
---@generic T:ClassType
---@param cls T
---@param value_cls boolean
---@return table
function Class.init_get(cls, value_cls)
    local value_cls = value_cls or false
    local __get = {}
    rawset(cls, '__get', __get)
    if not value_cls then
        rawset(cls, '__index', __index_with_get)
    else
        local __newindex_with_set_value = function(t, k)
            local var = rawget(cls, k)

            if var == nil then
                var = rawget(__get, k)

                if var ~= nil then
                    return var(t)
                end
            end

            return var
        end
        rawset(cls, '__index', __newindex_with_set_value)
    end
    return __get
end

---为类cls初始化属性访问器__set表
---@generic T:ClassType
---@param cls T
---@param value_cls boolean
---@return table
function Class.init_set(cls, value_cls)
    local value_cls = value_cls or false
    local __set = {}
    rawset(cls, '__set', __set)
    if not value_cls then
        rawset(cls, '__newindex', __newindex_with_set)
    else
        local __newindex_with_set_value = function(t, k, v)
            if rawget(cls, k) ~= nil then
                rawset(t, k, v)
                return
            end

            local var = rawget(__set, k)
            if var ~= nil then
                var(t, v)
                return
            end

            rawset(t, k, v)
        end
        rawset(cls, '__newindex', __newindex_with_set_value)
    end
    return __set
end

---创建类: 指定类名，类的初始化列表，并指定要继承的基类
---@param t table|nil @ 要创建的类的初始化表
---@param baseClass table|nil @ 基类
function Class.inheritsFrom(cls_name, t, baseClass)
    -- set cls index
    local new_class = t or {}
    new_class.__cls_name = cls_name

    -- declare new function
    function new_class.new(...)
        local newinst = {}
        setmetatable(newinst, new_class)

        if newinst.__ctor then
            newinst:__ctor(...)
        end

        return newinst
    end

    -- Implementation of additional OO properties starts here --
    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    function new_class:superClass()
        return baseClass
    end

    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    new_class.__index = __index
    setmetatable(new_class, baseClass or {})

    if new_class.__cls_ctor then
        new_class.__cls_ctor(new_class)
    end

    new_class.__newindex = __newindex
    return new_class
end

---@generic T, K: ClassType
---@param data T
---@param clazz K
---@return boolean
function Class.isa(data, clazz)
    local clazz_type = type(clazz)
    local data_type = type(data)
    if clazz_type == 'table' then
        if data_type == 'table' and
                data.isa and
                data.isa(clazz) then
            return true
        end
    else
        return clazz_type == data_type
    end

    return false
end

---属性访问函数：支持通过第三个参数传递对象指针
---@param t table @ 属性访问链中的表，可能是对象指针，也可能是类
---@param k any @ 键值
---@param o table @ 属性访问链中的第一个表，即对象指针
__index = function (t, k, o)
    local h, mt
    o = o or t
    while t do
        if type(t) == "table" then
            if not rawequal(t, o) then
                local v = rawget(t, k)
                if v ~= nil then return v end
            end

            mt = getmetatable(t)
            h = mt.__index
            if h == nil then return nil end
        else
            mt = getmetatable(t)
            h = mt.__index
            if h == nil then
                error("metatable must has a __index")
            end
        end
        if type(h) == "function" then
            return (h(mt, k, o or t))     -- call the handler
        else
            t = h
        end
    end
end

---属性访问函数：支持通过第三个参数传递对象指针，同时支持属性重载
---@param t table @ 属性访问链中的表，可能是对象指针，也可能是类
---@param k any @ 键
---@param v any @ 值
---@param o table @ 属性访问链中的第一个表，即对象指针
__newindex = function(t, k, v, o)
    local h, mt
    o = o or t
    while t do
        if type(t) == 'table' then
            mt = getmetatable(t)
            h = mt.__newindex
            if h == nil then return false end
        else
            mt = getmetatable(t)
            h = mt.__newindex
            if h == nil then
                error("metatable must has a __newindex")
            end
        end

        if type(h) == "function" then
            local rt = h(mt, k, v, o or t)
            if not rt then           -- call the handler
                if rawequal(t, o) then
                    rawset(o, k, v); return
                end
            end
            return rt
        else
            t = h
        end
    end
end

---属性访问函数：支持通过第三个参数传递对象指针，同时支持属性重载
---@param t table @ 属性访问链中的表，可能是对象指针，也可能是类
---@param k any @ 键值
---@param o table @ 属性访问链中的第一个表，即对象指针
__index_with_get = function(t, k, o)
    local h, mt
    o = o or t
    while t do
        if type(t) == "table" then
            local __get = rawget(t, '__get')
            if __get ~= nil then
                local v = rawget(__get, k)
                if v ~= nil then return (v(o or t)) end
            end

            if not rawequal(t, o) then
                local v = rawget(t, k)
                if v ~= nil then return v end
            end

            mt = getmetatable(t)
            h = mt.__index
            if h == nil then return nil end
        else
            mt = getmetatable(t)
            h = mt.__index
            if h == nil then
                error("metatable must has a __index")
            end
        end

        if type(h) == "function" then
            return (h(mt, k, o or t))     -- call the handler
        else
            t = h
        end
    end
end

---属性访问函数：支持通过第三个参数传递对象指针，同时支持属性重载
---@param t table @ 属性访问链中的表，可能是对象指针，也可能是类
---@param k any @ 键
---@param v any @ 值
---@param o table @ 属性访问链中的第一个表，即对象指针
__newindex_with_set = function(t, k, v, o)
    local h, mt
    o = o or t
    while t do
        if type(t) == 'table' then
            local __set = rawget(t, '__set')
            if __set ~= nil then
                local sv = rawget(__set, k)
                if sv ~= nil then sv(o, v); return true end
            end

            mt = getmetatable(t)
            h = mt.__newindex
            if h == nil then return false end
        else
            mt = getmetatable(t)
            h = mt.__newindex
            if h == nil then
                error("metatable must has a __newindex")
            end
        end

        if type(h) == "function" then
            local rt = h(mt, k, v, o or t)
            if not rt then           -- call the handler
                if rawequal(t, o) then
                    rawset(o, k, v); return
                end
            end
            return rt
        else
            t = h
        end
    end
end

return Class