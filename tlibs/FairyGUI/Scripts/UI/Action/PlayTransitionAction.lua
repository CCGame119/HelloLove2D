--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:30
--

local Class = require('libs.Class')

local ControllerAction = FairyGUI.ControllerAction

---@class FairyGUI.PlayTransitionAction:FairyGUI.ControllerAction
local PlayTransitionAction = Class.inheritsFrom('PlayTransitionAction', nil, ControllerAction)

--TODO: FairyGUI.PlayTransitionAction

FairyGUI.PlayTransitionAction = PlayTransitionAction
return PlayTransitionAction