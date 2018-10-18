--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 15:07
--

local Class = require('libs.Class')

local Component = Love2DEngine.Component

---@class Love2DEngine.MeshFilter:Love2DEngine.Component
---@field sharedMesh Love2DEngine.Mesh
---@field mesh Love2DEngine.Mesh
local MeshFilter = Class.inheritsFrom('MeshFilter', nil, Component)


Love2DEngine.MeshFilter = MeshFilter
return MeshFilter