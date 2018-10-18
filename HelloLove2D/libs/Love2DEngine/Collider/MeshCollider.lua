--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/11 10:48
--

local Class = require('libs.Class')

local Collider = Love2DEngine.Collider

---@class Love2DEngine.MeshCollider:Love2DEngine.Collider
local MeshCollider = Class.inheritsFrom('MeshCollider', nil, Collider)

--TODO: Love2DEngine.MeshCollider

Love2DEngine.MeshCollider = MeshCollider
return MeshCollider