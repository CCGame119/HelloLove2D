--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:38
--

local Class = require('libs.Class')

local Rect = Love2DEngine.Rect

local GObject = FairyGUI.GObject
local IAnimationGear = FairyGUI.IAnimationGear
local IColorGear = FairyGUI.IColorGear
local EventListener = FairyGUI.EventListener
local MovieClip = FairyGUI.MovieClip

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

function GMovieClip:CreateDisplayObject()
    self._content = MovieClip.new()
    self._content.gOwner = self
    self._content.ignoreEngineTimeScale = true
    self.displayObject = self._content
end

function GMovieClip:Rewind()
    self._content:Rewind()
end

---@param anotherMc FairyGUI.MovieClip
function GMovieClip:SyncStatus(anotherMc)
    self._content:SyncStatus(anotherMc._content)
end

---@param time number
function GMovieClip:Advance(time)
    self._content:Advance(time)
end

---Play from the start to end, repeat times, set to endAt on complete.
---从start帧开始，播放到end帧（-1表示结尾），重复times次（0表示无限循环），循环结束后，停止在endAt帧（-1表示参数end）
---@param start number
---@param End number
---@param times number
---@param endAt number
function GMovieClip:SetPlaySettings(start, End, times, endAt)
    self.displayObject:SetPlaySettings(start, End, times, endAt)
end

function GMovieClip:ConstructFromResource()
    local packageItem = self.packageItem
    local _content = self._content

    packageItem:Load()

    self.sourceWidth = packageItem.width
    self.sourceHeight = packageItem.height
    self.initWidth = self.sourceWidth
    self.initHeight = self.sourceHeight

    _content.interval = packageItem.interval
    _content.swing = packageItem.swing
    _content.repeatDelay = packageItem.repeatDelay
    _content:SetData(packageItem.texture, packageItem.frames, Rect(0, 0, self.sourceWidth, self.sourceHeight))

    self:SetSize(self.sourceWidth, self.sourceHeight)
end

function GMovieClip:Setup_BeforeAdd(buffer, beginPos)
    GObject.Setup_BeforeAdd(self, buffer, beginPos)

    local _content = self._content

    buffer:Seek(beginPos, 5)

    if (buffer:ReadBool()) then
        _content.color = buffer:ReadColor()
        _content.flip = buffer:ReadByte()
        _content.frame = buffer:ReadInt()
        _content.playing = buffer:ReadBool()
    end
end


local __get = Class.init_get(GMovieClip)
local __set = Class.init_set(GMovieClip)

---@param self FairyGUI.GMovieClip
__get.playing = function(self) return self._content.playing end

---@param self FairyGUI.GMovieClip
---@param val boolean
__set.playing = function(self, val)
    self._content.playing = val
    self:UpdateGear(5)
end

---@param self FairyGUI.GMovieClip
__get.frame = function(self) return self._content.frame end

---@param self FairyGUI.GMovieClip
---@param val number
__set.frame = function(self, val)
    self._content.frame = val
    self:UpdateGear(5)
end

---@param self FairyGUI.GMovieClip
__get.color = function(self) return self._content.color end

---@param self FairyGUI.GMovieClip
---@param val Love2DEngine.Color
__set.color = function(self, val)
    self._content.color = val
    self:UpdateGear(4)
end

---@param self FairyGUI.GMovieClip
__get.flip = function(self) return self._content.flip end

---@param self FairyGUI.GMovieClip
---@param val FairyGUI.FlipType
__set.flip = function(self, val) self._content.flip = val end

---@param self FairyGUI.GMovieClip
__get.material = function(self) return self._content.material end

---@param self FairyGUI.GMovieClip
---@param val Love2DEngine.Material
__set.material = function(self, val) self._content.material = val end

---@param self FairyGUI.GMovieClip
__get.shader = function(self) return self._content.shader end

---@param self FairyGUI.GMovieClip
---@param val string
__set.shader = function(self, val) self._content.shader = val end

---@param self FairyGUI.GMovieClip
__get.timeScale = function(self) return self._content.timeScale  end

---@param self FairyGUI.GMovieClip
---@param val number
__set.timeScale = function(self, val) self._content.timeScale = val end

---@param self FairyGUI.GMovieClip
__get.ignoreEngineTimeScale = function(self) return _content.ignoreEngineTimeScale end

---@param self FairyGUI.GMovieClip
---@param val boolean
__set.ignoreEngineTimeScale = function(self, val) self._content.ignoreEngineTimeScale = val  end


FairyGUI.GMovieClip = GMovieClip
return GMovieClip