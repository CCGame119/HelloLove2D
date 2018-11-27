--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:38
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local IAnimationGear = FairyGUI.IAnimationGear
local IColorGear = FairyGUI.IColorGear
local EventListener = FairyGUI.EventListener

---@class FairyGUI.GMovieClip:FairyGUI.GObject @implement IAnimationGear, IColorGear
---@field public playing boolean
---@field public frame number
---@field public color Love2DEngine.Color
---@field public flip FairyGUI.FlipType
---@field public material Love2DEngine.Material
---@field public shader string
---@field public timeScale number
---@field public ignoreEngineTimeScale boolean
---@field public onPlayEnd FairyGUI.EventListener
---@field private _content FairyGUI.MovieClip
local GMovieClip = Class.inheritsFrom('GMovieClip', nil, GObject, {IAnimationGear, IColorGear})

function GMovieClip:__ctor()
    GObject.__ctor(self)
    self._sizeImplType = 1
    self.onPlayEnd = EventListener.new(self, "onPlayEnd")
end

function GMovieClip:CreateDisplayObject() end

function GMovieClip:Rewind() end

---@param anotherMc FairyGUI.MovieClip
function GMovieClip:SyncStatus(anotherMc) end

---@param time number
function GMovieClip:Advance(time) end

---Play from the start to end, repeat times, set to endAt on complete.
---从start帧开始，播放到end帧（-1表示结尾），重复times次（0表示无限循环），循环结束后，停止在endAt帧（-1表示参数end）
---@param start number
---@param End number
---@param times number
---@param endAt number
function GMovieClip:SetPlaySettings(start, End, times, endAt) end

function GMovieClip:ConstructFromResource() end

function GMovieClip:Setup_BeforeAdd(buffer, beginPos)
end

--TODO: FairyGUI.GMovieClip

local __get = Class.init_get(GMovieClip)
local __set = Class.init_set(GMovieClip)

---@param self FairyGUI.GMovieClip
__get.playing  = function(self) end

---@param self FairyGUI.GMovieClip
---@param val boolean
__set.playing  = function(self, val) end

---@param self FairyGUI.GMovieClip
__get.frame  = function(self) end

---@param self FairyGUI.GMovieClip
---@param val number
__set.frame  = function(self, val) end

---@param self FairyGUI.GMovieClip
__get.color  = function(self) end

---@param self FairyGUI.GMovieClip
---@param val Love2DEngine.Color
__set.color  = function(self, val) end

---@param self FairyGUI.GMovieClip
__get.flip  = function(self) end

---@param self FairyGUI.GMovieClip
---@param val FairyGUI.FlipType
__set.flip  = function(self, val) end

---@param self FairyGUI.GMovieClip
__get.material  = function(self) end

---@param self FairyGUI.GMovieClip
---@param val Love2DEngine.Material
__set.material  = function(self, val) end

---@param self FairyGUI.GMovieClip
__get.shader  = function(self) end

---@param self FairyGUI.GMovieClip
---@param val string
__set.shader  = function(self, val) end

---@param self FairyGUI.GMovieClip
__get.timeScale  = function(self) end

---@param self FairyGUI.GMovieClip
---@param val number
__set.timeScale  = function(self, val) end

---@param self FairyGUI.GMovieClip
__get.ignoreEngineTimeScale  = function(self) end

---@param self FairyGUI.GMovieClip
---@param val boolean
__set.ignoreEngineTimeScale  = function(self, val) end


FairyGUI.GMovieClip = GMovieClip
return GMovieClip