--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:28
--

local Class = require('libs.Class')

local ControllerAtion = FairyGUI.ControllerAtion

---@class FairyGUI.ChangePageAction:FairyGUI.ControllerAction
---@field public objectId string
---@field public controllerName string
---@field public targetPage string
local ChangePageAction = Class.inheritsFrom('ChangePageAction', nil, ControllerAtion)

---@param controller FairyGUI.Controller
function ChangePageAction:Enter(controller)
    if string.isNullOrEmpty(self.controllerName) then
        return
    end

    ---@type FairyGUI.GComponent
    local gcom
    if not string.isNullOrEmpty(self.objectId) then
        gcom = controller.parent:GetChildById(self.objectId)
    else
        gcom = controller.parent
    end
    if (gcom ~= nil) then
        local cc = gcom:GetController(self.controllerName)
        if (cc ~= nil and cc ~= controller and not cc.changing) then
            cc.selectedPageId = self.targetPage
        end
    end
end

---@param buffer Utils.ByteBuffer
function ChangePageAction:Setup(buffer)
    ControllerAtion.Setup(self, buffer)

    self.objectId = buffer:ReadS()
    self.controllerName = buffer:ReadS()
    self.targetPage = buffer:ReadS()
end

FairyGUI.ControllerAtion = ControllerAtion
return ControllerAtion