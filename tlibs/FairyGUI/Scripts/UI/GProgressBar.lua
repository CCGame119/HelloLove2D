--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:33
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent

---@class FairyGUI.GProgressBar:FairyGUI.GComponent
---@field public titleType FairyGUI.ProgressTitleType
---@field public max number
---@field public value number
---@field public reverse boolean
---@field private _max number
---@field private _value number
---@field private _titleType FairyGUI.ProgressTitleType
---@field private _reverse boolean
---@field private _titleObject FairyGUI.GTextField
---@field private _aniObject FairyGUI.GMovieClip
---@field private _barObjectH FairyGUI.GObject
---@field private _barObjectV FairyGUI.GObject
---@field private _barMaxWidth number
---@field private _barMaxHeight number
---@field private _barMaxWidthDelta number
---@field private _barMaxHeightDelta number
---@field private _barStartX number
---@field private _barStartY number
---@field private _tweening boolean
local GProgressBar = Class.inheritsFrom('GProgressBar', nil, GComponent)

function GProgressBar:__ctor()
    GComponent.__ctor(self)
    self._value = 50
    self._max = 100
end

---@param value number
---@param duration number
---@return FairyGUI.GTweener
function GProgressBar:TweenValue(value, duration)

end

---@param newValue number
function GProgressBar:Update(newValue)

end

function GProgressBar:ConstructExtension(buffer)
end

function GProgressBar:Setup_AfterAdd(buffer, beginPos)
end

function GProgressBar:HandleSizeChanged()
end

function GProgressBar:Dispose()
end

--TODO: FairyGUI.GProgressBar

local __get = Class.init_get(GProgressBar)
local __set = Class.init_set(GProgressBar)

---@param self FairyGUI.GProgressBar
__get.titleType = function(self) end

---@param self FairyGUI.GProgressBar
---@param val FairyGUI.ProgressTitleType
__set.titleType = function(self, val) end

---@param self FairyGUI.GProgressBar
__get.max = function(self) end

---@param self FairyGUI.GProgressBar
---@param val number
__set.max = function(self, val) end

---@param self FairyGUI.GProgressBar
__get.value = function(self) end

---@param self FairyGUI.GProgressBar
---@param val number
__set.value = function(self, val) end

---@param self FairyGUI.GProgressBar
__get.reverse = function(self) end

---@param self FairyGUI.GProgressBar
---@param val boolean
__set.reverse = function(self, val) end


FairyGUI.GProgressBar = GProgressBar
return GProgressBar