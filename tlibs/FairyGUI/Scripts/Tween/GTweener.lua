--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 19:36
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

local Random = Love2DEngine.Random
local Debug = Love2DEngine.Debug
local Time = Love2DEngine.Time
local Vector2 = Love2DEngine.Vector2
local Vector3 = Love2DEngine.Vector3
local Vector4 = Love2DEngine.Vector4
local Color = Love2DEngine.Color
local TweenValue = FairyGUI.TweenValue
local GTween = FairyGUI.GTween
local TweenPropType = FairyGUI.TweenPropType
local TweenPropTypeUtils = FairyGUI.TweenPropTypeUtils
local EaseType = FairyGUI.EaseType
local EaseManager = FairyGUI.EaseManager


--========================= 声明回调委托 =========================
---@class FairyGUI.GTweenCallback:Delegate
local GTweenCallback = Delegate.newDelegate('GTweenCallback')
---@class FairyGUI.GTweenCallback1:Delegate
local GTweenCallback1 = Delegate.newDelegate('GTweenCallback1')

--========================= ITweenListener =========================
---@class FairyGUI.ITweenListener:ClassType
local ITweenListener = Class.inheritsFrom('ITweenListener')

---@param tweener FairyGUI.GTweener
function ITweenListener:OnTweenStart(tweener) end
---@param tweener FairyGUI.GTweener
function ITweenListener:OnTweenUpdate(tweener) end
---@param tweener FairyGUI.GTweener
function ITweenListener:OnTweenComplete(tweener) end

--region 类定义
--========================= GTweener =========================
---@class FairyGUI.GTweener:ClassType
---@field public delay number
---@field public duration number
---@field public Repeat number
---@field public target any
---@field public userData any
---@field public startValue FairyGUI.TweenValue
---@field public endValue FairyGUI.TweenValue
---@field public value FairyGUI.TweenValue
---@field public deltaValue FairyGUI.TweenValue
---@field public normalizedTime number
---@field public completed number
---@field public allCompleted number
---@field protected _target any
---@field protected _propType FairyGUI.TweenPropType
---@field protected _killed boolean
---@field protected _paused boolean
---@field private _delay number
---@field private _duration number
---@field private _breakponumber number
---@field private _easeType FairyGUI.EaseType
---@field private _easeOvershootOrAmplitude number
---@field private _easePeriod number
---@field private _repeat number
---@field private _yoyo boolean
---@field private _timeScale number
---@field private _ignoreEngineTimeScale boolean
---@field private _snapping boolean
---@field private _userData any
---@field private _onUpdate FairyGUI.GTweenCallback
---@field private _onStart FairyGUI.GTweenCallback
---@field private _onComplete FairyGUI.GTweenCallback
---@field private _onUpdate1 FairyGUI.GTweenCallback1
---@field private _onStart1 FairyGUI.GTweenCallback1
---@field private _onComplete1 FairyGUI.GTweenCallback1
---@field private _listener FairyGUI.ITweenListener
---@field private _startValue FairyGUI.TweenValue
---@field private _endValue FairyGUI.TweenValue
---@field private _value FairyGUI.TweenValue
---@field private _deltaValue FairyGUI.TweenValue
---@field private _valueSize number
---@field private _started boolean
---@field private _ended number
---@field private _elapsedTime number
---@field private _normalizedTime number
local GTweener = Class.inheritsFrom('GTweener')

--endregion

--region 类成员函数
function GTweener:__ctor()
    self._startValue = TweenValue.new()
    self._endValue = TweenValue.new()
    self._value = TweenValue.new()
    self._deltaValue = TweenValue.new()
end

---@param val number
---@return FairyGUI.GTweener
function GTweener:SetDelay(val)
    self._delay = val
    return self
end

---@param val number
---@return FairyGUI.GTweener
function GTweener:SetDuration(val)
    self._duration = val
    return self
end

---@param val number
---@return FairyGUI.GTweener
function GTweener:SetBreakpoint(val)
    self._breakpoint = val
    return self
end

---@param val FairyGUI.EaseType
---@return FairyGUI.GTweener
function GTweener:SetEase(val)
    self._easeType = val
    return self
end

---@param val number
---@return FairyGUI.GTweener
function GTweener:SetEasePeriod(val)
    self._easePeriod = val
    return self
end

---@param val number
---@return FairyGUI.GTweener
function GTweener:SetEaseOvershootOrAmplitude(val)
    self._easeOvershootOrAmplitude = val
    return self
end

---@param val number
---@param yoyo boolean @default:false
---@return FairyGUI.GTweener
function GTweener:SetRepeat(val, yoyo)

    self._repeat = val
    self._yoyo = yoyo
    return self
end

---@param val number
---@return FairyGUI.GTweener
function GTweener:SetTimeScale(val)
    self._timeScale = val
    return self
end

---@param val boolean
---@return FairyGUI.GTweener
function GTweener:SetIgnoreEngineTimeScale(val)
    self._ignoreEngineTimeScale = val
    return self
end

---@param val boolean
---@return FairyGUI.GTweener
function GTweener:SetSnapping(val)
    self._snapping = val
    return self
end

---@param val any
---@param propType FairyGUI.TweenPropType
---@return FairyGUI.GTweener
function GTweener:SetTarget(val, propType)
    self._target = val
    self._propType = propType or TweenPropType.None
    return self
end

---@param val any
---@return FairyGUI.GTweener
function GTweener:SetUserData(val)
    self._userData = val
    return self
end

---@param callback FairyGUI.GTweenCallback|FairyGUI.GTweenCallbac1
---@return FairyGUI.GTweener
function GTweener:OnUpdate(callback)
    if callback:isa(GTweenCallback) then
        self._onUpdate = callback
    elseif callback:isa(GTweenCallback1) then
        self._onUpdate1 = callback
    else
        assert(false, "type mismatch")
    end
    return self
end


---@param callback FairyGUI.GTweenCallback|FairyGUI.GTweenCallbac1
---@return FairyGUI.GTweener
function GTweener:OnStart(callback)
    if callback:isa(GTweenCallback) then
        self._onStart = callback
    elseif callback:isa(GTweenCallback1) then
        self._onStart1 = callback
    else
        assert(false, "type mismatch")
    end

    return self
end


---@param callback FairyGUI.GTweenCallback|FairyGUI.GTweenCallbac1
---@return FairyGUI.GTweener
function GTweener:OnComplete(callback)
    if callback:isa(GTweenCallback) then
        self._onComplete = callback
    elseif callback:isa(GTweenCallback1) then
        self._onComplete1 = callback
    else
        assert(false, "type mismatch")
    end
    return self
end

---@param val FairyGUI.ITweenListener
---@return FairyGUI.GTweener
function GTweener:SetListener(val)
    self._listener = val
    return self
end

---@param paused boolean
---@return FairyGUI.GTweener
function GTweener:SetPaused(paused)
    self._paused = paused
    return self
end

---@param time number
function GTweener:Seek(time)
    if self._killed then return end

    self._elapsedTime = time
    if self._elapsedTime < self._delay then
        if self._started then
            self._elapsedTime = self._delay
        end
        return
    end

    self:Update()
end

---@param complete boolean @defalut: false
function GTweener:Kill(complete)
    if self._killed then
        return
    end

    if complete then
        if self._ended == 0 then
            if self._breakpoint >= 0 then
                self._elapsedTime = self._delay + self._breakpoint
            elseif self._repeat >= 0 then
                self._elapsedTime = self._delay + self._duration * (self._repeat + 1)
            else
                self._elapsedTime = self._delay + self._duration * 2
            end
            self:Update()
        end
        self:CallCompleteCallback()
    end

    self._killed = true
end

---@param start number|Love2DEngine.Vector2|Love2DEngine.Vector3|Love2DEngine.Vector4|Love2DEngine.Color
---@param End number|Love2DEngine.Vector2|Love2DEngine.Vector3|Love2DEngine.Vector4|Love2DEngine.Color
---@param Delegate number
---@return FairyGUI.GTweener
function GTweener:_To(start, End, duration)
    if Class.isa(start, Vector2) then
        self._valueSize = 2
        self._startValue.vec2:Assign(start)
        self._endValue.vec2:Assign(End)
    elseif Class.isa(start, Vector3) then
        self._valueSize = 3
        self._startValue.vec3:Assign(start)
        self._endValue.vec3:Assign(End)
    elseif Class.isa(start, Vector4) then
        self._valueSize = 4
        self._startValue.vec4:Assign(start)
        self._endValue.vec4:Assign(End)
    elseif Class.isa(start, Color) then
        self._valueSize = 4
        self._startValue.color:Assign(start)
        self._endValue.color:Assign(End)
    else
        self._valueSize = 1
        self._startValue.x = start
        self._endValue.x = End
    end
    self._duration = duration
    return self
end

---@param start Love2DEngine.Vector3
---@param amplitude number
---@param Delegate number
---@return FairyGUI.GTweener
function GTweener:_Shake(start, amplitude, duration)
    self._valueSize = 6
    self._startValue.vec3:Assign(start)
    self._startValue.w = amplitude
    self._duration = duration
    self._easeType = EaseType.Linear
    return self
end

function GTweener:_Init()
    self._delay = 0
    self._duration = 0
    self._breakpoint = -1
    self._easeType = EaseType.QuadOut
    self._timeScale = 1
    self._easePeriod = 0
    self._easeOvershootOrAmplitude = 1.70158
    self._snapping = false
    self._repeat = 0
    self._yoyo = false
    self._valueSize = 0
    self._started = false
    self._paused = false
    self._killed = false
    self._elapsedTime = 0
    self._normalizedTime = 0
    self._ended = 0
end

function GTweener:_Reset()
    self._target = nil
    self._listener = nil
    self._userData = nil
    self._onStart , self._onUpdate , self._onComplete = nil, nil, nil
    self._onStart1 , self._onUpdate1 , self._onComplete1 = nil, nil, nil
end

function GTweener:_Update()
    if self._ended ~= 0 then
        self:CallCompleteCallback()
        self._killed = true
        return
    end

    local dt = 0
    if self._ignoreEngineTimeScale then
        dt = Time.unscaledDeltaTime
    else
        dt = Time.deltaTime
    end

    if self._timeScale ~= 1 then
        dt = dt * self._timeScale
    end
    if dt == 0 then
        return
    end

    self._elapsedTime = self._elapsedTime + dt
    self:Update()

    if self._ended ~= 0 then
        if not self._killed then
            self:CallCompleteCallback()
            self._killed = true
        end
    end
end

function GTweener:Update()
    self._ended = 0

    if self._valueSize == 0 then -- DelayedCall
        if self._elapsedTime >= self._delay + self._duration then
            self._ended = 1
            return
        end
    end

    if not self._started then
        if self._elapsedTime < self._delay then
            return
        end

        self._started = true
        self:CallStartCallback()
        if self._killed then
            return
        end
    end

    local reversed = false
    local tt = self._elapsedTime - self._delay
    if self._breakpoint >= 0 and tt >= self._breakpoint then
        tt = self._breakpoint
        self._ended = 2
    end

    if self._repeat ~= 0 then
        local round = math.floor(tt / self._duration)
        tt = tt - self._duration * round
        if self._yoyo then
            reversed = round % 2 == 1
        end

        if self._repeat > 0 and self._repeat - round < 0 then
            if self._yoyo then
                reversed = self._repeat % 2 == 1
            end
            tt = self._duration
            self._ended = 1
        end
    elseif tt >= self._duration then
        tt = self._duration
        self._ended = 1
    end

    self._normalizedTime = EaseManager.Evaluate(self._easeType, reversed and (self._duration - tt) or tt, self._duration,
        self._easeOvershootOrAmplitude, self._easePeriod)
    self._value:SetZero()
    self._deltaValue:SetZero()

    if self._valueSize == 5 then
        local d = self._startValue.d + (self._endValue.d - self._startValue.d) * self._normalizedTime
        if self._snapping then
            d = math.round(d)
        end
        self.deltaValue.d = self.value.d
        self._value.d = d
    elseif self._valueSize == 6 then
        if self._ended == 0 then
            local r = Random.insideUnitSphere
            r.x = r.x > 0 and 1 or -1
            r.y = r.y > 0 and 1 or -1
            r.z = r.z > 0 and 1 or -1
            r = r * self._startValue.w * (1 - self.normalizedTime)

            self._deltaValue.vec3 = r
            self._value.vec3 = self._startValue.vec3 + r
        else
            self._value.vec3 = self._startValue.vec3:Clone()
        end
    else
        for i = 1, self._valueSize do
            local n1 = self._startValue[i]
            local n2 = self._endValue[i]
            local f = n1 + (n2 - n1) * self._normalizedTime
            if self._snapping then
                f = math.round(f)
            end
            self._deltaValue[i] = f - self._value[i]
            self._value[i] = f
        end
    end

    if self._target ~= nil and self._propType ~= TweenPropType.None then
        TweenPropTypeUtils.SetProps(self._target, self._propType, self._value)
    end

    self:CallUpdateCallback()
end

function GTweener:CallStartCallback()
    local oldTraceback
    if GTween.catchCallbackExceptions then
        oldTraceback = Debug.traceback
        Debug.traceback = function(msg) Debug.LogWarn("FairyGUI: error in start callback > " + msg) end
    end

    if self._onStart1 ~= nil then
        self._onStart1(self)
    end
    if self._onStart ~= nil then
        self._onStart()
    end
    if self._listener ~= nil then
        self._listener:OnTweenStart(self)
    end

    if GTween.catchCallbackExceptions then
        Debug.traceback = oldTraceback
    end
end

function GTweener:CallUpdateCallback()
    local oldTraceback
    if GTween.catchCallbackExceptions then
        oldTraceback = Debug.traceback
        Debug.traceback = function(msg) Debug.LogWarn("FairyGUI: error in update callback > " + msg) end
    end

    if self._onUpdate1 ~= nil then
        self._onUpdate1(self)
    end
    if self._onUpdate ~= nil then
        self._onUpdate()
    end
    if self._listener ~= nil then
        self._listener:OnTweenUpdate(self)
    end

    if GTween.catchCallbackExceptions then
        Debug.traceback = oldTraceback
    end
end

function GTweener:CallCompleteCallback()
    local oldTraceback
    if GTween.catchCallbackExceptions then
        oldTraceback = Debug.traceback
        Debug.traceback = function(msg) Debug.LogWarn("FairyGUI: error in complete callback > " + msg) end
    end

    if self._onComplete1 ~= nil then
        self._onComplete1(self)
    end
    if self._onComplete ~= nil then
        self._onComplete()
    end
    if self._listener ~= nil then
        self._listener:OnTweenComplete(self)
    end

    if GTween.catchCallbackExceptions then
        Debug.traceback = oldTraceback
    end
end
--endregion

--region 属性访问器

local __get = Class.init_get(GTweener, true)

---@param self FairyGUI.GTweener
__get.delay = function(self) return self._delay end

---@param self FairyGUI.GTweener
__get.duration = function(self) return self._duration end

---@param self FairyGUI.GTweener
__get.Repeat = function(self) return self._repeat end

---@param self FairyGUI.GTweener
__get.target = function(self) return self._target end

---@param self FairyGUI.GTweener
__get.userData = function(self) return self._userData end

---@param self FairyGUI.GTweener
__get.startValue = function(self) return self._startValue end

---@param self FairyGUI.GTweener
__get.endValue = function(self) return self._endValue end

---@param self FairyGUI.GTweener
__get.value = function(self) return self._value end

---@param self FairyGUI.GTweener
__get.deltaValue = function(self) return self._deltaValue end

---@param self FairyGUI.GTweener
__get.normalizedTime = function(self) return self._normalizedTime end

---@param self FairyGUI.GTweener
__get.completed = function(self) return self._ended ~= 0 end

---@param self FairyGUI.GTweener
__get.allCompleted = function(self) return self._ended == 1 end

--endregion

FairyGUI.GTweenCallback = GTweenCallback
FairyGUI.GTweenCallback1 = GTweenCallback1
FairyGUI.ITweenListener = ITweenListener
FairyGUI.GTweener = GTweener
return GTweener