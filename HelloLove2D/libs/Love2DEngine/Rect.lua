--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 15:20
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2
local getmetatable = getmetatable
local setmetatable = setmetatable

--region 类定义
---@class Love2DEngine.Rect:ClassType
---@field public x number
---@field public y number
---@field public width number
---@field public height number
---@field public size Love2DEngine.Vector2
---@field public center Love2DEngine.Vector2
---@field public min Love2DEngine.Vector2
---@field public max Love2DEngine.Vector2
---@field public xMin number
---@field public yMin number
---@field public xMax number
---@field public yMax number
---@field public zero Love2DEngine.Rect
---@field private _XMin number
---@field private _YMin number
---@field private _Width number
---@field private _Height number
local Rect = Class.inheritsFrom('Rect')

--endregion

--region 成员函数
---@param x_pos_src number|Love2DEngine.Vector2|Love2DEngine.Rect
---@param y_size number|Love2DEngine.Vector2
---@param w number
---@param h number
function Rect:__ctor(x_pos_src, y_size, w, h)
    if type(x_pos_src) == 'number' then
        self._XMin, self._YMin, self._Width, self._Height = x_pos_src, y_size, w, h
        return
    end

    if Class.isa(x_pos_src, Vector2) then
        self._XMin, self._YMin, self._Width, self._Height = x_pos_src.x, x_pos_src.y, y_size.x, y_size.y
        return
    end

    if Class.isa(x_pos_src, Rect) then
        local source = x_pos_src
        self._XMin, self._YMin, self._Width, self._Height = x_pos_src.x, x_pos_src.y, x_pos_src.width, x_pos_src.height
        return
    end
end

function Rect.Zero()
    return Rect(0, 0, 0, 0)
end

---@param point Love2DEngine.Vector2
---@return boolean
function Rect:Contains(point)
    return point.x >= self.xMin and point.x < self.xMax and
            point.y >= self.yMin and point.y < self.yMax
end

---@param x number
---@param y number
---@param w number
---@param h number
function Rect:Set(x, y, w, h)
    self._XMin, self._YMin, self._Width, self._Height = x, y, w, h
end

---@return Love2DEngine.Rect
function Rect:Clone()
    return Rect.new(self)
end

--endregion

--region 属性
local __get = Class.init_get(Rect, true)
local __set = Class.init_set(Rect, true)

__get.zero = Rect.Zero

__get.x = function(self) return self._XMin end
__set.x = function(self, val) self._XMin = val end

__get.y = function(self) return self._YMin end
__set.y = function(self, val) self._YMin = val end

__get.position = function(self) return Vector2(self._XMin, self._YMin) end
__set.position = function(self, val) self._XMin, self._YMin = val.x, val.y end

__get.center = function(self) return Vector2(self.x + self._Width / 2, self.y + self._Height / 2) end
__set.center = function(self, val) self._XMin, self._YMin = val.x - self._Width / 2, val.y - self._Height / 2 end

__get.min = function(self) return Vector2(self.xMin, self.yMin) end
__set.min = function(self, val) self.xMin, self.yMin = val.x, val.y end

__get.max = function(self) return Vector2(self.xMax, self.yMax) end
__set.max = function(self, val) self.xMax, self.yMax = val.x, val.y end

__get.width = function(self) return self._Width end
__set.width = function(self, val) self._Width = val end

__get.height = function(self) return self._Height end
__set.height = function(self, val) self._Height = val end

__get.size = function(self) return Vector2(self._Width, self._Height) end
__set.size = function(self, val) self._Width, self._Height = val.x, val.y end

__get.xMin = function(self) return self._XMin end
__set.xMin = function(self, val) local xMax = self.xMax; self._XMin, self._Width = val, xMax - val end

__get.yMin = function(self) return self._YMin end
__set.yMin = function(self, val) local yMax = self.xMax; self._YMin, self._Height = val, yMax - val end

__get.xMax = function(self) return self._Width + self._XMin end
__set.xMax = function(self, val) self._Width = val - self._XMin end

__get.yMax = function(self) return self._Height + self._YMin end
__set.yMax = function(self, val) self._Height = val - self._YMin end

---@deprecated use xMin
__get.left = function(self) return self._XMin end
---@deprecated use xMax
__get.right = function(self) return self._XMin + self._Width end
---@deprecated use yMin
__get.top = function(self) return self._YMin end
---@deprecated use yMax
__get.bottom = function(self) return self._YMin + self._Height end

--endregion

--region metatable method
Rect.__call = function(t, x, y, w, h)
    return Rect.new(x, y, w, h)
end

Rect.__tostring = function(a)
    return string.format("(%f, %f, %f, %f)", a.x, a.y, a.width, a.height)
end

Rect.__div = function(a, d)
    return Rect.new(a.x / d, a.y / d, a.width / d, a.height / d)
end

Rect.__mul = function(a, m)
    return Rect.new(a.x * m, a.y * m, a.width * m, a.height * m)
end

Rect.__add = function(a, b)
    return Rect.new(a.x + b.x, a.y + b.y, a.width + b.width, a.height + b.height)
end

Rect.__sub = function(a, b)
    return Rect.new(a.x - b.x, a.y - b.y, a.width - b.width, a.height - b.height)
end

Rect.__unm = function(a)
    return Rect.new(-a.x, -a.y, -a.width, -a.height)
end

Rect.__eq = function(a, b)
    return a.position == b.position and a.size == b.size
end
--endregion

Love2DEngine.Rect = Rect
setmetatable(Rect, Rect)
return Rect