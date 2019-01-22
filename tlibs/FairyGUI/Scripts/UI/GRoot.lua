--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:23
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent

---@type FairyGUI.GRoot
local GRoot = Class.inheritsFrom('GRoot', nil, GComponent)

FairyGUI.GRoot = GRoot
setmetatable(GRoot, GRoot)
return GRoot