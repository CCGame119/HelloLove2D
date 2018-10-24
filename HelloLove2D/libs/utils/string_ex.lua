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