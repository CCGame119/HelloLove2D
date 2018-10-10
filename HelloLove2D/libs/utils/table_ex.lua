--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/20 15:05
--

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

--- 打印lua table 内容
---@param table table  @lua table
---@param level number @缩进等级
function printT(t, lv)
    print(table.tostr(t, lv))
end