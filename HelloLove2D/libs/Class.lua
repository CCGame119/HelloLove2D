--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 14:09
--
local metatable = getmetatable

---@class ClassType @ 类类型
---@field public __cls_name string @ 类名称
ClassType = {}
function ClassType.new(...) end
function ClassType.__cls_ctor(cls) end
function ClassType:__ctor(...) end
function ClassType:class(...) end
function ClassType:superClass(...) end
function ClassType:isa(...) end

---@class Class @ Lua 类模拟辅助类
local Class = {}
local __index = nil
local __index_with_get = nil

function Class.init_get(cls)
    local __get = {}
    rawset(cls, '__get', __get)
    rawset(cls, '__index', __index_with_get)
    return __get
end

---@param t table|nil @ 要创建的类的初始化表
---@param baseClass table|nil @ 基类
function Class.inheritsFrom(cls_name, t, baseClass)
    -- set cls index
    local new_class = t or {}
    new_class.__cls_name = cls_name
    new_class.__index = __index
    setmetatable(new_class, baseClass or {})
    if baseClass then
        local base_index = rawget(baseClass, '__index')
        if base_index then
            rawset(new_class, '__index', base_index)
        end
    end

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

    if new_class.__cls_ctor then
        new_class.__cls_ctor(new_class)
    end

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
---@param table table @ 属性访问链中的表，可能是对象指针，也可能是类
---@param key any @ 键值
---@param obj table @ 属性访问链中的第一个表，即对象指针
__index = function (table, key, obj)
    local h, mt
    obj = obj or table
    while table do
        if type(table) == "table" then
            if table ~= obj then
                local v = rawget(table, key)
                if v ~= nil then return v end
            end

            mt = metatable(table)
            h = mt.__index
            if h == nil then return nil end
        else
            mt = metatable(table)
            h = mt.__index
            if h == nil then
                error("metatable must has a __index")
            end
        end
        if type(h) == "function" then
            return (h(mt, key, obj or table))     -- call the handler
        else
            table = mt
        end
    end
end

---属性访问函数：支持通过第三个参数传递对象指针，同时支持属性重载
---@param table table @ 属性访问链中的表，可能是对象指针，也可能是类
---@param key any @ 键值
---@param obj table @ 属性访问链中的第一个表，即对象指针
__index_with_get = function(table, key, obj)
    local h, mt

    obj = obj or table
    while table do
        if type(table) == "table" then
            local __get = rawget(table, '__get')
            if __get ~= nil then
                local v = rawget(__get, key)
                if v ~= nil then return (v(obj or table)) end
            end

            if table ~= obj then
                local v = rawget(table, key)
                if v ~= nil then return v end
            end

            mt = metatable(table)
            h = mt.__index
            if h == nil then return nil end
        else
            mt = metatable(table)
            h = mt.__index
            if h == nil then
                error("metatable must has a __index")
            end
        end

        if type(h) == "function" then
            return (h(mt, key, obj or table))     -- call the handler
        else
            table = mt
        end
    end
end

return Class