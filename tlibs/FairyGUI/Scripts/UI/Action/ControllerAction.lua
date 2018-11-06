--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:29
--

local Class = require('libs.Class')

local PlayTransitionAction = FairyGUI.PlayTransitionAction
local ChangePageAction = FairyGUI.ChangePageAction

---@class FairyGUI.ControllerAction.ActionType:enum
local ActionType = {
    PlayTransition = 0,
    ChangePage = 1
}

---@class FairyGUI.ControllerAction:ClassType
---@field public fromPage string[]
---@field public toPage string[]
local ControllerAction = Class.inheritsFrom('ControllerAction')

---@param actionType FairyGUI.ControllerAction.ActionType
function ControllerAction.CreateAction(actionType)
    if actionType == ActionType.PlayTransition then
        return PlayTransitionAction.new()
    elseif actionType == ActionType.ChangePage then
        return ChangePageAction.new()
    end
    return nil
end

---@param controller FairyGUI.Controller
---@param prevPage string
---@param curPage string
function ControllerAction:Run(controller, prevPage, curPage)
    if (self.fromPage == nil or self.fromPage:len() == 0 or self.fromPage:indexOf(prevPage) ~= -1)
            and (self.toPage == nil or self.toPage:len() == 0 or self.toPage:indexOf(curPage) ~= -1) then
        self:Enter(controller)
    else
        self:Leave(controller)
    end
end

---@param controller FairyGUI.Controller
function ControllerAction:Enter(controller) end

---@param controller FairyGUI.Controller
function ControllerAction:Leave(controller) end

---@param buffer Utils.ByteBuffer
function ControllerAction:Setup(buffer)
    local cnt = buffer:ReadShort()
    self.fromPage = {}
    for i = 1, cnt do
        self.fromPage[i] = buffer:ReadS()
    end

    cnt = buffer:ReadShort()
    self.toPage = {}
    for i = 1, cnt do
        self.toPage[i] = buffer:ReadS()
    end
end

ControllerAction.ActionType = ActionType
FairyGUI.ControllerAction = ControllerAction
return ControllerAction