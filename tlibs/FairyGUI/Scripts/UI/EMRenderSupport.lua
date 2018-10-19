--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:08
--

local Class = require('libs.Class')

---@class FairyGUI.EMRenderTarget:ClassType
---@field EM_sortingOrder number
local EMRenderTarget = Class.inheritsFrom('EMRenderTarget')

function EMRenderTarget:EM_BeforeUpdate() end
---@param context FairyGUI.UpdateContext
function EMRenderTarget:EM_Update(context) end
function EMRenderTarget:EM_Reload() end

---@class FairyGUI.EMRenderSupport:ClassType
local EMRenderSupport = Class.inheritsFrom('EMRenderSupport')

EMRenderSupport.orderChanged = false

--TODO: FairyGUI.EMRenderSupport

FairyGUI.EMRenderTarget = EMRenderTarget
FairyGUI.EMRenderSupport = EMRenderSupport
return EMRenderSupport