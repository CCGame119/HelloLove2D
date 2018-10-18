--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 19:43
--

local Class = require('libs.Class')
local Container = FairyGUI.Container

---@class FairyGUI.Stage : FairyGUI.Container
---@field public inst FairyGUI.Stage
---@field public stageHeight number
---@field public stageHeight number
---@field public cachedTransform Love2DEngine.Transform
local Stage = Class.inheritsFrom('Stage', nil, Container)

--TODO: FairyGUI.Stage

FairyGUI.Stage = Stage
return Stage