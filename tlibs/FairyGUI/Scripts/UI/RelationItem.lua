--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:48
--

local Class = require('libs.Class')

---@class FairyGUI.RelationDef:ClassType
local RelationDef = Class.inheritsFrom('RelationDef')

---@class FairyGUI.RelationItem:ClassType
local RelationItem = Class.inheritsFrom('RelationItem')

--TODO: FairyGUI.RelationItem

FairyGUI.RelationDef = RelationDef
FairyGUI.RelationItem = RelationItem
return RelationItem