--------------------------------------------------------------------------------
--      Copyright (c) 2015 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
local Class = require('libs.Class')

local clamp	= math.clamp
local sqrt	= math.sqrt
local min	= math.min
local max 	= math.max
local setmetatable = setmetatable
local rawget = rawget

---@class Love2DEngine.Vector4:ClassType
---@field public x number
---@field public y number
---@field public z number
---@field public w number
---@field public zero Love2DEngine.Vector4
---@field public one Love2DEngine.Vector4
---@field public magnitude number
---@field public normalized Love2DEngine.Vector4
---@field public sqrMagnitude number
local Vector4 = Class.inheritsFrom('Vector4')
local get = Class.init_get(Vector4, true)
local set = Class.init_set(Vector4, true)

---@param self Love2DEngine.Vector4
---@param idx number
get.__indexer = function(self, idx)
    if idx == 0 then
        return self.x
    elseif idx == 1 then
        return self.y
    elseif idx == 2 then
        return self.z
    elseif idx == 3 then
        return self.w
    else
        error("Index out of bounds: " .. idx)
    end
end

---@param self Love2DEngine.Vector4
---@param idx number
---@param value number
set.__indexer = function(self, idx, value)
    if idx == 0 then
        self.x = value
    elseif idx == 1 then
        self.y = value
    elseif idx == 2 then
        self.z = value
    elseif idx == 3 then
        self.w = value
    else
        error("Index out of bounds: " .. idx)
    end
end

function Vector4:__ctor(x, y, z, w)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.w = w or 0
end

Vector4.__call = function(t, x, y, z, w)
	return setmetatable({x = x or 0, y = y or 0, z = z or 0, w = w or 0}, Vector4)		
end

function Vector4.New(x, y, z, w)	
	return setmetatable({x = x or 0, y = y or 0, z = z or 0, w = w or 0}, Vector4)		
end

function Vector4:Set(x,y,z,w)
	self.x = x or 0
	self.y = y or 0	
	self.z = z or 0
	self.w = w or 0
end

function Vector4:Get()
	return self.x, self.y, self.z, self.w
end

function Vector4.Lerp(from, to, t)    
    t = clamp(t, 0, 1)
    return Vector4.New(from.x + ((to.x - from.x) * t), from.y + ((to.y - from.y) * t), from.z + ((to.z - from.z) * t), from.w + ((to.w - from.w) * t))
end    

function Vector4.MoveTowards(current, target, maxDistanceDelta)    
	local vector = target - current
	local magnitude = vector:Magnitude()	
	
	if magnitude > maxDistanceDelta and magnitude ~= 0 then     
		maxDistanceDelta = maxDistanceDelta / magnitude
		vector:Mul(maxDistanceDelta)   
		vector:Add(current)
		return vector
	end
	
	return target
end    

function Vector4.Scale(a, b)    
    return Vector4.New(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w)
end    

function Vector4:SetScale(scale)
	self.x = self.x * scale.x
	self.y = self.y * scale.y
	self.z = self.z * scale.z
	self.w = self.w * scale.w
end

function Vector4:Normalize()
	local v = Vector4.New(self.x, self.y, self.z, self.w)
	return v:SetNormalize()
end

function Vector4:SetNormalize()
	local num = self:Magnitude()	
	
	if num == 1 then
		return self
    elseif num > 1e-05 then    
        self:Div(num)
    else    
        self:Set(0,0,0,0)
	end 

	return self
end

function Vector4:Div(d)
	self.x = self.x / d
	self.y = self.y / d	
	self.z = self.z / d
	self.w = self.w / d
	
	return self
end

function Vector4:Mul(d)
	self.x = self.x * d
	self.y = self.y * d
	self.z = self.z * d
	self.w = self.w * d	
	
	return self
end

function Vector4:Add(b)
	self.x = self.x + b.x
	self.y = self.y + b.y
	self.z = self.z + b.z
	self.w = self.w + b.w
	
	return self
end

function Vector4:Sub(b)
	self.x = self.x - b.x
	self.y = self.y - b.y
	self.z = self.z - b.z
	self.w = self.w - b.w
	
	return self
end

function Vector4.Dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

function Vector4.Project(a, b)
	local s = Vector4.Dot(a, b) / Vector4.Dot(b, b)
	return b * s
end

function Vector4.Distance(a, b)
	local v = a - b
	return Vector4.Magnitude(v)
end

function Vector4.Magnitude(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)
end

function Vector4.SqrMagnitude(a)
	return a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w
end

function Vector4.Min(lhs, rhs)
	return Vector4.New(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z), max(lhs.w, rhs.w))
end

function Vector4.Max(lhs, rhs)
	return Vector4.New(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z), min(lhs.w, rhs.w))
end

Vector4.__tostring = function(self)
	return string.format("Vector4: (%f,%f,%f,%f)", self.x, self.y, self.z, self.w)
end

Vector4.__div = function(va, d)
	return Vector4.New(va.x / d, va.y / d, va.z / d, va.w / d)
end

Vector4.__mul = function(va, d)
	return Vector4.New(va.x * d, va.y * d, va.z * d, va.w * d)
end

Vector4.__add = function(va, vb)
	return Vector4.New(va.x + vb.x, va.y + vb.y, va.z + vb.z, va.w + vb.w)
end

Vector4.__sub = function(va, vb)
	return Vector4.New(va.x - vb.x, va.y - vb.y, va.z - vb.z, va.w - vb.w)
end

Vector4.__unm = function(va)
	return Vector4.New(-va.x, -va.y, -va.z, -va.w)
end

Vector4.__eq = function(va,vb)
	local v = va - vb
	local delta = Vector4.SqrMagnitude(v)	
	return delta < 1e-10
end

get.zero = function() return Vector4.New(0, 0, 0, 0) end
get.one	 = function() return Vector4.New(1, 1, 1, 1) end

get.magnitude 	 = Vector4.Magnitude
get.normalized 	 = Vector4.Normalize
get.sqrMagnitude = Vector4.SqrMagnitude

Love2DEngine.Vector4 = Vector4
setmetatable(Vector4, Vector4)
return Vector4