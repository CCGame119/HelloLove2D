--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 10:13
--
local Class = require('libs.Class')
local EventDispatcher = FairyGUI.EventDispatcher
local GComponent = FairyGUI.GComponent

---@class FairyGUI.GObject:FairyGUI.EventDispatcher
---@field public parent FairyGUI.GComponent
local GObject = Class.inheritsFrom('GObject', nil, EventDispatcher)

--TODO: FairyGUI.GObject

FairyGUI.GObject = GObject
return GObject