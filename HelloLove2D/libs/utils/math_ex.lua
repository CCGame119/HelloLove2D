--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 17:10
--
local abs = math.abs

--- clamp val between min and max
---@param val number
---@param min number
---@param max number
function math.clamp(val, min, max)
    return math.max(min, math.min(val, max))
end

--- return then sign of val
---@param val number
---@return number
function math.sign(val)
    if val > 0 then return 1
    elseif val < 0 then return -1
    else return 0 end
end

function math.Approximately(f0, f1)
    return abs(f0 - f1) < 1e-6
end

math.Deg2Rad = 0.01745329
math.Rad2Deg = 57.29578