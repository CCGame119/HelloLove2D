--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 18:54
--

local Class = require('libs.Class')

---@class Love2DEngine.RaycastHit:ClassType
local RaycastHit = Class.inheritsFrom('RaycastHit')

--TODO: Love2DEngine.RaycastHit
local __get = Class.init_get(RaycastHit, true)
local __set = Class.init_set(RaycastHit, true)

Love2DEngine.RaycastHit = RaycastHit
return RaycastHit