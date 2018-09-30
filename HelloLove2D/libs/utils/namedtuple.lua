--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/20 14:46
--
require('libs.utils.table_ex')

---@class namedtuple
local namedtuple = {}

---模拟python namedtuple, 返回类似namedtuple的一个table
---@param dict_data table @ 数据表
---@param dict_name table @ 字段名称表
---@return dict_data table @ 数据表: mt = o
function namedtuple.bind(dict_data, dict_name)
    local __item_mt = {
        __dict_name = dict_name,
        __index = function(t, key)
            local idx = dict_name[key]
            if nil ~= idx then
                local val = rawget(t, idx+1)
                return val
            end
        end,
        __tostring = function(e)
            local ret_str = "{\n"
            for k, i in pairs(dict_name) do
                local val = e[i+1]
                local val_str = tostring(val)
                if type(val) == 'table' then
                    val_str = table.tostr2(val)
                end
                ret_str = ret_str .. string.format("\t['%s'] = %s,\n", k, val_str)
            end
            ret_str = ret_str .. "}"
            return ret_str
        end
    }

    for _, item in pairs(dict_data) do
        setmetatable(item, __item_mt)
    end

    return  dict_data
end

return namedtuple