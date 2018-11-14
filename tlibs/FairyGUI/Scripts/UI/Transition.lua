--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:52
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')
local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

--region using section
local Vector2 = Love2DEngine.Vector2
local Vector3 = Love2DEngine.Vector3
local Vector4 = Love2DEngine.Vector4
local Color = Love2DEngine.Color

local ITweenListener = FairyGUI.ITweenListener
local GTweenCallback = FairyGUI.GTweenCallback
local GTweenCallback1 = FairyGUI.GTweenCallback1
local TransitionActionType = FairyGUI.TransitionActionType
local GTween = FairyGUI.GTween
local EaseType = FairyGUI.EaseType
local UIConfig = FairyGUI.UIConfig
local UIPackage = FairyGUI.UIPackage
local ColorFilter = FairyGUI.ColorFilter
local Stage = FairyGUI.Stage
--endregion

---@class FairyGUI.PlayCompleteCallback:Delegate @fun()
local PlayCompleteCallback = Delegate.newDelegate('PlayCompleteCallback')
---@class FairyGUI.TransitionHook:Delegate @fun()
local TransitionHook = Delegate.newDelegate('TransitionHook')

--region Transition Definition
---@class FairyGUI.Transition:FairyGUI.ITweenListener
---@field public name string @动效的名称。在编辑器里设定。
---@field public invalidateBatchingEveryFrame boolean @ 当你启动了自动合批，动效里有涉及到XY、大小、旋转等的改变，如果你观察到元件的显示深度在播放过程中有错误，可以开启这个选项。
---@field public playing boolean
---@field public timeScale number
---@field public ignoreEngineTimeScale boolean
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
    if (item.displayLockToken ~= 0) then
        item.target:ReleaseDisplayLock(item.displayLockToken)
        item.displayLockToken = 0
    end

    if (item.tweener ~= nil) then
        item.tweener:Kill(setToComplete)
        item.tweener = nil

        if (item.type == TransitionActionType.Shake and not setToComplete) then --震动必须归位，否则下次就越震越远了。	{
            item.target._gearLocked = true
            ---@type FairyGUI.TValue_Shake
            local value = item.value
            item.target:SetXY(item.target.x - value.lastOffset.x, item.target.y - value.lastOffset.y)
            item.target._gearLocked = false

            self._owner:InvalidateBatchingState(true)
        end
    end

    if (item.type == TransitionActionType.Transition) then
        ---@type FairyGUI.TValue_Transition
        local value = item.value
        if (value.trans ~= nil) then
            value.trans:Stop(setToComplete, false)
        end
    end
end

---@param paused boolean
function Transition:SetPaused(paused)
    if (not self._playing or self._paused == paused) then
        return
    end

    self._paused = paused
    local tweener = GTween.GetTween(self)
    if (tweener ~= nil) then
        tweener:SetPaused(paused)
    end

    for _, item in ipairs(self._items) do
        if (item.target ~= nil) then
            if (item.type == TransitionActionType.Transition) then
                if (item.value.trans ~= nil) then
                    item.value.trans:SetPaused(paused)
                end
            elseif (item.type == TransitionActionType.Animation) then
                if (paused) then
                    item.value.flag = item.target.playing
                    item.target.playing = false
                else
                    item.target.playing = item.value.flag
                end
            end

            if (item.tweener ~= nil) then
                item.tweener:SetPaused(paused)
            end
        end
    end
end

function Transition:Dispose()
    if (self._playing) then
        GTween.Kill(self) --delay start
    end


    for _, item in ipairs(self._items) do
        if (item.tweener ~= nil) then
            item.tweener:Kill()
            item.tweener = nil
        end

        item.target = nil
        item.hook = nil
        if (item.tweenConfig ~= nil) then
            item.tweenConfig.endHook = nil
        end
    end

    self._playing = false
    self._onComplete = nil
end

---@param label string
---@param aParams args
function Transition:SetValue(label, ...)
    local aParams = {...}
    ---@type FairyGUI.TValue|FairyGUI.TValue_Animation|FairyGUI.TValue_Shake|FairyGUI.TValue_Text|FairyGUI.TValue_Sound
    local value
    for _, item in ipairs(self._items) do
        local continue = false
        if (item.label == label) then
            if (item.tweenConfig ~= nil) then
                value = item.tweenConfig.startValue
            else
                value = item.value
            end
        elseif (item.tweenConfig ~= nil and item.tweenConfig.endLabel == label) then
            value = item.tweenConfig.endValue
        else
            continue = true
        end
        local type = item.type
        if not continue then
            if type == TransitionActionType.XY or
                    type == TransitionActionType.Size or
                    type == TransitionActionType.Pivot or
                    type == TransitionActionType.Scale or
                    type == TransitionActionType.Skew then
                ---@type FairyGUI.TValue
                local tvalue = value
                tvalue.b1 = true
                tvalue.b2 = true
                tvalue.f1 = aParams[1]
                tvalue.f2 = aParams[2]
            elseif type == TransitionActionType.Alpha then
                ---@type FairyGUI.TValue
                value.f1 = aParams[1]
            elseif type == TransitionActionType.Rotation then
                ---@type FairyGUI.TValue
                value.f1 = aParams[1]
            elseif type == TransitionActionType.Color then
                ---@type FairyGUI.TValue
                value.color = aParams[1]
            elseif type == TransitionActionType.Animation then
                ---@type FairyGUI.TValue_Animation
                local tvalue = value
                tvalue.frame = aParams[1]
                if (#aParams > 1) then
                    tvalue.playing = aParams[2]
                end
            elseif type == TransitionActionType.Visible then
                ---@type FairyGUI.TValue_Visible
                value.visible = aParams[1]
            elseif type == TransitionActionType.Sound then
                ---@type FairyGUI.TValue_Sound
                local tvalue = value
                tvalue.sound = aParams[1]
                if (#aParams > 1) then
                    tvalue.volume = aParams[2]
                end
            elseif type == TransitionActionType.Transition then
                ---@type FairyGUI.TValue_Transition
                local tvalue = value
                tvalue.transName = aParams[1]
                if (#aParams > 1) then
                    tvalue.playTimes = aParams[2]
                end
            elseif type == TransitionActionType.Shake then
                ---@type FairyGUI.TValue_Shake
                value.amplitude = aParams[1]
                if (#aParams > 1) then
                    value.duration = aParams[2]
                end
            elseif type == TransitionActionType.ColorFilter then
                ---@type FairyGUI.TValue
                local tvalue = value
                tvalue.f1 = aParams[1]
                tvalue.f2 = aParams[2]
                tvalue.f3 = aParams[3]
                tvalue.f4 = aParams[4]
            elseif type == TransitionActionType.Text or
                    type == TransitionActionType.Icon then
                ---@type FairyGUI.TValue_Text
                value.text = aParams[1]
            end
        end
    end
end

---@param label string
---@param callback FairyGUI.TransitionHook
function Transition:SetHook(label, callback)
    for _, item in ipairs(self._items) do
        if item.label == label then
            item.hook = callback
            break
        end
        if item.tweenConfig ~= nil and item.tweenConfig.endLabel == label then
            item.tweenConfig.endHook = callback
            break
        end
    end
end

function Transition:ClearHooks()
    for _, item in ipairs(self._items) do
        item.hook = nil
        if item.tweenConfig ~= nil then
            item.tweenConfig.endHook = nil
        end
    end
end

---@param label string
---@param newTarget FairyGUI.GObject
function Transition:SetTarget(label, newTarget)
    for _, item in ipairs(self._items) do
        if item.label == label then
            item.targetId = newTarget.id
            item.target = nil
        end
    end
end

---@param label string
---@param value number
function Transition:SetDuration(label, value)
    for _, item in ipairs(self._items) do
        if item.tweenConfig ~= nil and item.label == label then
            item.tweenConfig.duration = value
        end
    end
end

---@param label string
---@return number
function Transition:GetLabelTime(label)
    for _, item in ipairs(self._items) do
        if item.label == label then
            return item.time
        elseif item.tweenConfig ~= nil and item.tweenConfig.endLabel == label then
            return item.time + item.tweenConfig.duration
        end
    end

    return math.nan
end

---@param targetId string
---@param dx number
---@param dy number
function Transition:UpdateFromRelations(targetId, dx, dy)
    if #self._items == 0 then
        return
    end

    for _, item in ipairs(self._items) do
        if item.label == TransitionActionType.XY and item.targetId == targetId then
            if item.tweenConfig ~= nil then
                item.tweenConfig.startValue.f1 = item.tweenConfig.startValue.f1 + dx
                item.tweenConfig.startValue.f2 = item.tweenConfig.startValue.f2 + dy
                item.tweenConfig.endValue.f1 = item.tweenConfig.endValue.f1 + dx
                item.tweenConfig.endValue.f2 = item.tweenConfig.endValue.f2 + dy
            else
                item.value.f1 = item.value.f1 + dx
                item.value.f2 = item.value.f2 + dy
            end
        end
    end
end

function Transition:OnOwnerAddedToStage()
    if self._autoPlay and not self._playing then
        self:Play(self._autoPlayTimes, self._autoPlayDelay, nil)
    end
end

function Transition:OnOwnerRemovedFromStage()
    if band(self._options, self.OPTION_AUTO_STOP_DISABLED) == 0  then
        self:Stop(band(self._options, self.OPTION_AUTO_STOP_AT_END) ~= 0 and true or false, false)
    end
end

function Transition:OnDelayedPlay()
    self:InternalPlay()

    if self._playing then
        if band(self._options, self.OPTION_IGNORE_DISPLAY_CONTROLLER) ~= 0 then
            for _, item in ipairs(self._items) do
                if item.target ~= nil and item.target ~= self._owner then
                    item.displayLockToken = item.target:AddDisplayLock()
                end
            end
        end
    elseif self._onComplete ~= nil then
        local func = self._onComplete
        self._onComplete = nil
        func()
    end
end

function Transition:InternalPlay()
    self._ownerBaseX = self._owner.x
    self._ownerBaseY = self._owner.y

    self._totalTasks = 0

    local needSkipAnimations = false

    if (not self._reversed) then
        for _, item in ipairs(self._items) do
            if item.target ~= nil then
                if item.type == TransitionActionType.Animation and self._startTime ~= 0 and item.time <= self._startTime then
                    needSkipAnimations = true
                    item.value.flag = false
                else
                    self:PlayItem(item)
                end
            end
        end
    else
        for i = #self._items, 1, -1 do
            local item = self._items[i]
            if item.target ~= nil then
                self:PlayItem(item)
            end
        end
    end

    if needSkipAnimations then
        self:SkipAnimations()
    end
end

---@param item FairyGUI.TransitionItem
function Transition:PlayItem(item)
    local time
    if (item.tweenConfig ~= nil) then
        if (self._reversed) then
            time = (self._totalDuration - item.time - item.tweenConfig.duration)
        else
            time = item.time
        end

        if (self._endTime == -1 or time <= self._endTime) then
            ---@type FairyGUI.TValue
            local startValue, endValue

            if (self._reversed) then
                startValue = item.tweenConfig.endValue
                endValue = item.tweenConfig.startValue
            else
                startValue = item.tweenConfig.startValue
                endValue = item.tweenConfig.endValue
            end

            item.value.b1 = startValue.b1 or endValue.b1
            item.value.b2 = startValue.b2 or endValue.b2
            local type = item.type
            if type == TransitionActionType.XY or
                    type ==  TransitionActionType.Size or
                    type ==  TransitionActionType.Scale or
                    type ==  TransitionActionType.Skew then
                item.tweener = GTween.To(startValue.vec2, endValue.vec2, item.tweenConfig.duration)
            elseif type == TransitionActionType.Alpha or
                    type ==  TransitionActionType.Rotation then
                item.tweener = GTween.To(startValue.f1, endValue.f1, item.tweenConfig.duration)
            elseif type == TransitionActionType.Color then
                item.tweener = GTween.To(startValue.color, endValue.color, item.tweenConfig.duration)
            elseif type == TransitionActionType.ColorFilter then
                item.tweener = GTween.To(startValue.vec4, endValue.vec4, item.tweenConfig.duration)
            end

            item.tweener:SetDelay(time)
                :SetEase(item.tweenConfig.easeType)
                :SetRepeat(item.tweenConfig.Repeat, item.tweenConfig.yoyo)
                :SetTimeScale(self._timeScale)
                :SetIgnoreEngineTimeScale(self._ignoreEngineTimeScale)
                :SetTarget(item)
                :SetListener(self)

            if (self._endTime >= 0) then
                item.tweener:SetBreakpoint(self._endTime - time)
            end

            self._totalTasks = self._totalTasks + 1
        end
    elseif (item.type == TransitionActionType.Shake) then
        ---@type FairyGUI.TValue_Shake
        local value = item.value

        if (self._reversed) then
            time = (self._totalDuration - item.time - value.duration)
        else
            time = item.time
        end

        if (self._endTime == -1 or time <= self._endTime) then
            value.lastOffset:Set(0, 0)
            value.offset:Set(0, 0)
            item.tweener = GTween.Shake(Vector3.zero, value.amplitude, value.duration)
                                 :SetDelay(time)
                                 :SetTimeScale(self._timeScale)
                                 :SetIgnoreEngineTimeScale(self._ignoreEngineTimeScale)
                                 :SetTarget(item)
                                 :SetListener(this)

            if (self._endTime >= 0) then
                item.tweener:SetBreakpoint(self._endTime - item.time)
            end

            self._totalTasks  = self._totalTasks + 1
        end
    else
        if (self._reversed) then
            time = (self._totalDuration - item.time)
        else
            time = item.time
        end

        if (time <= self._startTime) then
            self:ApplyValue(item)
            self:CallHook(item, false)
        elseif (self._endTime == -1 or time <= self._endTime) then
            self._totalTasks = self._totalTasks + 1
            item.tweener = GTween.DelayedCall(time)
                                 :SetTimeScale(self._timeScale)
                                 :SetIgnoreEngineTimeScale(self._ignoreEngineTimeScale)
                                 :SetTarget(item)
                                 :OnComplete(self._delayedCallDelegate2)
        end
    end

    if (item.tweener ~= nil) then
        item.tweener:Seek(self._startTime)
    end
end

function Transition:SkipAnimations()
    local frame = 0
    local playStartTime = 0
    local playTotalTime = 0
    ---@type FairyGUI.TValue_Animation
    local value
    ---@type FairyGUI.IAnimationGear
    local target
    ---@type FairyGUI.TransitionItem
    local item

    local cnt = #self._items
    for i = 1, cnt do
        item = self._items[i]
        if (item.type ~= TransitionActionType.Animation or item.time > self._startTime) then
            --continue
        else
            value = item.value
            if (value.flag) then
                --continue
            else
                target = item.target
                frame = target.frame
                playStartTime = target.playing and 0 or -1
                playTotalTime = 0

                for j = i, cnt do
                    item = self._items[j]
                    if (item.type ~= TransitionActionType.Animation or item.target ~= target or item.time > self._startTime) then
                        --continue
                    else
                        value = item.value
                        value.flag = true

                        if (value.frame ~= -1) then
                            frame = value.frame
                            if (value.playing) then
                                playStartTime = item.time
                            else
                                playStartTime = -1
                            end
                            playTotalTime = 0
                        else
                            if (value.playing) then
                                if (playStartTime < 0) then
                                    playStartTime = item.time
                                end
                            else
                                if (playStartTime >= 0) then
                                    playTotalTime = playTotalTime + (item.time - playStartTime)
                                end
                                playStartTime = -1
                            end
                        end

                        self:CallHook(item, false)
                    end
                end

                if (playStartTime >= 0) then
                    playTotalTime = playTotalTime + (self._startTime - playStartTime)
                end

                target.playing = playStartTime >= 0
                target.frame = frame
                if (playTotalTime > 0) then
                    target:Advance(playTotalTime)
                end
            end
        end
    end
end

---@param tweener FairyGUI.GTweener
function Transition:OnDelayedPlayItem(tweener)
    ---@type FairyGUI.TransitionItem
    local item = tweener.target
    item.tweener = nil
    self._totalTasks = self._totalTasks - 1

    self:ApplyValue(item)
    self:CallHook(item, false)

    self:CheckAllComplete()
end

---@param tweener FairyGUI.GTweener
function Transition:OnTweenStart(tweener)
    ---@type FairyGUI.TransitionItem
    local item = tweener.target

    if (item.type == TransitionActionType.XY or item.type == TransitionActionType.Size) then  --位置和大小要到start才最终确认起始值
        ---@type FairyGUI.TValue
        local startValue, endValue

        if (self._reversed) then
            startValue = item.tweenConfig.endValue
            endValue = item.tweenConfig.startValue
        else
            startValue = item.tweenConfig.startValue
            endValue = item.tweenConfig.endValue
        end

        if (item.type == TransitionActionType.XY) then
            if (item.target ~= self._owner) then
                if (not startValue.b1) then
                    startValue.f1 = item.target.x
                end
                if (not startValue.b2) then
                    startValue.f2 = item.target.y
                end
            else
                if (not startValue.b1) then
                    startValue.f1 = item.target.x - self._ownerBaseX
                end
                if (not startValue.b2) then
                    startValue.f2 = item.target.y - self._ownerBaseY
                end
            end
        else
            if (not startValue.b1) then
                startValue.f1 = item.target.width
            end
            if (not startValue.b2) then
                startValue.f2 = item.target.height
            end
        end

        if (not endValue.b1) then
            endValue.f1 = startValue.f1
        end
        if (not endValue.b2) then
            endValue.f2 = startValue.f2
        end

        tweener.startValue.vec2 = startValue.vec2
        tweener.endValue.vec2 = endValue.vec2
    end

    self:CallHook(item, false)
end

---@param tweener FairyGUI.GTweener
function Transition:OnTweenUpdate(tweener)
    ---@type FairyGUI.TransitionItem
    local item = tweener.target
    local type = item.type
    if type == TransitionActionType.XY or
            type == TransitionActionType.Size or
            type == TransitionActionType.Scale or
            type == TransitionActionType.Skew then
        item.value.vec2 = tweener.value.vec2
    elseif type == TransitionActionType.Alpha or
            type == TransitionActionType.Rotation then
        item.value.f1 = tweener.value.x
    elseif type == TransitionActionType.Color then
        item.value.color = tweener.value.color
    elseif type == TransitionActionType.ColorFilter then
        item.value.vec4 = tweener.value.vec4
    elseif type == TransitionActionType.Shake then
        item.value.offset = tweener.deltaValue.vec2
    end
    self:ApplyValue(item)
end

---@param tweener FairyGUI.GTweener
function Transition:OnTweenComplete(tweener)
    ---@type FairyGUI.TransitionItem
    local item = tweener.target
    item.tweener = nil
    self._totalTasks = self._totalTasks - 1

    if (item.type == TransitionActionType.XY or item.type == TransitionActionType.Size
            or item.type == TransitionActionType.Scale or item.type == TransitionActionType.Shake) then
        self._owner:InvalidateBatchingState(true)
    end

    if (tweener.allCompleted) then  --当整体播放结束时间在这个tween的中间时不应该调用结尾钩子
        self:CallHook(item, true)
    end

    self:CheckAllComplete()
end

---@param item FairyGUI.TransitionItem
function Transition:OnPlayTransCompleted(item)
    self._totalTasks = self._totalTasks - 1
    self:CheckAllComplete()
end

---@param item FairyGUI.TransitionItem
---@param tweenEnd boolean
function Transition:CallHook(item, tweenEnd)
    if tweenEnd then
        if item.tweenConfig ~= nil and item.tweenConfig.endHook ~= nil then
            item.tweenConfig.endHook()
        end
    else
        if item.time >= self._startTime and item.hook ~= nil then
            item.hook()
        end
    end
end

function Transition:CheckAllComplete()
    if (self._playing and self._totalTasks == 0) then
        if (self._totalTimes < 0) then
            self:InternalPlay()
        else
            self._totalTimes = self._totalTimes - 1
            if (self._totalTimes > 0) then
                self:InternalPlay()
            else
                self._playing = false

                for _, item in ipairs(self._items) do
                    if (item.target ~= nil and item.displayLockToken ~= 0) then
                        item.target:ReleaseDisplayLock(item.displayLockToken)
                        item.displayLockToken = 0
                    end
                end

                if (self._onComplete ~= nil) then
                    local func = self._onComplete
                    self._onComplete = nil
                    func()
                end
            end
        end
    end
end

---@param item FairyGUI.TransitionItem
function Transition:ApplyValue(item)
    item.target._gearLocked = true
    local type = item.type
    local _owner = self._owner
    local _ownerBaseX = self._ownerBaseX
    local _ownerBaseY = self._ownerBaseY

    if type == TransitionActionType.XY then
        ---@type FairyGUI.TValue
        local value = item.value
        if (item.target == _owner) then
            local f1, f2
            if (not value.b1) then
                f1 = item.target.x
            else
                f1 = value.f1 + _ownerBaseX
            end
            if (not value.b2) then
                f2 = item.target.y
            else
                f2 = value.f2 + _ownerBaseY
            end
            item.target:SetXY(f1, f2)
        else
            if (not value.b1) then
                value.f1 = item.target.x
            end
            if (not value.b2) then
                value.f2 = item.target.y
            end
            item.target:SetXY(value.f1, value.f2)
        end
        if (self.invalidateBatchingEveryFrame) then
            _owner:InvalidateBatchingState(true)
        end
    elseif type == TransitionActionType.Size then
        ---@type FairyGUI.TValue
        local value = item.value
        if (not value.b1) then
            value.f1 = item.target.width
        end
        if (not value.b2) then
            value.f2 = item.target.height
        end
        item.target:SetSize(value.f1, value.f2)
        if (self.invalidateBatchingEveryFrame) then
            _owner:InvalidateBatchingState(true)
        end
    elseif type == TransitionActionType.Pivot then
        item.target:SetPivot(item.value.f1, item.value.f2, item.target.pivotAsAnchor)
        if (self.invalidateBatchingEveryFrame) then
            _owner:InvalidateBatchingState(true)
        end
    elseif type == TransitionActionType.Alpha then
        item.target.alpha = item.value.f1
    elseif type == TransitionActionType.Rotation then
        item.target.rotation = item.value.f1
        if (self.invalidateBatchingEveryFrame) then
            _owner:InvalidateBatchingState(true)
        end
    elseif type == TransitionActionType.Scale then
        item.target:SetScale(item.value.f1, item.value.f2)
        if (self.invalidateBatchingEveryFrame) then
            _owner:InvalidateBatchingState(true)
        end
    elseif type == TransitionActionType.Skew then
        item.target.skew = item.value.vec2
        if (self.invalidateBatchingEveryFrame) then
            _owner:InvalidateBatchingState(true)
        end
    elseif type == TransitionActionType.Color then
        item.target.color = item.value.color
    elseif type == TransitionActionType.Animation then
        ---@type FairyGUI.TValue_Animation
        local value = item.value
        if (value.frame >= 0) then
            item.target.frame = value.frame
        end
        item.target.playing = value.playing
        item.target.timeScale = self._timeScale
        item.target.ignoreEngineTimeScale = self._ignoreEngineTimeScale
    elseif type == TransitionActionType.Visible then
        item.target.visible = item.value.visible
    elseif type == TransitionActionType.Shake then
        ---@type FairyGUI.TValue_Shake
        local value = item.value
        item.target:SetXY(item.target.x - value.lastOffset.x + value.offset.x, item.target.y - value.lastOffset.y + value.offset.y)
        value.lastOffset = value.offset

        if (self.invalidateBatchingEveryFrame) then
            _owner:InvalidateBatchingState(true)
        end
    elseif type == TransitionActionType.Transition then
        if (self._playing) then
            ---@type FairyGUI.TValue_Transition
            local value = item.value
            if (value.trans ~= nil) then
                self._totalTasks = self._totalTasks + 1

                local startTime = self._startTime > item.time and (self._startTime - item.time) or 0
                local endTime = self._endTime >= 0 and (self._endTime - item.time) or -1
                if (value.stopTime >= 0 and (endTime < 0 or endTime > value.stopTime)) then
                    endTime = value.stopTime
                end
                value.trans.timeScale = self._timeScale
                value.trans.ignoreEngineTimeScale = self._ignoreEngineTimeScale
                value.trans:_Play(value.playTimes, 0, startTime, endTime, value.playCompleteDelegate, self._reversed)
            end
        end
    elseif type == TransitionActionType.Sound then
        if (self._playing and item.time >= self._startTime) then
            ---@type FairyGUI.TValue_Sound
            local value = item.value
            if (value.audioClip == nil) then
                if (UIConfig.soundLoader == nil or value.sound:StartsWith(UIPackage.URL_PREFIX)) then
                    value.audioClip = UIPackage.GetItemAssetByURL(value.sound)
                else
                    value.audioClip = UIConfig.soundLoader(value.sound)
                end
            end

            if (value.audioClip ~= nil and value.audioClip.nativeClip ~= nil) then
                Stage.inst:PlayOneShotSound(value.audioClip.nativeClip, value.volume)
            end
        end
    elseif type == TransitionActionType.ColorFilter then
        ---@type FairyGUI.TValue
        local value = item.value
        ---@type FairyGUI.ColorFilter
        local cf = item.target.filter
        if (cf == nil) then
            cf = ColorFilter.new()
            item.target.filter = cf
        else
            cf:Reset()
        end

        cf:AdjustBrightness(value.f1)
        cf:AdjustContrast(value.f2)
        cf:AdjustSaturation(value.f3)
        cf:AdjustHue(value.f4)
    elseif type == TransitionActionType.Text then
        item.target.text = item.value.text
    elseif type == TransitionActionType.Icon then
        item.target.icon = item.value.text
    end

    item.target._gearLocked = false
end

---@param buffer Utils.ByteBuffer
function Transition:Setup(buffer)
    self.name = buffer:ReadS()
    self._options = buffer:ReadInt()
    self._autoPlay = buffer:ReadBool()
    self._autoPlayTimes = buffer:ReadInt()
    self._autoPlayDelay = buffer:ReadFloat()

    local cnt = buffer:ReadShort()
    self._items = {}
    for i = 1,  cnt do
        local dataLen = buffer:ReadShort()
        local curPos = buffer.position

        buffer:Seek(curPos, 0)

        local item = FairyGUI.TransitionItem.new(buffer:ReadByte())
        self._items[i] = item

        item.time = buffer:ReadFloat()
        local targetId = buffer:ReadShort()
        if (targetId < 0) then
            item.targetId = ''
        else
            item.targetId = self._owner:GetChildAt(targetId).id
        end
        item.label = buffer:ReadS()

        if (buffer:ReadBool()) then
            buffer:Seek(curPos, 1)

            item.tweenConfig = FairyGUI.TweenConfig.new()
            item.tweenConfig.duration = buffer:ReadFloat()
            if (item.time + item.tweenConfig.duration > self._totalDuration) then
                self._totalDuration = item.time + item.tweenConfig.duration
            end
            item.tweenConfig.easeType = buffer:ReadByte()
            item.tweenConfig.Repeat = buffer:ReadInt()
            item.tweenConfig.yoyo = buffer:ReadBool()
            item.tweenConfig.endLabel = buffer:ReadS()

            buffer:Seek(curPos, 2)

            self:DecodeValue(item, buffer, item.tweenConfig.startValue)

            buffer:Seek(curPos, 3)

            self:DecodeValue(item, buffer, item.tweenConfig.endValue)
        else
            if (item.time > self._totalDuration) then
                self._totalDuration = item.time
            end

            buffer:Seek(curPos, 2)

            self:DecodeValue(item, buffer, item.value)
        end

        buffer.position = curPos + dataLen
    end
end

---@param item FairyGUI.TransitionItem
---@param buffer Utils.ByteBuffer
---@param value FairyGUI.TValue_Transition| FairyGUI.TValue|FairyGUI.TValue_Animation|FairyGUI.TValue_Shake|FairyGUI.TValue_Text|FairyGUI.TValue_Sound
function Transition:DecodeValue(item, buffer, value)
    local type = item.type

    if type == TransitionActionType.XY or
            type == TransitionActionType.Size or
            type == TransitionActionType.Pivot or
            type == TransitionActionType.Skew then
        ---@type FairyGUI.TValue
        local tvalue = value
        tvalue.b1 = buffer:ReadBool()
        tvalue.b2 = buffer:ReadBool()
        tvalue.f1 = buffer:ReadFloat()
        tvalue.f2 = buffer:ReadFloat()
    elseif type == TransitionActionType.Alpha or
            type == TransitionActionType.Rotation then
        value.f1 = buffer:ReadFloat()
    elseif type == TransitionActionType.Scale then
        value.f1 = buffer:ReadFloat()
        value.f2 = buffer:ReadFloat()
    elseif type == TransitionActionType.Color then
        value.color = buffer:ReadColor()
    elseif type == TransitionActionType.Animation then
        value.playing = buffer:ReadBool()
        value.frame = buffer:ReadInt()
    elseif type == TransitionActionType.Visible then
        value.visible = buffer:ReadBool()
    elseif type == TransitionActionType.Sound then
        value.sound = buffer:ReadS()
        value.volume = buffer:ReadFloat()
    elseif type == TransitionActionType.Transition then
        value.transName = buffer:ReadS()
        value.playTimes = buffer:ReadInt()
        value.playCompleteDelegate = PlayCompleteCallback.new(function(...) self:OnPlayTransCompleted(item) end, self)
    elseif type == TransitionActionType.Shake then
        value.amplitude = buffer:ReadFloat()
        value.duration = buffer:ReadFloat()
    elseif type == TransitionActionType.ColorFilter then
        ---@type FairyGUI.TValue
        local tvalue = value
        tvalue.f1 = buffer:ReadFloat()
        tvalue.f2 = buffer:ReadFloat()
        tvalue.f3 = buffer:ReadFloat()
        tvalue.f4 = buffer:ReadFloat()
    elseif type == TransitionActionType.Text or
            type == TransitionActionType.Icon then
        value.text = buffer:ReadS()
    end
end

local __get = Class.init_get(Transition)
local __set = Class.init_set(Transition)

---@param self FairyGUI.Transition
__get.playing = function(self) return self._playing end

---@param self FairyGUI.Transition
__get.timeScale = function(self) return self._timeScale end

---@param self FairyGUI.Transition
---@param val number
__set.timeScale = function(self, val)
    if self._timeScale ~= val then
        self._timeScale = val
        for _, item in ipairs(self._items) do
            if item.tweener ~= nil then
                item.tweener:SetTimeScale(val)
            elseif item.type == TransitionActionType.Transition then
                if item.value.trans ~= nil then
                    item.value.trans.timeScale = val
                end
            elseif item.type == TransitionActionType.Animation then
                if item.target ~= nil then
                    item.target.timeScale = val
                end
            end
        end
    end
end

---@param self FairyGUI.Transition
__get.ignoreEngineTimeScale = function(self) return self._ignoreEngineTimeScale end

---@param self FairyGUI.Transition
---@param val boolean
__set.ignoreEngineTimeScale = function(self, val)
    if self._ignoreEngineTimeScale ~= val then
        self._ignoreEngineTimeScale = val
        for _, item in ipairs(self._items) do
            if item.tweener ~= nil then
                item.tweener:SetIgnoreEngineTimeScale(val)
            elseif item.type == TransitionActionType.Transition then
                if item.value.trans ~= nil then
                    item.value.trans.ignoreEngineTimeScale = val
                end
            elseif item.type == TransitionActionType.Animation then
                if item.target ~= nil then
                    item.target.ignoreEngineTimeScale = val
                end
            end
        end
    end
end

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
---@field public vec2 Love2DEngine.Vector2
---@field public vec4 Love2DEngine.Vector4
---@field public color Love2DEngine.Color
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