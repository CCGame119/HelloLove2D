--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 19:43
--

local Class = require('libs.Class')

local Container = FairyGUI.Container
local EventListener = FairyGUI.EventListener

--region FairyGUI.TouchInfo
---@class FairyGUI.TouchInfo:ClassType
---@field public x number 
---@field public y number 
---@field public touchId number 
---@field public clickCount number 
---@field public keyCode char
---@field public character char 
---@field public modifiers FairyGUI.EventModifiers
---@field public mouseWheelDelta number 
---@field public button number 
---@field public downX number 
---@field public downY number 
---@field public began boolean 
---@field public clickCancelled boolean 
---@field public lastClickTime number 
---@field public target FairyGUI.DisplayObject
---@field public downTargets FairyGUI.DisplayObject[]
---@field public lastRollOver FairyGUI.DisplayObject
---@field public touchMonitors FairyGUI.EventDispatcher
---@field public evt FairyGUI.InputEvent
local TouchInfo = Class.inheritsFrom('TouchInfo')

---@type FairyGUI.EventBridge[]
TouchInfo.sHelperChain = {}
--endregion

--region FairyGUI.Stage
---@class FairyGUI.Stage:FairyGUI.Container
---@field public inst FairyGUI.Stage @static
---@field public stageHeight number
---@field public stageWidth number
---@field public soundVolume number
---@field public onStageResized FairyGUI.EventListener
---@field public cachedTransform Love2DEngine.Transform
---@field private _inst FairyGUI.Stage
---@field private _touchTarget FairyGUI.DisplayObject
---@field private _focused FairyGUI.DisplayObject
---@field private _lastInput FairyGUI.InputTextField
---@field private _updateContext FairyGUI.UpdateContext
---@field private _rollOutChain FairyGUI.DisplayObject[]
---@field private _rollOverChain FairyGUI.DisplayObject[]
---@field private _touches FairyGUI.TouchInfo[]
---@field private _touchCount number
---@field private _touchPosition Love2DEngine.Vector2
---@field private _frameGotHitTarget number
---@field private _frameGotTouchPosition number
---@field private _customInput boolean
---@field private _customInputPos Love2DEngine.Vector2
---@field private _customInputButtonDown boolean
---@field private _focusRemovedDelegate FairyGUI.EventCallback1
---@field private _audio Love2DEngine.AudioSource
---@field private _toCollectTexture FairyGUI.NTexture
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
setmetatable(Stage, Stage)
--endregion

FairyGUI.Stage = Stage
FairyGUI.TouchInfo = TouchInfo
return Stage