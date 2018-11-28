--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:33
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent
local GTween = FairyGUI.GTween
local ProgressTitleType = FairyGUI.ProgressTitleType
local GLoader = FairyGUI.GLoader
local GImage = FairyGUI.GImage
local FillMethod = FairyGUI.FillMethod
local TweenPropType = FairyGUI.TweenPropType
local EaseType = FairyGUI.EaseType
local GTweenCallback = FairyGUI.GTweenCallback

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
    local oldValule = self._value
    self._value = value

    if (self._tweening) then
        GTween.Kill(self, TweenPropType.Progress, false)
    end
    self._tweening = true

    return GTween.ToDouble(oldValule, self._value, duration)
        :SetEase(EaseType.Linear)
        :SetTarget(self, TweenPropType.Progress)
        :OnComplete(GTweenCallback.new(function () self._tweening = false end, self))
end

---@param newValue number
function GProgressBar:Update(newValue)
    local percent = self._max ~= 0 and math.min(newValue / self._max, 1) or 0
    if (self._titleObject ~= nil) then
        if self._titleType ==  ProgressTitleType.Percent then
            self._titleObject.text = math.round(percent * 100) .. "%"
        elseif self._titleType ==  ProgressTitleType.ValueAndMax then
            self._titleObject.text = math.round(newValue) .. "/" .. math.round(self.max)
        elseif self._titleType ==  ProgressTitleType.Value then
            self._titleObject.text = "" .. math.round(newValue)
        elseif self._titleType ==  ProgressTitleType.Max then
            self._titleObject.text = "" .. math.round(self._max)
        end
    end

    local fullWidth = self.width - self._barMaxWidthDelta
    local fullHeight = self.height - self._barMaxHeightDelta
    if (not self._reverse) then
        if (self._barObjectH ~= nil) then
            if (self._barObjectH:isa(GImage) and self._barObjectH.fillMethod ~= FillMethod.None) then
                self._barObjectH.fillAmount = percent
            elseif (self._barObjectH:isa(GLoader) and self._barObjectH.fillMethod ~= FillMethod.None) then
                self._barObjectH.fillAmount = percent
            else
                self._barObjectH.width = math.round(fullWidth * percent)
            end
        end
        if (self._barObjectV ~= nil) then
            if (self._barObjectV:isa(GImage) and self._barObjectV.fillMethod ~= FillMethod.None) then
                self._barObjectV.fillAmount = percent
            elseif (self._barObjectV:isa(GLoader) and self._barObjectV.fillMethod ~= FillMethod.None) then
                self._barObjectV.fillAmount = percent
            else
                self._barObjectV.height = math.round(fullHeight * percent)
            end
        end
    else
        if (self._barObjectH ~= nil) then
            if (self._barObjectH:isa(GImage) and self._barObjectH.fillMethod ~= FillMethod.None) then
                self._barObjectH.fillAmount = 1 - percent
            elseif (self._barObjectH:isa(GLoader) and self._barObjectH.fillMethod ~= FillMethod.None) then
                self._barObjectH.fillAmount = 1 - percent
            else
                self._barObjectH.width = math.round(fullWidth * percent)
                self._barObjectH.x = self._barStartX + (fullWidth - self._barObjectH.width)
            end
        end
        if (self._barObjectV ~= nil) then
            if (self._barObjectV:isa(GImage) and self._barObjectV.fillMethod ~= FillMethod.None) then
                self._barObjectV.fillAmount = 1 - percent
            elseif (self._barObjectV:isa(GLoader) and self._barObjectV.fillMethod ~= FillMethod.None) then
                self._barObjectV.fillAmount = 1 - percent
            else
                self._barObjectV.height = math.round(fullHeight * percent)
                self._barObjectV.y = self._barStartY + (fullHeight - self._barObjectV.height)
            end
        end
    end
    if (self._aniObject ~= nil) then
        self._aniObject.frame = math.round(percent * 100)
    end

    self:InvalidateBatchingState(true)
end

function GProgressBar:ConstructExtension(buffer)
    buffer:Seek(0, 6)

    self._titleType = buffer:ReadByte()
    self._reverse = buffer:ReadBool()

    self._titleObject = self:GetChild("title")
    self._barObjectH = self:GetChild("bar")
    self._barObjectV = self:GetChild("bar_v")
    self._aniObject = self:GetChild("ani")

    if (self._barObjectH ~= nil) then
        self._barMaxWidth = self._barObjectH.width
        self._barMaxWidthDelta = self.width - self._barMaxWidth
        self._barStartX = self._barObjectH.x
    end
    if (self._barObjectV ~= nil) then
        self._barMaxHeight = self._barObjectV.height
        self._barMaxHeightDelta = self.height - self._barMaxHeight
        self._barStartY = self._barObjectV.y
    end
end

function GProgressBar:Setup_AfterAdd(buffer, beginPos)
    GComponent.Setup_AfterAdd(buffer, beginPos)

    if (not buffer:Seek(beginPos, 6)) then
        self:Update(self._value)
        return
    end

    if (buffer:ReadByte() ~= self.packageItem.objectType) then
        self:Update(self._value)
        return
    end

    self._value = buffer:ReadInt()
    self._max = buffer:ReadInt()

    self:Update(self._value)
end

function GProgressBar:HandleSizeChanged()
    GComponent.HandleSizeChanged(self)

    if (self._barObjectH ~= nil) then
        self._barMaxWidth = self.width - self._barMaxWidthDelta
    end
    if (self._barObjectV ~= nil) then
        self._barMaxHeight = self.height - self._barMaxHeightDelta
    end

    if (not self.underConstruct) then
        self:Update(self._value)
    end
end

function GProgressBar:Dispose()
    if self._tweening then
        GTween.Kill(self)
    end
    GComponent.Dispose(self)
end


local __get = Class.init_get(GProgressBar)
local __set = Class.init_set(GProgressBar)

---@param self FairyGUI.GProgressBar
__get.titleType = function(self) return self._titleType end

---@param self FairyGUI.GProgressBar
---@param val FairyGUI.ProgressTitleType
__set.titleType = function(self, val)
    if self._titleType ~= val then
        self._titleType = val
        self:Update(self._value)
    end
end

---@param self FairyGUI.GProgressBar
__get.max = function(self) return self._max end

---@param self FairyGUI.GProgressBar
---@param val number
__set.max = function(self, val)
    if self._max ~= val then
        self._max = val
        self:Update(self._value)
    end
end

---@param self FairyGUI.GProgressBar
__get.value = function(self) return self._value end

---@param self FairyGUI.GProgressBar
---@param val number
__set.value = function(self, val)
    if (self._tweening) then
        GTween.Kill(self, TweenPropType.Progress, true)
        self._tweening = false
    end

    if (self._value ~= val) then
        self._value = val
        self:Update(self._value)
    end
end

---@param self FairyGUI.GProgressBar
__get.reverse = function(self) return self._reverse end

---@param self FairyGUI.GProgressBar
---@param val boolean
__set.reverse = function(self, val) self._reverse = val end


FairyGUI.GProgressBar = GProgressBar
return GProgressBar