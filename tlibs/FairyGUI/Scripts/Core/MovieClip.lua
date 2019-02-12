--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:28
--

local Class = require('libs.Class')

local Time = Love2DEngine.Time
local TimerCallback = FairyGUI.TimerCallback
local Image = FairyGUI.Image
local EventListener = FairyGUI.EventListener
local TimerCallback = FairyGUI.TimerCallback
local Timers = FairyGUI.Timers
local ToolSet = Utils.ToolSet
local FlipType = FairyGUI.FlipType
local NGraphics = FairyGUI.NGraphics

---@class FairyGUI.MovieClip.Frame:ClassType
---@field public rect Love2DEngine.Rect
---@field public addDelay number
---@field public uvRect Love2DEngine.Rect
---@field public rotated boolean
local Frame = Class.inheritsFrom('Frame')

---@class FairyGUI.MovieClip:FairyGUI.Image
---@field public numbererval number
---@field public swing boolean
---@field public repeatDelay number
---@field public frameCount number
---@field public frames FairyGUI.MovieClip.Frame[]
---@field public timeScale number
---@field public ignoreEngineTimeScale boolean
---@field public onPlayEnd FairyGUI.EventListener
---@field public playing boolean
---@field public frame number
---@field private _frame number
---@field private _playing boolean
---@field private _start number
---@field private _end number
---@field private _times number
---@field private _endAt number
---@field private _status number --0-none, 1-next loop, 2-ending, 3-ended
---@field private _frameElapsed number --当前帧延迟
---@field private _reversed boolean
---@field private _repeatedCount number
---@field private _displayFrame number
---@field private _timerDelegate FairyGUI.TimerCallback
local MovieClip = Class.inheritsFrom('MovieClip', {
    swing = false,
    repeatDelay = 0,
    frameCount = 0,
    _frame = 0,
    _playing = false,
    _start = 0, _end = 0, _times = 0, _endAt = 0, _status = 0, _frameElapsed = 0, _reversed = false,
    _repeatedCount = 0, _displayFrame = 0
}, Image)

function MovieClip:__ctor()
    Image.__ctor(self)

    self._timerDelegate = TimerCallback.new()

    self.interval = 0.1
    self._playing = true
    self._timerDelegate:Add(self.OnTimer, self)
    self.timeScale = 1
    self.ignoreEngineTimeScale = false

    self.onPlayEnd = EventListener.new(self, "onPlayEnd")

    self:SetPlaySettings();
end

---@param texture FairyGUI.NTexture
---@param frames FairyGUI.MovieClip.Frame[]
---@param boundsRect Love2DEngine.Rect
function MovieClip:SetData(texture, frames, boundsRect)
    self.frames = frames
    self.frameCount = #frames
    self._contentRect = boundsRect

    if self._end == 0 or self._end > self.frameCount then
        self._end = self.frameCount
    end
    if self._endAt == 0 or self._endAt > self.frameCount then
        self._endAt = self.frameCount
    end

    if self._frame < 1 or self._frame > self.frameCount then
        self._frame = self.frameCount
    end

    self.graphics.texture = texture
    self:OnSizeChanged(true, true)
    self:InvalidateBatchingState()

    self._displayFrame = 0
    self._frameElapsed = 0
    self._repeatedCount = 0
    self._reversed = false

    self:CheckTimer()
end

function MovieClip:Clear()
    self.frameCount = 0
    self.graphics.texture = nil
    self.graphics:ClearMesh()
end

function MovieClip:Rewind()
    self._frame = 1
    self._frameElapsed = 0
    self._reversed = false
    self._repeatedCount = 0
end

---@param anotherMc FairyGUI.MovieClip
function MovieClip:SyncStatus(anotherMc)
    self._frame = anotherMc._frame
    self._frameElapsed = anotherMc._frameElapsed
    self._reversed = anotherMc._reversed
    self._repeatedCount = anotherMc._repeatedCount
    self._displayFrame = 0
end

---@param time number
function MovieClip:Advance(time)
    local beginFrame = self._frame
    local beginReversed = self._reversed
    local backupTime = time

    while true do
        local tt = self.interval + self.frames[self._frame].addDelay
        if self._frame == 0 and self._repeatedCount > 0 then
            tt = tt + self.repeatDelay
        end
        if time < tt then
            self._frameElapsed = 0
            break
        end
        time = time - tt
        if self.swing then
            if self._reversed then
                self._frame = self._frame - 1
                if self._frame <= 1 then
                    self._frame = 1
                    self._repeatedCount = self._repeatedCount + 1
                    self._reversed = not self._reversed
                end
            else
                self._frame = self._frame + 1
                if self._frame > self.frameCount then
                    self._frame = math.max(1, self.frameCount - 1)
                    self._repeatedCount = self._repeatedCount + 1
                    self._reversed = not self._reversed
                end
            end
        else
            self._frame = self._frame + 1
            if self._frame > self.frameCount then
                self._frame = 0
                self._repeatedCount = self._repeatedCount + 1
            end
        end

        if self._frame == beginFrame and self._reversed == beginReversed then -- 走了一轮了
            local roundTime = backupTime - time -- 这就是一轮需要的时间
            time = time - math.floor(time / roundTime) * roundTime -- 跳过
        end
    end
end

function MovieClip:SetPlaySettings(start, End, times, endAt)
    self._start = start or 1
    self._end = End or -1

    if self._end == -1 or self._end > self.frameCount then
        self._end = self.frameCount
    end

    self._times = times or 0
    self._endAt = endAt or -1
    if self._endAt == -1 then
        self._endAt = self._end
    end
    self._status = 0
    self._frame = start
end

function MovieClip:OnAddedToStage()
    if self._playing and self.frameCount > 0 then
        Timers.inst:AddUpdate(self._timerDelegate)
    end
end

function MovieClip:OnRemoveFromStage()
    Timers.inst:Remove(self._timerDelegate)
end

function MovieClip:CheckTimer()
    if self._playing and self.frameCount > 0 and self.stage ~= nil then
        Timers.inst:AddUpdate(self._timerDelegate)
    else
        Timers.inst:Remove(self._timerDelegate)
    end
end

---@param param any
function MovieClip:OnTimer(param)
    if not self._playing or self.frameCount == 0 or self._status == 3 then
        return
    end

    local dt
    if self.ignoreEngineTimeScale then
        dt = Time.unscaledDeltaTime
        if dt > 0.1 then
            dt = 0.1
        end
    else
        dt = Time.deltaTime
    end
    if self.timeScale ~= 1 then
        dt = dt * self.timeScale
    end

    self._frameElapsed = self._frameElapsed + dt
    local tt = self.interval + self.frames[self.frame].addDelay
    if self._frame == 1 and self._repeatedCount > 0 then
        tt = tt + self.repeatDelay
    end
    if self._frameElapsed < tt then
        return
    end

    self._frameElapsed = self._frameElapsed - tt
    if self._frameElapsed > self.interval then
        self._frameElapsed = self.interval
    end

    if self.swing then
        if self._reversed then
            self._frame = self._frame - 1
            if self._frame <= 1 then
                self._frame = 1
                self._repeatedCount = self._repeatedCount + 1
                self._reversed = not self._reversed
            end
        else
            self._frame = self._frame + 1
            if self._frame > self.frameCount then
                self._frame = math.max(1, self.frameCount - 1)
                self._repeatedCount = self._repeatedCount + 1
                self._reversed = not self._reversed
            end
        end
    else
        self.frame = self.frame + 1
        if self.frame > self.frameCount then
            self._frame = 1
            self._repeatedCount = self._repeatedCount + 1
        end
    end

    if self._status == 1 then -- new loop
        self._frame = self._start
        self._frameElapsed = 0
        self._status = 0
    elseif self._status == 2 then -- endding
        self._frame = self._endAt
        self._frameElapsed = 0
        self._status = 3

        self.onPlayEnd:Call()
    else
        if self._frame == self._end then
            if self._times > 0 then
                self._times = self._times - 1
                if self._times == 0 then
                    self._status = 2 -- ending
                else
                    self._status = 2 -- new loop
                end
            elseif self._start ~= 0 then
                self._status = 1
            end
        end
    end
end

---@param context FairyGUI.UpdateContext
function MovieClip:Update(context)
    if self.frameCount > 0 and self._frame ~= self._displayFrame then
        self:DrawFrame()
    end

    Image.Update(self, context)
end

function MovieClip:DrawFrame()
    self._displayFrame = self._frame

    if self._frame >= #self.frames then
        self.graphics:ClearMesh()
    else
        local frame = self.frames[self._frame]
        if frame.rect.width == 0 then
            self.graphics:ClearMesh()
        else
            local uvRect = frame.uvRect
            if self._flip ~= FlipType.None then
                ToolSet.FlipRect(uvRect, self._flip)
            end

            self.graphics:DrawRect(frame.rect, uvRect, self._color)
            if frame.rotated then
                NGraphics.RotateUV(self.graphics.uv, uvRect)
            end
            self.graphics:UpdateMesh()
        end
    end
end

function MovieClip:Rebuild()
    if self._texture ~= nil then
        Image.Rebuild(self)
    elseif self.frameCount > 0 then
        self._requireUpdateMesh = false
        self:DrawFrame()
    end
end

local __get = Class.init_get(MovieClip)
local __set = Class.init_set(MovieClip)

---@param self FairyGUI.MovieClip
__get.playing = function(self) return self._playing end

---@param self FairyGUI.MovieClip
---@param val boolean
__set.playing = function(self, val)
    if self._playing ~= val then
        self._playing = val
        self:CheckTimer()
    end
end

---@param self FairyGUI.MovieClip
__get.frame = function(self) return self._frame end

---@param self FairyGUI.MovieClip
---@param val boolean
__set.frame = function(self, val)
    if self._frame ~= val then
        if self.frames ~= nil and val >= self.frameCount then
            val = self.frameCount
        end
        self._frame = val
        self._frameElapsed = 0
        self._displayFrame = 0
    end
end

MovieClip.Frame = Frame
FairyGUI.MovieClip = MovieClip
return MovieClip