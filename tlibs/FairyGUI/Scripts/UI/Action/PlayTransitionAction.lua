--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:30
--

local Class = require('libs.Class')

local ControllerAction = FairyGUI.ControllerAction

---@class FairyGUI.PlayTransitionAction:FairyGUI.ControllerAction
---@field public transitionName string
---@field public playTimes number
---@field public delay number
---@field public stopOnExit boolean
---@field private _currentTransition FairyGUI.Transition
local PlayTransitionAction = Class.inheritsFrom('PlayTransitionAction', nil, ControllerAction)

function PlayTransitionAction:__ctor()
    self.playTimes = 1
    self.delay = 0
end

---@param controller FairyGUI.Controller
function PlayTransitionAction:Enter(controller)
    local trans = controller.parent:GetTransition(self.transitionName)
    if (trans ~= nil) then
        if (self._currentTransition ~= nil and self._currentTransition.playing) then
            trans:ChangePlayTimes(self.playTimes)
        else
            trans:Play(self.playTimes, self.delay, nil)
        end
        self._currentTransition = trans
    end
end

---@param controller FairyGUI.Controller
function PlayTransitionAction:Leave(controller)
    if (self.stopOnExit and self._currentTransition ~= nil) then
        self._currentTransition:Stop()
        self._currentTransition = nil
    end
end

---@param buffer Utils.ByteBuffer
function PlayTransitionAction:Setup(buffer)
    ControllerAction.Setup(self, buffer)

    self.transitionName = buffer:ReadS()
    self.playTimes = buffer:ReadInt()
    self.delay = buffer:ReadFloat()
    self.stopOnExit = buffer:ReadBool()
end


FairyGUI.PlayTransitionAction = PlayTransitionAction
return PlayTransitionAction