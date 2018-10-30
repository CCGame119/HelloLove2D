--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 19:05
--

local Class = require('libs.Class')

---@class Love2DEngine.Color:ClassType
---@field public r number
---@field public g number
---@field public b number
---@field public a number
---@field public white Love2DEngine.Color
---@field public clear Love2DEngine.Color
---@field public black Love2DEngine.Color
local Color = Class.inheritsFrom('Color')

---@field r number
---@field g number
---@field b number
---@field a number
function Color:__ctor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a or 1
end

function Color:Clone()
    return Color.new(self.r, self.g, self.b, self.a)
end

--TODO: Love2DEngine.Color

local __get = Class.init_get(Color, true)
local __set = Class.init_set(Color, true)

__get.white = function(self) return Color.new(1,1,1,1) end
__get.clear = function(self) return Color.new(0,0,0,0) end
__get.black = function(self) return Color.new(0,0,0,1) end

Love2DEngine.Color = Color
setmetatable(Color, Color)
return Color