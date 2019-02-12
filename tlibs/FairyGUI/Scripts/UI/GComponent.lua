--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 10:35
--
local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local ChildrenRenderOrder = FairyGUI.ChildrenRenderOrder

---@type FairyGUI.GComponent
local GComponent = Class.inheritsFrom('GComponent', {
    _buildingDisplayList = false,
    _trackBounds = false,
    _boundsChanged = false,
    _apexIndex = 0,
    _childrenRenderOrder = ChildrenRenderOrder.Ascent,
}, GObject)

FairyGUI.GComponent = GComponent
return GComponent