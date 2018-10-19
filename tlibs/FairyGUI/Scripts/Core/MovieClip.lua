--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:28
--

local Class = require('libs.Class')

local TimerCallback = FairyGUI.TimerCallback
local Image = FairyGUI.Image
local EventListener = FairyGUI.EventListener
local TimerCallback = FairyGUI.TimerCallback

---@class FairyGUI.MovieClip.Frame:ClassType
---@field public rect Love2DEngine.Rect
---@field public addDelay number
---@field public uvRect Love2DEngine.Rect
---@field public rotated boolean
local Frame = Class.inheritsFrom('Frame')

---@class FairyGUI.MovieClip:ClassType
---@field public numbererval number
---@field public swing boolean
---@field public repeatDelay number
---@field public frameCount number
---@field public frames FairyGUI.MovieClip.Frame[]
---@field public timeScale number
---@field public ignoreEngineTimeScale boolean
---@field public onPlayEnd FairyGUI.EventListener
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
local MovieClip = Class.inheritsFrom('MovieClip', nil, Image)

function MovieClip:__ctor()
    self._timerDelegate = TimerCallback.new()

    self.interval = 0.1
    self._playing = true
    self._timerDelegate:Add(self.OnTimer, self)
    self.timeScale = 1
    self.ignoreEngineTimeScale = false

    self.onPlayEnd = EventListener.new(self, "onPlayEnd")

    self:SetPlaySettings();
end
--TODO: FairyGUI.MovieClip

MovieClip.Frame = Frame
FairyGUI.MovieClip = MovieClip
return MovieClip