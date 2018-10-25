--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/25 10:29
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local IColorGear = FairyGUI.IColorGear
local IAnimationGear = FairyGUI.IAnimationGear

---@class FairyGUI.GLoader:FairyGUI.GObject @implement IAnimationGear, IColorGear
---@field playing boolean
---@field public frame number
---@field public timeScale number
---@field public ignoreEngineTimeScale boolean
---@field color Love2DEngine.Color
local GLoader = Class.inheritsFrom('GLoader', nil, GObject)

---@param time number
function IAnimationGear:Advance(time)

end

--TODO: FairyGUI.GLoader

FairyGUI.GLoader = GLoader
return GLoader