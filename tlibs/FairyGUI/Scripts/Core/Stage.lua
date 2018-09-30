--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 19:43
--

local Class = require('libs.Class')
local Container = FairyGUI.Container

---@class FairyGUI.Stage : FairyGUI.Container
local Stage = {}
Stage = Class.inheritsFrom('Stage', Stage, Container)

--TODO: Stage

FairyGUI.Stage = Stage
return Stage