--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:37
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local IColorGear = FairyGUI.IColorGear


---@class FairyGUI.GGraph:FairyGUI.GObject @implement IColorGear
local GGraph = Class.inheritsFrom('GGraph', nil, GObject {IColorGear})

--TODO: FairyGUI.GGraph

FairyGUI.GGraph = GGraph
return GGraph