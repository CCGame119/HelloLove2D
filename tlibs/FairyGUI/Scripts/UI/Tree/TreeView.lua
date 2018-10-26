--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 19:40
--

local Class = require('libs.Class')

local EventDispatcher = FairyGUI.EventDispatcher

---@class FairyGUI.TreeView:FairyGUI.EventDispatcher
local TreeView = Class.inheritsFrom('TreeView', nil, EventDispatcher)

--TODO: FairyGUI.TreeView

FairyGUI.TreeView = TreeView
return TreeView