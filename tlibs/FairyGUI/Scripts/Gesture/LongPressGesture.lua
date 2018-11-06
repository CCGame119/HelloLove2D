--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 10:55
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2

local EventDispatcher = FairyGUI.EventDispatcher
local EventListener = FairyGUI.EventListener
local Timers = FairyGUI.Timers
local TimerCallback = FairyGUI.TimerCallback
local EventCallback1 = FairyGUI.EventCallback1
local GRoot = FairyGUI.GRoot
local Stage = FairyGUI.Stage

---@class FairyGUI.LongPressGesture:FairyGUI.EventDispatcher
---长按手势。当按下一定时间后(duration)，派发onAction，如果once为false，
---则间隔duration时间持续派发onAction，直到手指释放。
---
---@field public host FairyGUI.GObject
---@field public onBegin FairyGUI.EventListener
---@field public onBegin FairyGUI.EventListener
---@field public onBegin FairyGUI.EventListener
---@field public trigger number
---@field public interval number
---@field public once boolean
---@field public holdRangeRadius number
---@field private _startPoint Love2DEngine.Vector2
---@field private _started boolean
local LongPressGesture = Class.inheritsFrom('LongPressGesture', nil, EventDispatcher)

LongPressGesture.TRIGGER = 1.5
LongPressGesture.INTERVAL = 1

---@param host FairyGUI.GObject
function LongPressGesture:__ctor(host)
    self.host = host
    self.trigger = LongPressGesture.TRIGGER
    self.interval = LongPressGesture.INTERVAL
    self.holdRangeRadius = 50
    self:Enable(true)

    self.onBegin = EventListener.new(self, "onLongPressBegin")
    self.onEnd = EventListener.new(self, "onLongPressEnd")
    self.onAction = EventListener.new(self, "onLongPressAction")

    self.__timerDelegate  = TimerCallback.new(self.__timer, self)
    self.__touchBeginDelegate  = EventCallback1.new(self.__touchBegin, self)
    self.__touchEndDelegate  = EventCallback1.new(self.__touchEnd, self)
end

function LongPressGesture:Dispose()
    self:Enable(false)
    self.host = nil
end

---@param value boolean
function LongPressGesture:Enable(value)
    if (value) then
        if (self.host == GRoot.inst) then
            Stage.inst.onTouchBegin:Add(self.__touchBeginDelegate)
            Stage.inst.onTouchEnd:Add(self.__touchEndDelegate)
        else
            self.host.onTouchBegin:Add(self.__touchBeginDelegate)
            self.host.onTouchEnd:Add(self.__touchEndDelegate)
        end
    else
        if (self.host == GRoot.inst) then
            Stage.inst.onTouchBegin:Remove(self.__touchBeginDelegate)
            Stage.inst.onTouchEnd:Remove(self.__touchEndDelegate)
        else
            self.host.onTouchBegin:Remove(self.__touchBeginDelegate)
            self.host.onTouchEnd:Remove(self.__touchEndDelegate)
        end
        Timers.inst:Remove(self.__timerDelegate)
    end
end

function LongPressGesture:Cancel()
    Timers.inst:Remove(self.__timerDelegate)
    self._started = false
end

---@param context FairyGUI.EventContext
function LongPressGesture:__touchBegin(context)
    local evt = context.inputEvent
    self._startPoint = self.host:GlobalToLocal(Vector2(evt.x, evt.y))
    self._started = false

    Timers.inst:Add(self.trigger, 1, self.__timerDelegate)
    context:CaptureTouch()
end

---@param param any
function LongPressGesture:__timer(param)
    local pt = self.host:GlobalToLocal(Stage.inst.touchPosition)
    if (math.pow(pt.x - self._startPoint.x, 2) + math.pow(pt.y - self._startPoint.y, 2) > math.pow(self.holdRangeRadius, 2)) then
        Timers.inst:Remove(self.__timerDelegate)
        return
    end
    if not self._started then
        self._started = true
        self.onBegin:Call()

        if not self.once then
            Timers.inst:Add(self.interval, 0, self.__timerDelegate)
        end
    end

    self.onAction:Call()
end

---@param context FairyGUI.EventContext
function LongPressGesture:__touchEnd(context)
    Timers.inst:Remove(self.__timerDelegate)

    if self._started then
        self._started = false
        self.onEnd:Call()
    end
end

FairyGUI.LongPressGesture = LongPressGesture
return LongPressGesture