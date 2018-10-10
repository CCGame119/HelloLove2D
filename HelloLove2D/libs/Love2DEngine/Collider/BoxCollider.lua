--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 18:41
--

local Class = require('libs.Class')

local Collider = Love2DEngine.BoxCollider

---@class Love2DEngine.BoxCollider
local BoxCollider = Class.inheritsFrom('BoxCollider', nil, Collider)

--TODO: Love2DEngine.BoxCollider

Love2DEngine.BoxCollider = BoxCollider
return BoxCollider