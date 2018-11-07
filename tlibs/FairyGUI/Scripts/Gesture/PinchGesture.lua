--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 10:56
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2

local EventDispatcher = FairyGUI.EventDispatcher
local EventListener = FairyGUI.EventListener
local EventCallback1 = FairyGUI.EventCallback1
local Stage = FairyGUI.Stage
local GRoot = FairyGUI.GRoot
local UIConfig = FairyGUI.UIConfig

---@class FairyGUI.PinchGesture:FairyGUI.EventDispatcher
---两个指头捏或者放的手势。
---@field public host FairyGUI.GObject
---@field public onBegin FairyGUI.EventListener @当两个手指开始呈捏手势时派发该事件。
---@field public onEnd FairyGUI.EventListener @当其中一个手指离开屏幕时派发该事件。
---@field public onAction FairyGUI.EventListener @当手势动作时派发该事件。
---@field public scale number @总共缩放的量。
---@field public delta number @从上次通知后的改变量。
---@field private _startDistance number
---@field private _lastScale number
---@field private _touches number[]
---@field private _started boolean
---@field private _touchBegan boolean
local PinchGesture = Class.inheritsFrom('PinchGesture')

---@param host FairyGUI.GObject
function PinchGesture:__ctor(host)
    self.host = host
    self:Enable(true)

    self._touches = {0, 0}

    self.onBegin = EventListener.new(self, "onPinchBegin")
    self.onEnd = EventListener.new(self, "onPinchEnd")
    self.onAction = EventListener.new(self, "onPinchAction")

    self.__touchBeginDelegate = EventCallback1.new(self.__touchBegin, self)
    self.__touchMoveDelegate = EventCallback1.new(self.__touchMove, self)
    self.__touchEndDelegate = EventCallback1.new(self.__touchEnd, self)
end

function PinchGesture:Dispose()
    self:Enable(false)
    self.host = nil
end

---@param value boolean
function PinchGesture:Enable(value)
    if (value) then
        if (self.host == GRoot.inst) then
            Stage.inst.onTouchBegin:Add(self.__tDelegateouchBegin)
            Stage.inst.onTouchMove:Add(self.__tDelegateouchMove)
            Stage.inst.onTouchEnd:Add(self.__tDelegateouchEnd)
        else
            self.host.onTouchBegin:Add(self.__tDelegateouchBegin)
            self.host.onTouchMove:Add(self.__tDelegateouchMove)
            self.host.onTouchEnd:Add(self.__tDelegateouchEnd)
        end
    else
        self._started = false
        self._touchBegan = false
        if (self.host == GRoot.inst) then
            Stage.inst.onTouchBegin:Remove(self.__tDelegateouchBegin)
            Stage.inst.onTouchMove:Remove(self.__tDelegateouchMove)
            Stage.inst.onTouchEnd:Remove(self.__tDelegateouchEnd)
        else
            self.host.onTouchBegin:Remove(self.__tDelegateouchBegin)
            self.host.onTouchMove:Remove(self.__tDelegateouchMove)
            self.host.onTouchEnd:Remove(self.__tDelegateouchEnd)
        end
    end
end

---@param context FairyGUI.EventContext
function PinchGesture:__touchBegin(context)
    if (Stage.inst.touchCount == 2) then
        if (not self._started and not self._touchBegan) then
            self._touchBegan = true
            Stage.inst:GetAllTouch(self._touches)
            local pt1 = self.host.GlobalToLocal(Stage.inst:GetTouchPosition(self._touches[1]))
            local pt2 = self.host.GlobalToLocal(Stage.inst:GetTouchPosition(self._touches[2]))
            self._startDistance = Vector2.Distance(pt1, pt2)

            context:CaptureTouch()
        end
    end
end

---@param context FairyGUI.EventContext
function PinchGesture:__touchMove(context)
    if (not self._touchBegan or Stage.inst.touchCount ~= 2) then
        return
    end

    local evt = context.inputEvent
    local pt1 = self.host:GlobalToLocal(Stage.inst:GetTouchPosition(self._touches[1]))
    local pt2 = self.host:GlobalToLocal(Stage.inst:GetTouchPosition(self._touches[2]))
    local dist = Vector2.Distance(pt1, pt2)

    if (not self._started and math.abs(dist - self._startDistance) > UIConfig.touchDragSensitivity) then
        self._started = true
        scale = 1
        self._lastScale = 1

        self.onBegin:Call(evt)
    end

    if (self._started) then
        local ss = dist / self._startDistance
        self.delta = ss - self._lastScale
        self._lastScale = ss
        self.scale = self.scale + self.delta
        self.onAction:Call(evt)
    end
end

---@param context FairyGUI.EventContext
function PinchGesture:__touchEnd(context)
    self._touchBegan = false
    if (self._started) then
        self._started = false
        self.onEnd:Call(context.inputEvent)
    end
end


FairyGUI.PinchGesture = PinchGesture
return PinchGesture