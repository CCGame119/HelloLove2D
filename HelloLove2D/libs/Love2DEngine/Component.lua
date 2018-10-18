--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 14:05
--

local Class = require('libs.Class')

local Object = Love2DEngine.Object

---@class Love2DEngine.Component:Love2DEngine.Object
local Component = Class.inheritsFrom('Component', nil, Object)

--TODO: Love2DEngine.Component

Love2DEngine.Component = Component
return Component