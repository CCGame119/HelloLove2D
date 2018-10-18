--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 18:54
--

local Class = require('libs.Class')

local Vector3 = Love2DEngine.Vector3
local Vector2 = Love2DEngine.Vector2
local Collider = Love2DEngine.Collider

---@class Love2DEngine.RaycastHit:ClassType
---@field public collider Love2DEngine.Collider
---@field public textureCoord Love2DEngine.Vector2
---@field private _Point Love2DEngine.Vector3
---@field private _Normal Love2DEngine.Vector3
---@field private _FaceID number
---@field private _Distance number
---@field private _UV Love2DEngine.Vector2
---@field private _Collider Love2DEngine.Collider
local RaycastHit = Class.inheritsFrom('RaycastHit')

function RaycastHit:__ctor()
    self:Reset()
end

function RaycastHit:Reset()
    self._Point = Vector3()
    self._Normal = Vector3()
    self._FaceID = 0
    self._Distance = 0
    self._UV = Vector2()
    self._Collider = nil
end

---@param raycastHit Love2DEngine.RaycastHit
function RaycastHit:Assign(raycastHit)
    self._Point:Assign(raycastHit._Point)
    self._Normal:Assign(raycastHit._Normal)
    self._FaceID = raycastHit._FaceID
    self._Distance = raycastHit._Distance
    self._UV:Assign(raycastHit._UV)
    self._Collider = raycastHit._Collider
end

--TODO: Love2DEngine.RaycastHit
local __get = Class.init_get(RaycastHit, true)
local __set = Class.init_set(RaycastHit, true)

__get.point = function(self) return self._Point end
__set.point = function(self, val) self._Point = val end

__get.normal = function(self) return self._Normal end
__set.normal = function(self, val) self._Normal = val end

__get.barycentricCoordinate = function(self) return Vector3((1 - (self._UV.y + self._UV.x)), self._UV.x, self._UV.y) end
__set.barycentricCoordinate = function(self, val) self._UV = val end

__get.distance = function(self) return self._Distance end
__set.distance = function(self, val) self._Distance = val end

__get.triangleIndex = function(self) return self._FaceID end

__get.textureCoord = function(self)
    local output = Vector2()
    RaycastHit.CalculateRaycastTexCoord(output, self.collider, self._UV, self._Point, self._FaceID, 0)
    return output
end

__get.textureCoord2 = function(self)
    local output = Vector2()
    RaycastHit.CalculateRaycastTexCoord(output, self.collider, self._UV, self._Point, self._FaceID, 1)
    return output
end

__get.collider = function(self) return self._Collider end

RaycastHit.__call = function(t)
    return RaycastHit.new()
end

Love2DEngine.RaycastHit = RaycastHit
setmetatable(RaycastHit, RaycastHit)
return RaycastHit