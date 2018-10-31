--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:52
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

local ITweenListener = FairyGUI.ITweenListener

---@class FairyGUI.PlayCompleteCallback:Delegate @fun()
local PlayCompleteCallback = Delegate.newDelegate('PlayCompleteCallback')
---@class FairyGUI.TransitionHook:Delegate @fun()
local TransitionHook = Delegate.newDelegate('TransitionHook')

---@class FairyGUI.Transition:FairyGUI.ITweenListener
local Transition = Class.inheritsFrom('Transition', nil, ITweenListener)

--TODO: FairyGUI.Transition

FairyGUI.PlayCompleteCallback = PlayCompleteCallback
FairyGUI.TransitionHook = TransitionHook
FairyGUI.Transition = Transition
return Transition