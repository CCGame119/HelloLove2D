--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 10:57
--

local Class = require('libs.Class')

local EventDispatcher = FairyGUI.EventDispatcher
local EventListener = FairyGUI.EventListener
local EventCallback1 = FairyGUI.EventCallback1
local Stage = FairyGUI.Stage
local GRoot = FairyGUI.GRoot

---@class FairyGUI.RotationGesture:FairyGUI.EventDispatcher
---手指反向操作的手势。
---@field public host FairyGUI.GObject
---@field public onBegin FairyGUI.EventListener @当两个手指开始呈反向操作时派发该事件。
---@field public onEnd FairyGUI.EventListener @当其中一个手指离开屏幕时派发该事件。
---@field public onAction FairyGUI.EventListener @当手势动作时派发该事件。
---@field public rotation number @总共旋转的角度。
---@field public delta 从上次通知后的改变量。
---@field public snapping boolean @是否把变化量强制为整数。默认true。
---@field private _startVector Love2DEngine.Vector2
---@field private _lastRotation number
---@field private _touches number[]
---@field private _started boolean
---@field private _touchBegan boolean
local RotationGesture = Class.inheritsFrom('RotationGesture', nil, EventDispatcher)

---@param host FairyGUI.GObject
function RotationGesture:__ctor(host)
    self.host = host
    self:Enable(true)

    self._touches = {0, 0}
    self.snapping = true

    self.onBegin = EventListener.new(self, "onRotationBegin")
    self.onEnd = EventListener.new(self, "onRotationEnd")
    self.onAction = EventListener.new(self, "onRotationAction")

    self.__touchBeginDelegate = EventCallback1.new(self.__touchBegin, self)
    self.__touchMoveDelegate = EventCallback1.new(self.__touchMove, self)
    self.__touchEndDelegate = EventCallback1.new(self.__touchEnd, self)
end

function RotationGesture:Dispose()
    self:Enable(false)
    self.host = nil
end

---@param value boolean
function RotationGesture:Enable(value)
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
function RotationGesture:__touchBegin(context)
    if (Stage.inst.touchCount == 2) then
        if (not self._started and not self._touchBegan) then
            self._touchBegan = true
            Stage.inst:GetAllTouch(self._touches)
            local pt1 = self.host.GlobalToLocal(Stage.inst:GetTouchPosition(self._touches[1]))
            local pt2 = self.host.GlobalToLocal(Stage.inst:GetTouchPosition(self._touches[2]))
            self._startVector = pt1 - pt2

            context:CaptureTouch()
        end
    end
end

---@param context FairyGUI.EventContext
function RotationGesture:__touchMove(context)
    if (not self._touchBegan or Stage.inst.touchCount ~= 2) then
        return
    end

    local evt = context.inputEvent
    local pt1 = self.host:GlobalToLocal(Stage.inst:GetTouchPosition(self._touches[1]))
    local pt2 = self.host:GlobalToLocal(Stage.inst:GetTouchPosition(self._touches[2]))
    local vec = pt1 - pt2

    local rot = math.Deg2Rad * ((math.atan2(vec.y, vec.x) - math.atan2(self._startVector.y, self._startVector.x)))
    if self.snapping then
        rot = math.round(rot)
        if (rot == 0) then
            return
        end
    end

    if (not self._started and rot > 5) then
        self._started = true
        self.rotation = 0
        self._lastRotation = 0

        self.onBegin:Call(evt)
    end

    if self._started then
        self.delta = rot - self._lastRotation
        self._lastRotation = rot
        self.rotation = self.rotation + selfdelta
        self.onAction:Call(evt)
    end
end

---@param context FairyGUI.EventContext
function RotationGesture:__touchEnd(context)
    self._touchBegan = false
    if (self._started) then
        self._started = false
        self.onEnd:Call(context.inputEvent)
    end
end


FairyGUI.RotationGesture = RotationGesture
return RotationGesture