--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/11 13:11
--

local Class = require('libs.Class')

local setmetatable = setmetatable
local tostring = tostring
local format = string.format

---@class Love2DEngine.Ray:ClassType
---@field private _Origin Love2DEngine.Vector3
---@field private _Direction Love2DEngine.Vector3
local Ray = Class.inheritsFrom('Ray')

---@param origin Love2DEngine.Vector3
---@param direction Love2DEngine.Vector3
function Ray:__ctor(origin, direction)
    self._Origin = origin
    self._Direction = direction
end

---@param distance number
function Ray:GetPoint(distance)
    return self._Origin + self._Direction * distance
end

local __get = Class.init_get(Ray, true)
local __set = Class.init_set(Ray, true)

__get.origin = function(self) return self._Origin end
__set.origin = function(self, val) self._Origin = val end

__get.direction = function(self) return self._Direction end
__set.direction = function(self, val) self._Direction = val end

---@param a Love2DEngine.Ray
Ray.__tostring = function(a)
    return format('Origin: %s, Dir: %s', tostring(a._Origin), tostring(a._Direction))
end

Ray.__call = function(t, ori, dir)
    return Ray.new(ori, dir)
end

Love2DEngine.Ray = Ray
setmetatable(Ray, Ray)
return Ray