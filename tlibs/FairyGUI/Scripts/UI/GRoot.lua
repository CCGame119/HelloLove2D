--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:23
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent

---@class FairyGUI.GRoot:FairyGUI.GComponent
local GRoot = Class.inheritsFrom('GRoot', nil, GComponent)

--TODO: FairyGUI.GRoot

FairyGUI.GRoot = GRoot
return GRoot