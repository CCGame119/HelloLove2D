--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 15:02
--

local Class = require('libs.Class')

---@class Love2DEngine.Color32:ClassType
---@field private rgba number
---@field public r number
---@field public g number
---@field public b number
---@field public a number
local Color32 = Class.inheritsFrom('Color32')

---@param r number
---@param g number
---@param b number
---@param a number
function Color32:__ctor(r, g, b, a)
    self.rgba = 0
    self.r, self.g, self.b, self.a = r or 1, g or 1, b or 1, a or 1
end

---@param c Love2DEngine.Color
---@return Love2DEngine.Color32
function Color32.FromColor(c)
    return Color32.new(math.clamp01(c.r) * 255, math.clamp01(c.g) * 255, math.clamp01(c.b) * 255, math.clamp01(c.a) * 255)
end

local __get = Class.init_get(Color32, true)
local __set = Class.init_set(Color32, true)

Color32.__call = function(t, r, g, b, a)
    return Color32.new(r, g, b, a)
end

Love2DEngine.Color32 = Color32
setmetatable(Color32, Color32)
return Color32