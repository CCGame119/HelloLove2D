--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:28
--

local Class = require('libs.Class')

local ControllerAtion = FairyGUI.ControllerAtion

---@class FairyGUI.ChangePageAction:FairyGUI.ControllerAtion
local ChangePageAction = Class.inheritsFrom('ChangePageAction', nil, ControllerAtion)

--TODO: FairyGUI.ControllerAtion

FairyGUI.ControllerAtion = ControllerAtion
return ControllerAtion