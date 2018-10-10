--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 13:44
--

local Class = require('libs.Class')

---@class FairyGUI.NGraphics:ClassType
---@field public sortingOrder number
---@field public gameObject Love2DEngine.GameObject
---@field public enabled boolean
---@field public vertexMatrix Love2DEngine.Matrix4x4
local NGraphics = Class.inheritsFrom('NGraphics')

--TODO: FairyGUI.NGraphics

FairyGUI.NGraphics = NGraphics
return NGraphics