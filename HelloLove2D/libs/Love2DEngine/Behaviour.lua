--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 14:03
--

local Class = require('libs.Class')

local Component = Love2DEngine.Component

---@class Love2DEngine.Behaviour:Love2DEngine.Component
local Behaviour = Class.inheritsFrom('Behaviour',  nil, Component)

--TODO: Love2DEngine.Behaviour

Love2DEngine.Behaviour = Behaviour
return Behaviour