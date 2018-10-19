--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 14:05
--

local Class = require('libs.Class')

local Object = Love2DEngine.Object

---@class Love2DEngine.Component:Love2DEngine.Object
---@field public gameObject Love2DEngine.GameObject
---@field public transform Love2DEngine.Transform
---@field private _gameObject Love2DEngine.GameObject
local Component = Class.inheritsFrom('Component', nil, Object)

---@generic T:Love2DEngine.Component
---@param t T
---@return T
function Component:GetComponent(t)
    return self._gameObject:GetComponent(t)
end

--TODO: Love2DEngine.Component
---Component is a weak value table
Component.__mode = 'v'

local __get = Class.init_get(Component)
local __set = Class.init_set(Component)

__get.gameObject = function(self) return self._gameObject end
__set.gameObject = function(self, val)
    self._gameObject = val
end

---@param self Love2DEngine.Component
__get.transform = function(self) return self._gameObject.transform end

Love2DEngine.Component = Component
return Component