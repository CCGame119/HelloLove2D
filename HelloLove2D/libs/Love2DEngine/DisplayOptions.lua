--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 11:51
--

local Class = require('libs.Class')

local HideFlags = Love2DEngine.HideFlags

---@class Love2DEngine.DisplayOptions:ClassType
---@field public hideFlags Love2DEngine.HideFlags
local DisplayOptions = Class.inheritsFrom('DisplayOptions')

DisplayOptions.hideFlags = HideFlags.None

function DisplayOptions.SetEditModeHideFlags()
    DisplayOptions.hideFlags = HideFlags.DontSaveInEditor
end

Love2DEngine.DisplayOptions = DisplayOptions
return DisplayOptions