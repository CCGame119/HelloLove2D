--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/20 15:05
--

---list table copy
---@param source table
---@param dest table
function table.copy_l(source, dest)
    for i, v in ipairs(source) do
        dest[i] = v
    end
end

---list table copy
---@param source table
---@param dest table
function table.copy_l2(source, s_idx, dest, d_idx, count)
    local k = 0
    for i = s_idx, s_idx + count - 1 do
        k = k + 1
       dest[d_idx + k] = source[i]
    end
end

---dict table copy
---@param source table
---@param dest table
function table.copy_d(source, dest)
    for i, v in pairs(source) do
        dest[i] = v
    end
end

---@param source table
---@return table
function table.clone(source)
    local ret = {}
    table.copy_l(source, ret)
    return ret
end

---获取lua table t 的格式化字符串格式
---@param table table  @lua table
---@param level number @缩进等级
function table.tostr(table, level)
    local tmpStr = ""
    local key = ""
    local func = function(table, level) end
    func = function(table, level)
        level = level or 1
        local indent = ""
        for i = 1, level do
            indent = indent.."  "
        end

        if key ~= "" then
            tmpStr = tmpStr .. indent.. tostring(key) .." ".."=".." ".."{\n"
        else
            tmpStr = tmpStr .. indent .. "{\n"
        end

        key = ""
        for k,v in pairs(table) do
            if type(v) == "table" then
                key = k
                func(v, level + 1)
            else
                local formatstring = "%s%s = "
                if type(k) == 'string' then formatstring = "%s%q = " end
                if type(v) == 'string' then
                    formatstring = formatstring.. "%q\n"
                else
                    formatstring = formatstring.. "%s\n"
                end
                local content = string.format(formatstring, indent .. "  ",tostring(k), tostring(v))
                tmpStr = tmpStr .. content
            end
        end
        tmpStr = tmpStr .. indent .. "}\n"
    end
    if type(table) == "table" then
        func(table, level)
    else
        tmpStr = 'nil'
    end
    return tmpStr
end

---获取lua table t 的格式化字符串格式
---@param table table  @lua table
function table.tostr2(table)
    local tmpStr = ""
    local key = ""
    local func = function(table, level)end
    func = function(table)
        if key ~= "" then
            tmpStr = tmpStr ..  tostring(key) .. "=" .. "{"
        else
            tmpStr = tmpStr .. "{"
        end

        key = ""
        for k,v in pairs(table) do
            if type(v) == "table" then
                key = k
                func(v)
            else
                local formatstring = "%s="
                if type(k) == 'string' then formatstring = "%s%q = " end
                if type(v) == 'string' then
                    formatstring = formatstring.. "%q,"
                else
                    formatstring = formatstring.. "%s,"
                end
                local content = string.format(formatstring,  tostring(k), tostring(v))
                tmpStr = tmpStr .. content
            end
        end
        tmpStr = tmpStr .. "}"
    end
    if type(table) == "table" then
        func(table)
    else
        tmpStr = tostring(table)
    end
    return tmpStr
end

---@param t table
---@param e any
function table.indexOf(t, e)
    for i, v in ipairs(t) do
        if v == e then
            return i
        end
    end
    return -1
end

---@param t table
---@param i number @start index
---@param j number @end index, default: #t
function table.removeRange(t, i, j)
    j = j or #t
    for k = j, i, -1 do
        table.remove(t, k)
    end
end

--- 打印lua table 内容
---@param table table  @lua table
---@param level number @缩进等级
function printT(t, lv)
    print(table.tostr(t, lv))
end

