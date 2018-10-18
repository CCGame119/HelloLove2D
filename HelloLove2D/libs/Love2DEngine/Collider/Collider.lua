--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 18:44
--

local Class = require('libs.Class')

local Component = Love2DEngine.Component

---@class Love2DEngine.Collider
local Collider = Class.inheritsFrom('Collider', nil, Component)

--TODO: Love2DEngine.Collider

Love2DEngine.Collider = Collider
return Collider