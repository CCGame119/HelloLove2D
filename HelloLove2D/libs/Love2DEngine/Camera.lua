--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 14:02
--

local Class = require('libs.Class')

local Behaviour = Love2DEngine.Behaviour

---@class Love2DEngine.Camera:Love2DEngine.Behaviour
local Camera = Class.inheritsFrom('Camera', nil , Behaviour)

--TODO: Love2DEngine.Camera

Love2DEngine.Camera = Camera
return Camera