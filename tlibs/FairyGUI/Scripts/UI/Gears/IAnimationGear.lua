--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/25 10:30
--

local Class = require('libs.Class')

---@class FairyGUI.IAnimationGear:ClassType
---@field playing boolean
---@field public frame number
---@field public timeScale number
---@field public ignoreEngineTimeScale boolean
local IAnimationGear = Class.inheritsFrom('IAnimationGear')

---@param time number
function IAnimationGear:Advance(time) end

FairyGUI.IAnimationGear = IAnimationGear
return IAnimationGear