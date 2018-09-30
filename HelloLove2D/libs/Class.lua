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
function ClassType.__ctor(...) end

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
---@param base table|nil @ 基类
function Class.class(cls_name, t, base)
    -- set cls index
    local cls = t or {}
    cls.__index = __index
    cls.__cls_name = cls
    setmetatable(cls, base or {})
    if base then
        local base_index = rawget(base, '__index')
        if base_index then
            rawset(cls, '__index', base_index)
        end
    end

    -- declare new function
    function cls.new(...)
        local obj = {}
        setmetatable(obj, cls)
        if obj.__ctor then
            obj:__ctor(...)
        end
        return obj
    end

    if cls.__cls_ctor then
        cls.__cls_ctor(cls)
    end

    return cls
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