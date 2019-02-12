--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/20 15:05
--

---@param str string
---@param ch char
---@return string[]
function string.split(str, ch)
    local words = {}
    local pattern = string.format('([^%s]+)%s?', ch, ch)
    for w in string.gmatch(str, pattern) do
        table.insert(words, w)
    end
    return words
end

---@param substr string
---@return boolean
function string.endWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

---@param str string
---@param starting string
---@return boolean
function string.startsWith(str, starting)
    return starting == "" or str:sub(1, #starting) == starting
end

local whitespace = {[0x9]=1, [0xA]=1, [0xB]=1, [0xC]=1, [0xD]=1, [0x20]=1, [0x85]=1, [0xA0]=1, [0x1680]=1, [0x2000]=1, [0x2001]=1}
---@param ch char
---@return boolean
function string.isSpace(ch)
    local ret = whitespace[string.byte(ch)]
    return ret == 1
end

---@param str string
---@return string
function string.trimEnd(str)
    return (str:gsub("(.-)%s*$", "%1"))
end

---@param str string
---@return string
function string.trimBeg(str)
    return (str:gsub("^%s*(.-)", "%1"))
end

---@param str string
function string.isNullOrEmpty(str)
    if str == nil or str == '' then
        return  true
    end
    return false
end

function string.isHighSurrogate(ch)
    -- TODO: string.isHighSurrogate(ch)
    return false
end

---@param s string
---@param subStr string
---@param init string
---@return number, number, string
function string.indexOf(s, subStr, init)
    local begPos = string.find(s, subStr, init, true)
    begPos = begPos or -1
    return begPos
end

---@param s string @ref
---@param sub string
---@return string
function string.Append(s, substr)
    s = s .. substr
    return s
end

string.empty = ''

---扩展string
local mt = getmetatable('')

--[[
-- demo
a='abcdef'
return a[4]      --> d
]]
mt.__index = function(str,i)
    if type(i) == 'number' then
        return string.sub(str,i,i)
    else
        return string[i]
    end
end



--[[
-- demo
a='abcdef'
return a(3,5)    --> cde
return a(4)      --> def -- equivalent to a(4,-1)
]]
mt.__call = string.sub

--[[
'\t',
'\n',
'\v',
'\f',
'\r',
' ',
'\x0085',
' ',
' ',
' ',
' ',
' ',
' ',
' ',
' ',
' ',
' ',
' ',
' ',
' ',
'\x200B',
'\x2028',
'\x2029',
'　',
'\xFEFF'
]]