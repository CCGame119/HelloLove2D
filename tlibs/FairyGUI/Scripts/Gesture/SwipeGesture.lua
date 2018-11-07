--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 10:59
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2
local Vector3 = Love2DEngine.Vector3
local Time = Love2DEngine.Time

local EventDispather = FairyGUI.EventDispatcher
local EventListener = FairyGUI.EventListener
local EventCallback1 = FairyGUI.EventCallback1
local Stage = FairyGUI.Stage
local GRoot = FairyGUI.GRoot
local UIConfig = FairyGUI.UIConfig

---@class FairyGUI.SwipeGesture:FairyGUI.EventDispatcher
---滑动手势。你可以通过onBegin+onMove+onEnd关心整个滑动过程，也可以只使用onAction关注最后的滑动结果。滑动结果包括方向和加速度，可以从position和velocity获得。
---注意onAction仅当滑动超过一定距离(actionDistance)时才触发。
---@field public host FairyGUI.GObject
---@field public onBegin FairyGUI.EventListener @当手指开始扫动时派发该事件。
---@field public onEnd FairyGUI.EventListener @当其中一个手指离开屏幕时派发该事件。
---@field public onMove FairyGUI.EventListener @手指在滑动时派发该事件。
---@field public onAction FairyGUI.EventListener @ 当手指从按下到离开经过的距离大于actionDistance时派发该事件。
---@field public velocity Love2DEngine.Vector2 @手指离开时的加速度
---@field public position Love2DEngine.Vector2 @你可以在onBegin事件中设置这个值，那个后续将根据手指移动的距离修改这个值。如果不设置，那position初始为(0,0)，反映手指扫过的距离。
---@field public delta Love2DEngine.Vector2 @移动的变化值
---@field public actionDistance number @派发onAction事件的最小距离。如果手指扫过的距离少于此值，onAction不会触发（但onEnd仍然会派发）
---@field public snapping boolean @是否把变化量强制为整数。默认true。
---@field private _startPoint Love2DEngine.Vector2
---@field private _lastPoint Love2DEngine.Vector2
---@field private _time number
---@field private _started boolean
---@field private _touchBegan boolean
local SwipeGesture = Class.inheritsFrom('SwipeGesture', nil, EventDispather)

SwipeGesture.ACTION_DISTANCE = 200

---@param host FairyGUI.GObject
function SwipeGesture:__ctor(host)
    self.host = host
    self.actionDistance = SwipeGesture.ACTION_DISTANCE
    self.snapping = true
    self:Enable(true)

    self.onBegin = EventListener.new(self, "onSwipeBegin")
    self.onEnd = EventListener.new(self, "onSwipeEnd")
    self.onMove = EventListener.new(self, "onSwipeMove")
    self.onAction = EventListener.new(self, "onnSwipeAction")

    self.__touchBeginDelegate = EventCallback1.new(self.__touchBegin, self)
    self.__touchMoveDelegate = EventCallback1.new(self.__touchMove, self)
    self.__touchEndDelegate = EventCallback1.new(self.__touchEnd, self)
end

function SwipeGesture:Dispose()
    self:Enable(false)
    self.host = nil
end

---@param value boolean
function SwipeGesture:Enable(value)
    if (value) then
        if (self.host == GRoot.inst) then
            Stage.inst.onTouchBegin:Add(self.__touchBeginDelegate)
            Stage.inst.onTouchMove:Add(self.__touchMoveDelegate)
            Stage.inst.onTouchEnd:Add(self.__touchEndDelegate)
        else
            self.host.onTouchBegin:Add(self.__touchBeginDelegate)
            self.host.onTouchMove:Add(self.__touchMoveDelegate)
            self.host.onTouchEnd:Add(self.__touchEndDelegate)
        end
    else
        self._started = false
        self._touchBegan = false
        if (self.host == GRoot.inst) then
            Stage.inst.onTouchBegin:Remove(self.__touchBeginDelegate)
            Stage.inst.onTouchMove:Remove(self.__touchMoveDelegate)
            Stage.inst.onTouchEnd:Remove(self.__touchEndDelegate)
        else
            self.host.onTouchBegin:Remove(self.__touchBeginDelegate)
            self.host.onTouchMove:Remove(self.__touchMoveDelegate)
            self.host.onTouchEnd:Remove(self.__touchEndDelegate)
        end
    end
end

---@param context FairyGUI.EventContext
function SwipeGesture:__touchBegin(context)
    if (Stage.inst.touchCount > 1) then
        self._touchBegan = false
        if (self._started) then
            self._started = false
            self.onEnd:Call(context.inputEvent)
        end
        return
    end

    local evt = context.inputEvent
    self._startPoint = self.host:GlobalToLocal(Vector2(evt.x, evt.y))
    self._lastPoint = self._startPoint:Clone()

    self._time = Time.unscaledTime
    self._started = false
    self.velocity = Vector2.zero
    self.position = Vector2.zero
    self._touchBegan = true

    context:CaptureTouch()
end

---@param context FairyGUI.EventContext
function SwipeGesture:__touchMove(context)
    if (not self._touchBegan or Stage.inst.touchCount > 1) then
        return
    end

    local evt = context.inputEvent
    local pt = self.host:GlobalToLocal(Vector2(evt.x, evt.y))
    self.delta = pt - self._lastPoint
    if self.snapping then
        self.delta.x = math.round(self.delta.x)
        self.delta.y = math.round(self.delta.y)
        if (self.delta.x == 0 and self.delta.y == 0) then
            return
        end
    end

    local deltaTime = Time.unscaledDeltaTime
    local elapsed = (Time.unscaledTime - self._time) * 60 - 1
    if (elapsed > 1) then --速度衰减
        self.velocity = self.velocity * math.pow(0.833, elapsed)
    end
    self.velocity = Vector3.Lerp(self.velocity, self.delta / deltaTime, deltaTime * 10)
    self._time = Time.unscaledTime
    self.position = self.position + self.delta
    self._lastPoint = pt

    if not self._started then --灵敏度检查，为了和点击区分
        local sensitivity
        if (Stage.touchScreen) then
            sensitivity = UIConfig.touchDragSensitivity
        else
            sensitivity = 5
        end

        if (math.abs(self.delta.x) < sensitivity and math.abs(self.delta.y) < sensitivity) then
            return
        end
        self._started = true
        self.onBegin:Call(evt)
    end

    self.onMove:Call(evt)
end

---@param context FairyGUI.EventContext
function SwipeGesture:__touchEnd(context)
    if not self._started then
        return
    end

    self._started = false
    self._touchBegan = false

    local evt = context.inputEvent
    local pt = self.host:GlobalToLocal(Vector2(evt.x, evt.y))
    self.delta = pt - self._lastPoint
    if self.snapping then
        self.delta.x = math.round(self.delta.x)
        self.delta.y = math.round(self.delta.y)
    end
    self.position = self.position + self.delta

    --更新速度
    local elapsed = (Time.unscaledTime - self._time) * 60 - 1
    if elapsed > 1 then
        self.velocity = self.velocity * math.pow(0.833, elapsed)
    end
    if self.snapping then
        self.velocity.x = math.round(self.velocity.x)
        self.velocity.y = math.round(self.velocity.y)
    end
    self.onEnd:Call(evt)

    pt = pt - self._startPoint
    if (math.abs(pt.x) > self.actionDistance or math.abs(pt.y) > self.actionDistance) then
        self.onAction:Call(evt)
    end
end


FairyGUI.SwipeGesture = SwipeGesture
return SwipeGesture