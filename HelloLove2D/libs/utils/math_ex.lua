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

--- clamp val between 0 and 1
---@param val number
function math.clamp01(val)
    return math.clamp(val, 0, 1)
end

--- return then sign of val
---@param val number
---@return number
function math.sign(val)
    if val > 0 then return 1
    elseif val < 0 then return -1
    else return 0 end
end

---@param f0 number
---@param f1 number
function math.Approximately(f0, f1)
    return abs(f0 - f1) < 1e-6
end

---@param a number
---@param b number
---@param t number
function math.lerp(a, b, t)
    return a + (b - a) * math.clamp01(t)
end

---@param val number
function math.round(val)
    return math.floor(val + 0.5)
end

math.Deg2Rad = 0.01745329
math.Rad2Deg = 57.29578

math.inf = math.huge
math.nan = 0/0

math.fmaxval = 3.402823E+38
math.fminval = -3.402823E+38
