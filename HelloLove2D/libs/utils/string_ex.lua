--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/20 15:05
--

---@param str string
---@param ch char
function string.split(str, ch)
    local words = {}
    local pattern = string.format('([^%s]+)%s?', ch, ch)
    for w in string.gmatch(str, pattern) do
        table.insert(words, w)
        print(w)
    end
    return words
end

---@param substr string
function string.endWith(str, substr)
    local len = string.len(str)
    local lenSub = string.len(substr)
    if lenSub > len then
        return false
    end
    return string.sub(str, len - lenSub + 1) == substr
end

local whitespace = {[0x9]=1, [0xA]=1, [0xB]=1, [0xC]=1, [0xD]=1, [0x20]=1, [0x85]=1, [0xA0]=1, [0x1680]=1, [0x2000]=1, [0x2001]=1}
---@param ch char
function string.isWhiteSpace(ch)
    local ret = whitespace[string.char(ch)]
    return ret == 1
end