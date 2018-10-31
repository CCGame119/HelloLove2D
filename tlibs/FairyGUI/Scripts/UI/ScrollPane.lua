--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:51
--

local Class = require('libs.Class')

local EventDispatcher = FairyGUI.EventDispatcher

---@class FairyGUI.ScrollPane:FairyGUI.EventDispatcher
local ScrollPane = Class.inheritsFrom('ScrollPane', nil, EventDispatcher)

--TODO: FairyGUI.ScrollPane

FairyGUI.ScrollPane = ScrollPane
return ScrollPane