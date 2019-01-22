--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 17:56
--


local Class = require('libs.Class')

local EventDispatcher = FairyGUI.EventDispatcher

---@type FairyGUI.DisplayObject
local DisplayObject = Class.inheritsFrom('DisplayObject', {
    _renderingOrder = 0,
    _grayed = false,
    _perspective = false,
    _paintingMode = 0, _paintingFlag = 0,
    _cacheAsBitmap = false,
    _requireUpdateMesh = false,
    _ownsGameObject = false,
    _disposed = false,
    _touchDisabled = false,
    _skipInFairyBatching = false,
}, EventDispatcher)

FairyGUI.DisplayObject = DisplayObject
return DisplayObject

