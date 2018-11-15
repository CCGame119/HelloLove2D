--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:08
--

local Class = require('libs.Class')

--region EMRenderTarget
---@class FairyGUI.EMRenderTarget:ClassType
---@field EM_sortingOrder number
local EMRenderTarget = Class.inheritsFrom('EMRenderTarget')

function EMRenderTarget:EM_BeforeUpdate() end

---@param context FairyGUI.UpdateContext
function EMRenderTarget:EM_Update(context) end

function EMRenderTarget:EM_Reload() end
--endregion


function EMRenderTarget:EM_BeforeUpdate() end
---@param context FairyGUI.UpdateContext
function EMRenderTarget:EM_Update(context) end
function EMRenderTarget:EM_Reload() end

---@class FairyGUI.EMRenderSupport:ClassType @这是一个在编辑状态下渲染UI的功能类。EM=Edit Mode
---@field public packageListReady boolean
---@field public hasTarget boolean
local EMRenderSupport = Class.inheritsFrom('EMRenderSupport')

EMRenderSupport.orderChanged = false
---@type FairyGUI.UpdateContext
EMRenderSupport._updateContext = false
---@type FairyGUI.EMRenderTarget[]
EMRenderSupport._targets = {}

---@param value FairyGUI.EMRenderTarget
function EMRenderSupport.Add(value)
    if EMRenderSupport._targets:indexOf(value) == -1 then
        table.insert(EMRenderSupport._targets, value)
    end
    EMRenderSupport.orderChanged = true
end

---@param value FairyGUI.EMRenderTarget
function EMRenderSupport.Remove(value)
    local index = EMRenderSupport._targets:indexOf(value)
    if -1 ~= index then
        table.remove(EMRenderSupport._targets, index)
    end
end

function EMRenderSupport.Update()
    if (EMRenderSupport._updateContext == nil) then
        EMRenderSupport._updateContext = UpdateContext.new()
    end

    if (EMRenderSupport.orderChanged) then
        table.sort(EMRenderSupport._targets, EMRenderSupport.CompareDepth)
        EMRenderSupport.orderChanged = false
    end

    for _, panel in ipairs(EMRenderSupport._targets) do
        panel:EM_BeforeUpdate()
    end

    if (EMRenderSupport.packageListReady) then
        EMRenderSupport._updateContext:Begin()
        for _, panel in ipairs(EMRenderSupport._targets) do
            panel:EM_Update(EMRenderSupport._updateContext)
        end
        EMRenderSupport._updateContext:End()
    end
end

function EMRenderSupport.Reload()
    EMRenderSupport.packageListReady = true
    for _, panel in ipairs(EMRenderSupport._targets) do
        panel:EM_Reload()
    end
end

---@param c1 FairyGUI.EMRenderTarget
---@param c2 FairyGUI.EMRenderTarget
---@return number
function EMRenderSupport.CompareDepth(c1, c2)
    return c1.EM_sortingOrder - c2.EM_sortingOrder
end

FairyGUI.EMRenderTarget = EMRenderTarget
FairyGUI.EMRenderSupport = EMRenderSupport
return EMRenderSupport