--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 19:35
--

local Class = require('libs.Class')

---@class FairyGUI.TweenManager:ClassType
local TweenManager = Class.inheritsFrom('TweenManager')

---@return FairyGUI.GTweener
function TweenManager.CreateTween() end

--TODO: FairyGUI.TweenManager

FairyGUI.TweenManager = TweenManager
return TweenManager