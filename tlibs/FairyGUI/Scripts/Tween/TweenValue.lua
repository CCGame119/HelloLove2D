--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 14:36
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2
local Vector3 = Love2DEngine.Vector3
local Vector4 = Love2DEngine.Vector4
local Color = Love2DEngine.Color

---@class FairyGUI.TweenValue:ClassType
---@field public x number
---@field public y number
---@field public z number
---@field public w number
---@field public d number
---@field public vec2 Love2DEngine.Vector2
---@field public vec3 Love2DEngine.Vector3
---@field public vec4 Love2DEngine.Vector4
---@field public color Love2DEngine.Color
local TweenValue = Class.inheritsFrom('TweenValue')

function TweenValue:__ctor()
    self:SetZero()
end

function TweenValue:SetZero()
    self.x, self.y, self.z, self.w = 0
    self.d = 0
end

local __get = Class.init_get(TweenValue, true, true)
local __set = Class.init_set(TweenValue, true, true)

---@param self FairyGUI.TweenValue
__get.vec2 = function(self) return Vector2(self.x, self.y) end

---@param self FairyGUI.TweenValue
---@param val Love2DEngine.Vector2
__set.vec2 = function(self, val)
    self.x, self.y = val.x, val.y
end

---@param self FairyGUI.TweenValue
__get.vec3 = function(self) return Vector3(self.x, self.y, self.z) end

---@param self FairyGUI.TweenValue
---@param val Love2DEngine.Vector3
__set.vec3 = function(self, val)
    self.x, self.y, self.z = val.x, val.y, val.z
end

---@param self FairyGUI.TweenValue
__get.vec4 = function(self) return Vector4(self.x, self.y, self.z, self.w) end

---@param self FairyGUI.TweenValue
---@param val Love2DEngine.Vector4
__set.vec4 = function(self, val)
    self.x, self.y, self.z, self.w = val.x, val.y, val.z, val.w
end

---@param self FairyGUI.TweenValue
__get.color = function(self) return Color(self.x, self.y, self.z, self.w) end

---@param self FairyGUI.TweenValue
---@param val Love2DEngine.Color
__set.color = function(self, val)
    self.x, self.y, self.z, self.w = val.x, val.y, val.z, val.w
end


---@param self FairyGUI.TweenValue
---@param idx number
__get.__indexer = function(self, idx)
    if idx == 1 then
        return self.x
    elseif idx == 2 then
        return self.y
    elseif idx == 3 then
        return self.z
    elseif idx == 4 then
        return self.w
    else
        error("Index out of bounds: " .. idx)
    end
end

---@param self FairyGUI.TweenValue
---@param idx number
---@param value number
__set.__indexer = function(self, idx, value)
    if idx == 1 then
        self.x = value
    elseif idx == 2 then
        self.y = value
    elseif idx == 3 then
        self.z = value
    elseif idx == 4 then
        self.w = value
    else
        error("Index out of bounds: " .. idx)
    end
end


FairyGUI.TweenValue = TweenValue
return TweenValue