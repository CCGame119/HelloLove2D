--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:52
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

--region using section
local Vector2 = Love2DEngine.Vector2
local Vector4 = Love2DEngine.Vector4
local Color = Love2DEngine.Color

local ITweenListener = FairyGUI.ITweenListener
local GTweenCallback = FairyGUI.GTweenCallback
local GTweenCallback1 = FairyGUI.GTweenCallback1
local TransitionActionType = FairyGUI.TransitionActionType
local GTween = FairyGUI.GTween
local EaseType = FairyGUI.EaseType
--endregion

---@class FairyGUI.PlayCompleteCallback:Delegate @fun()
local PlayCompleteCallback = Delegate.newDelegate('PlayCompleteCallback')
---@class FairyGUI.TransitionHook:Delegate @fun()
local TransitionHook = Delegate.newDelegate('TransitionHook')

--region Transition Definition
---@class FairyGUI.Transition:FairyGUI.ITweenListener
---@field public name string @动效的名称。在编辑器里设定。
---@field public invalidateBatchingEveryFrame boolean @ 当你启动了自动合批，动效里有涉及到XY、大小、旋转等的改变，如果你观察到元件的显示深度在播放过程中有错误，可以开启这个选项。
---@field private _owner FairyGUI.GComponent
---@field private _items FairyGUI.TransitionItem[]
---@field private _totalTimes number
---@field private _totalTasks number
---@field private _playing boolean
---@field private _paused boolean
---@field private _ownerBaseX number
---@field private _ownerBaseY number
---@field private _onComplete FairyGUI.PlayCompleteCallback
---@field private _options number
---@field private _reversed boolean
---@field private _totalDuration number
---@field private _autoPlay boolean
---@field private _autoPlayTimes number
---@field private _autoPlayDelay number
---@field private _timeScale number
---@field private _ignoreEngineTimeScale boolean
---@field private _startTime number
---@field private _endTime number
---@field private _delayedCallDelegate FairyGUI.GTweenCallback
---@field private _delayedCallDelegate2 FairyGUI.GTweenCallback1
---@field private OPTION_IGNORE_DISPLAY_CONTROLLER number @const = 1
---@field private OPTION_AUTO_STOP_DISABLED number @const = 2
---@field private OPTION_AUTO_STOP_AT_END number @const = 4
local Transition = Class.inheritsFrom('Transition',
{OPTION_IGNORE_DISPLAY_CONTROLLER = 1,
    OPTION_AUTO_STOP_DISABLED = 2,
    OPTION_AUTO_STOP_AT_END = 4,},
    ITweenListener)
--endregion

--region Transition Declaration

---@param owner FairyGUI.GComponent
function Transition:__ctor(owner)
    self._owner = owner
    self._timeScale = 1
    self._ignoreEngineTimeScale = true

    self._delayedCallDelegate = GTweenCallback.new(self.OnDelayedPlay, self)
    self._delayedCallDelegate2 = GTweenCallback1.new(self.OnDelayedPlayItem, self)
end

---@param times number|FairyGUI.PlayCompleteCallback|nil
---@param delay number|nil
---@param startTime number|FairyGUI.PlayCompleteCallback|nil
---@param endTime number|nil
---@param onComplete FairyGUI.PlayCompleteCallback|nil
function Transition:Play(times, delay, startTime, endTime, onComplete)
    if nil ~= endTime then
        self:_Play(times, delay, startTime, endTime, onComplete, false)
        return
    end
    if Class.isa(startTime, FairyGUI.PlayCompleteCallback) or (nil == startTime and nil ~= delay) then
        onComplete = startTime
        self:_Play(times, delay, 0, -1, onComplete, false)
        return
    end
    if nil == times or Class.isa(times, FairyGUI.PlayCompleteCallback) then
        onComplete = times
        self:_Play(1, 0, 0, -1, onComplete, false)
    end
end

---@param times number|FairyGUI.PlayCompleteCallback|nil
---@param delay number|nil
---@param onComplete FairyGUI.PlayCompleteCallback|nil
function Transition:PlayReverse(times, delay, onComplete)
    if nil ~= delay then
        self:_Play(times, delay, 0, -1, onComplete, true)
        return
    end
    if nil == times or Class.isa(times, FairyGUI.PlayCompleteCallback) then
        onComplete = times
        self:_Play(1, 0, 0, -1, onComplete, true)
    end
end

---@param value number
function Transition:ChangePlayTimes(value)
    self._totalTimes = value
end

---@param autoPlay boolean
---@param times number
---@param delay number
function Transition:SetAutoPlay(autoPlay, times, delay)
    if (self._autoPlay ~= autoPlay) then
        self._autoPlay = autoPlay
        self._autoPlayTimes = times
        self._autoPlayDelay = delay
        if (self._autoPlay) then
            if (self._owner.onStage) then
                self:Play(times, delay, nil)
            end
        else
            if (not self._owner.onStage) then
                self:Stop(false, true)
            end
        end
    end
end

---@param times number
---@param delay number
---@param startTime number
---@param endTime number
---@param onComplete FairyGUI.PlayCompleteCallback|nil
---@param reverse boolean
function Transition:_Play(times, delay, startTime, endTime, onComplete, reverse)
    self:Stop(true, true)

    self._totalTimes = times
    self._reversed = reverse
    self._startTime = startTime
    self._endTime = endTime
    self._playing = true
    self._paused = false
    self._onComplete = onComplete

    for i, item in ipairs(self._items) do
        if (item.target == nil) then
            if (item.targetId:len() > 0) then
                item.target = self._owner:GetChildById(item.targetId)
            else
                item.target = self._owner
            end
        elseif (item.target ~= self._owner and item.target.parent ~= self._owner) then --maybe removed
            item.target = nil
        end

        if (item.target ~= nil and item.type == TransitionActionType.Transition) then
            local value = item.value
            local trans = item.target:GetTransition(value.transName)
            if (trans == self) then
                trans = nil
            end
            if (trans ~= nil) then
                if (value.playTimes == 0) then  --stop
                    local index = 0
                    for j = i - 1, 1 -1 do
                        index = j
                        local item2 = self._items[j]
                        if (item2.type == TransitionActionType.Transition) then
                            local value2 = item2.value
                            if (value2.trans == trans) then
                                value2.stopTime = item.time - item2.time
                                break
                            end
                        end
                    end
                    if (index < 0) then
                        value.stopTime = 0
                    else
                        trans = nil  --no need to handle stop anymore
                    end
                else
                    value.stopTime = -1
                end
            end
            value.trans = trans
        end
    end

    if (delay == 0) then
        self:OnDelayedPlay()
    else
        GTween.DelayedCall(delay):SetTarget(self):OnComplete(self._delayedCallDelegate)
    end
end

---@param setToComplete boolean @default: true
---@param processCallback boolean @default: false
function Transition:Stop(setToComplete, processCallback)
    if (not self._playing) then
        return
    end

    self._playing = false
    self._totalTasks = 0
    self._totalTimes = 0
    local func = self._onComplete
    self._onComplete = nil

    GTween.Kill(self) --delay start

    local cnt = #self._items
    if (self._reversed) then
        for i = cnt, 1 -1 do
            local item = self._items[i]
            if (item.target ~= nil) then
                self:StopItem(item, setToComplete)
            end
        end
    else
        for _, item in ipairs(self._items) do
            if (item.target ~= nil) then
                self:StopItem(item, setToComplete)
            end
        end
    end

    if (processCallback and func ~= nil) then
        func()
    end
end

---@param item FairyGUI.TransitionItem
---@param setToComplete boolean
function Transition:StopItem(item, setToComplete)

end

--TODO: FairyGUI.Transition

--endregion

--region TValueN class
---@class FairyGUI.TValue_Visible:ClassType
---@field public visible boolean
local TValue_Visible = Class.inheritsFrom('TValue_Visible')

---@class FairyGUI.TValue_Animation:ClassType
---@field public frame number
---@field public playing boolean
---@field public flag boolean
local TValue_Animation = Class.inheritsFrom('TValue_Animation')

---@class FairyGUI.TValue_Sound:ClassType
---@field public sound string
---@field public volume number
---@field public audioClip FairyGUI.NAudioClip
local TValue_Sound = Class.inheritsFrom('TValue_Sound')

---@class FairyGUI.TValue_Transition:ClassType
---@field public transName string
---@field public playTimes number
---@field public trans FairyGUI.Transition
---@field public playCompleteDelegate FairyGUI.PlayCompleteCallback
---@field public stopTime number
local TValue_Transition = Class.inheritsFrom('TValue_Transition')

---@class FairyGUI.TValue_Shake:ClassType
---@field public amplitude number
---@field public duration number
---@field public lastOffset Love2DEngine.Vector2
---@field public offset Love2DEngine.Vector2
local TValue_Shake = Class.inheritsFrom('TValue_Shake')

---@class FairyGUI.TValue_Text:ClassType
---@field public text string
local TValue_Text = Class.inheritsFrom('TValue_Text')

---@class FairyGUI.TValue:ClassType
---@field public f1 number
---@field public f2 number
---@field public f3 number
---@field public f4 number
---@field public b1 boolean
---@field public b2 boolean
local TValue = Class.inheritsFrom('TValue')

function TValue:__ctor()
    self.b1 = true
    self.b2 = true
end

---@param source FairyGUI.TValue
function TValue:Copy(source)
    self.f1 = source.f1
    self.f2 = source.f2
    self.f3 = source.f3
    self.f4 = source.f4
    self.b1 = source.b1
    self.b2 = source.b2
end

local TValue__get = Class.init_get(TValue)
local TValue__set = Class.init_set(TValue)

---@param self FairyGUI.TValue
TValue__get.vec2 = function(self) return Vector2(self.f1, self.f2) end

---@param self FairyGUI.TValue
---@param val Love2DEngine.Vector2
TValue__set.vec2 = function(self, val)
    self.f1, self.f2 = val.x, val.y
end

---@param self FairyGUI.TValue
TValue__get.vec4 = function(self) return Vector4(self.f1, self.f2, self.f3, self.f4) end

---@param self FairyGUI.TValue
---@param val Love2DEngine.Vector4
TValue__set.vec4 = function(self, val)
    self.f1, self.f2, self.f3, self.f4 = val.x, val.y, val.z, val.w
end

---@param self FairyGUI.TValue
TValue__get.color = function(self) return Color(self.f1, self.f2, self.f3, self.f4) end

---@param self FairyGUI.TValue
---@param val Love2DEngine.Color
TValue__set.color = function(self, val)
    self.f1, self.f2, self.f3, self.f4 = val.r, val.g, val.b, val.a
end
--endregion

--region TransitionItem
---@class FairyGUI.TransitionItem:ClassType
---@field public time number
---@field public targetId string
---@field public type FairyGUI.TransitionActionType
---@field public tweenConfig FairyGUI.TweenConfig
---@field public label string
---@field public value any
---@field public hook FairyGUI.TransitionHook
---@field public tweener FairyGUI.GTweener
---@field public target FairyGUI.GObject
---@field public displayLockToken number
local TransitionItem = Class.inheritsFrom('TransitionItem')

---@param type FairyGUI.TransitionActionType
function TransitionItem:__ctor(type)
    self.type = type

    if type == TransitionActionType.XY or
            type == TransitionActionType.Size or
            type == TransitionActionType.Scale or
            type == TransitionActionType.Pivot or
            type == TransitionActionType.Skew or
            type == TransitionActionType.Alpha or
            type == TransitionActionType.Rotation or
            type == TransitionActionType.Color or
            type == TransitionActionType.ColorFilter then
        self.value = TValue.new()
    elseif type == TransitionActionType.Animation then
        self.value = TValue_Animation.new()
    elseif type == TransitionActionType.Shake then
        self.value = TValue_Shake.new()
    elseif type == TransitionActionType.Sound then
        self.value = TValue_Sound.new()
    elseif type == TransitionActionType.Transition then
        self.value = TValue_Transition.new()
    elseif type == TransitionActionType.Visible then
        self.value = TValue_Visible.new()
    elseif type == TransitionActionType.Text or
            type == TransitionActionType.Icon then
        self.value = TValue_Text.new()
    end
end
--endregion

--region TweenConfig
---@class FairyGUI.TweenConfig:ClassType
---@field public duration number
---@field public easeType FairyGUI.EaseType
---@field public Repeat number
---@field public yoyo boolean---
---@field public startValue FairyGUI.TValue
---@field public endValue FairyGUI.TValue
---@field public endLabel string
---@field public endHook FairyGUI.TransitionHook
local TweenConfig = Class.inheritsFrom('TweenConfig')

function TweenConfig:__ctor()
    self.easeType = EaseType.QuadOut
    self.startValue = TValue.new()
    self.endValue = TValue.new()
end
--endregion


FairyGUI.PlayCompleteCallback = PlayCompleteCallback
FairyGUI.TransitionHook = TransitionHook
FairyGUI.TValue_Visible = TValue_Visible
FairyGUI.TValue_Animation = TValue_Animation
FairyGUI.TValue_Sound = TValue_Sound
FairyGUI.TValue_Transition = TValue_Transition
FairyGUI.TValue_Shake = TValue_Shake
FairyGUI.TValue_Text = TValue_Text
FairyGUI.TValue = TValue
FairyGUI.TransitionItem = TransitionItem
FairyGUI.TweenConfig = TweenConfig
FairyGUI.Transition = Transition
return Transition