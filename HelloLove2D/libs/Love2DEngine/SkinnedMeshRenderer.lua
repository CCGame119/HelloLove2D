--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/22 16:59
--

local Class = require('libs.Class')

local Renderer = Love2DEngine.Renderer

local SkinnedMeshRenderer = Class.inheritsFrom('SkinnedMeshRenderer', nil, Renderer)

--TODO: Love2DEngine.SkinnedMeshRenderer

Love2DEngine.SkinnedMeshRenderer = SkinnedMeshRenderer
return SkinnedMeshRenderer