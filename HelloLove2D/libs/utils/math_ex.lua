--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 17:10
--

--- clamp val between min and max
---@param val number
---@param min number
---@param max number
function math.clamp(val, min, max)
    return math.max(min, math.min(val, max))
end