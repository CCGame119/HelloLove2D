--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 19:43
--

local Class = require('libs.Class')

local Container = FairyGUI.Container
local EventListener = FairyGUI.EventListener

---@class FairyGUI.Stage:FairyGUI.Container
---@field public inst FairyGUI.Stage
---@field public stageHeight number
---@field public stageWidth number
---@field public soundVolume number
---@field public onStageResized FairyGUI.EventListener
---@field public cachedTransform Love2DEngine.Transform
---@field private _inst FairyGUI.Stage
local Stage = Class.inheritsFrom('Stage', nil, Container)

--TODO: FairyGUI.Stage

local __get = Class.init_get(Stage)
local __set = Class.init_set(Stage)

---@param self FairyGUI.Stage
__get.inst = function(self)
    if self._inst == nil then
        self:Instantiate()
    end
    return self._inst
end

FairyGUI.Stage = Stage
return Stage