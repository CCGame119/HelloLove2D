--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 10:13
--
local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2
local Rect = Love2DEngine.Rect
local EventDispatcher = FairyGUI.EventDispatcher

---@type FairyGUI.GObject
local GObject = Class.inheritsFrom('GObject', {
    sourceWidth = 0, sourceHeight = 0,
    initWidth = 0, initHeight = 0,
    minWidth = 0, maxWidth = 0, minHeight = 0, maxHeight = 0,
    _x = 0, _y = 0, _z = 0,
    _pivotX = 0, _pivotY = 0, _pivotAsAnchor = false,
    _rotation = 0, _rotationX = 0, _rotationY = 0,
    _handlingController = false,
    _grayed = false,
    _draggable = false,
    _sortingOrder = 0,
    _focusable = false,
    _tooltips = string.empty,
    _pixelSnapping = false,
    _sizeImplType = 0,
    underConstruct = false,
    _rawWidth = 0, _rawHeight = 0,
    _gearLocked = false,
    _sizePercentInGroup = 0,
    _disposed = false,
}, EventDispatcher)

FairyGUI.GObject = GObject
setmetatable(GObject, GObject)
return GObject