--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:34
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2

local GComponent = FairyGUI.GComponent
local EventCallback1 = FairyGUI.EventCallback1
local FillMethod = FairyGUI.FillMethod
local ProgressTitleType = FairyGUI.ProgressTitleType
local GImage = FairyGUI.GImage
local GLoader = FairyGUI.GLoader
local EventListener = FairyGUI.EventListener

---@class FairyGUI.GSlider:FairyGUI.GComponent
---@field public changeOnClick boolean
---@field public canDrag boolean
---@field public onChanged FairyGUI.EventListener
---@field public onGripTouchEnd FairyGUI.EventListener
---@field public titleType FairyGUI.ProgressTitleType
---@field public max number
---@field public value number
---@field private _max number
---@field private _value number
---@field private _titleType FairyGUI.ProgressTitleType
---@field private _reverse boolean
---@field private _titleObject FairyGUI.GTextField
---@field private _barObjectH FairyGUI.GObject
---@field private _barObjectV FairyGUI.GObject
---@field private _barMaxWidth number
---@field private _barMaxHeight number
---@field private _barMaxWidthDelta number
---@field private _barMaxHeightDelta number
---@field private _gripObject FairyGUI.GObject
---@field private _clickPos Love2DEngine.Vector2
---@field private _clickPercent number
---@field private _barStartX number
---@field private _barStartY number
local GSlider = Class.inheritsFrom('GSlider', nil, GComponent)

function GSlider:__ctor()
    GComponent.__ctor(self)

    self._value = 50
    self._max = 100
    self.changeOnClick = true
    self.canDrag = true

    self.onChanged = EventListener.new(self, "onChanged")
    self.onGripTouchEnd = EventListener.new(self, "onGripTouchEnd")

    self.__gripTouchBeginDelegate = EventCallback1.new(self.__gripTouchBegin, self)
    self.__gripTouchMoveDelegate = EventCallback1.new(self.__gripTouchMove, self)
    self.__gripTouchEndDelegate = EventCallback1.new(self.__gripTouchEnd, self)
    self.__barTouchBeginDelegate = EventCallback1.new(self.__barTouchBegin, self)
end

function GSlider:Update()
    local percent = math.min(self._value / self._max, 1)
    self:UpdateWidthPercent(percent)
end

---@param percent
function GSlider:UpdateWidthPercent(percent)
    if (self._titleObject ~= nil) then
        if self._titleType ==  ProgressTitleType.Percent then
            self._titleObject.text = math.round(percent * 100) .. "%"
        elseif self._titleType ==  ProgressTitleType.ValueAndMax then
            self._titleObject.text = math.round(self._value) .. "/" .. math.round(max)
        elseif self._titleType ==  ProgressTitleType.Value then
            self._titleObject.text = "" .. math.round(self._value)
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

    self:InvalidateBatchingState(true)
end

function GSlider:ConstructExtension(buffer)
    buffer:Seek(0, 6)

    self._titleType = buffer:ReadByte()
    self._reverse = buffer:ReadBool()

    self._titleObject = self:GetChild("title")
    self._barObjectH = self:GetChild("bar")
    self._barObjectV = self:GetChild("bar_v")
    self._gripObject = self:GetChild("grip")

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

    if (self._gripObject ~= nil) then
        self._gripObject.onTouchBegin:Add(self.__gripTouchBeginDelegate)
        self._gripObject.onTouchMove:Add(self.__gripTouchMoveDelegate)
        self._gripObject.onTouchEnd:Add(self.__gripTouchEndDelegate)
    end

    self.onTouchBegin:Add(self.__barTouchBeginDelegate)
end

function GSlider:Setup_AfterAdd(buffer, beginPos)
    GComponent.Setup_AfterAdd(self, buffer, beginPos)

    if (not buffer:Seek(beginPos, 6)) then
        self:Update()
        return
    end

    if (buffer.ReadByte() ~= self.packageItem.objectType) then
        self:Update()
        return
    end

    self._value = buffer:ReadInt()
    self._max = buffer:ReadInt()

    self:Update()
end

function GSlider:HandleSizeChanged()
    GComponent.HandleSizeChanged(self)

    if (self._barObjectH ~= nil) then
        self._barMaxWidth = self.width - self._barMaxWidthDelta
    end
    if (self._barObjectV ~= nil) then
        self._barMaxHeight = self.height - self._barMaxHeightDelta
    end

    if (not self.underConstruct) then
        self:Update()
    end
end

---@param context FairyGUI.EventContext
function GSlider:__gripTouchBegin(context)
    self.canDrag = true

    context:StopPropagation()

    local evt = context.inputEvent
    if (evt.button ~= 0) then
        return
    end

    context:CaptureTouch()

    self._clickPos = self:GlobalToLocal(Vector2(evt.x, evt.y))
    self._clickPercent = self._value / self._max
end

---@param context FairyGUI.EventContext
function GSlider:__gripTouchMove(context)
    if (not self.canDrag) then
        return
    end

    local evt = context.inputEvent
    local pt = self:GlobalToLocal(Vector2(evt.x, evt.y))
    if (math.isNaN(pt.x)) then
        return
    end

    local deltaX = pt.x - self._clickPos.x
    local deltaY = pt.y - self._clickPos.y
    if (self._reverse) then
        deltaX = -deltaX
        deltaY = -deltaY
    end

    local percent
    if (self._barObjectH ~= nil) then
        percent = self._clickPercent + deltaX / self._barMaxWidth
    else
        percent = self._clickPercent + deltaY / self._barMaxHeight
    end
    if (percent > 1) then
        percent = 1
    elseif (percent < 0) then
        percent = 0
    end

    local newValue = percent * self._max
    if (newValue ~= self._value) then
        self._value = newValue
        if (self.onChanged:Call()) then
            return
        end
    end
    self:UpdateWidthPercent(percent)
end

---@param context FairyGUI.EventContext
function GSlider:__gripTouchEnd(context)
    self.onGripTouchEnd:Call()
end

---@param context FairyGUI.EventContext
function GSlider:__barTouchBegin(context)
    local _gripObject = self._gripObject
    if (not self.changeOnClick) then
        return
    end

    local evt = context.inputEvent
    local pt = _gripObject:GlobalToLocal(Vector2(evt.x, evt.y))
    local percent = self._value / self._max
    local delta = 0
    if (self._barObjectH ~= nil) then
        delta = (pt.x - _gripObject.width / 2) / self._barMaxWidth
    end
    if (self._barObjectV ~= nil) then
        delta = (pt.y - _gripObject.height / 2) / self._barMaxHeight
    end
    if (self._reverse) then
        percent = percent - delta
    else
        percent = percent + delta
    end
    if (percent > 1) then
        percent = 1
    elseif (percent < 0) then
        percent = 0
    end
    local newValue = percent * _max
    if (newValue ~= self._value) then
        self._value = newValue
        self.onChanged:Call()
    end
    self:UpdateWidthPercent(percent)
end


local __get = Class.init_get(GSlider)
local __set = Class.init_set(GSlider)

---@param self FairyGUI.GSlider
__get.titleType = function(self) return self._titleType end

---@param self FairyGUI.GSlider
---@param val FairyGUI.ProgressTitleType
__set.titleType = function(self, val)
    if self._titleType ~= val then
        self._titleType = val
        self:Update()
    end
end

---@param self FairyGUI.GSlider
__get.max = function(self) return self._max end

---@param self FairyGUI.GSlider
---@param val number
__set.max = function(self, val)
    if self._max ~= val then
        self._max = val
        self:Update()
    end
end

---@param self FairyGUI.GSlider
__get.value = function(self) return self._value end

---@param self FairyGUI.GSlider
---@param val number
__set.value = function(self, val)
    if self._value ~= val then
        self._value = val
        self:Update()
    end
end


FairyGUI.GSlider = GSlider
return GSlider