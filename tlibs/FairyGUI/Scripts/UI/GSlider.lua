--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:34
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent

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
end

function GSlider:Update()

end

---@param percent
function GSlider:UpdateWidthPercent(percent)

end

function GSlider:ConstructExtension(buffer)
end

function GSlider:Setup_AfterAdd(buffer, beginPos)
end

function GSlider:HandleSizeChanged()
end

---@param context FairyGUI.EventContext
function GSlider:__gripTouchBegin(context)

end

---@param context FairyGUI.EventContext
function GSlider:__gripTouchMove(context)

end

---@param context FairyGUI.EventContext
function GSlider:__gripTouchEnd(context)

end

---@param context FairyGUI.EventContext
function GSlider:__barTouchBegin(context)

end

--TODO: FairyGUI.GSlider

local __get = Class.init_get(GSlider)
local __set = Class.init_set(GSlider)

---@param self FairyGUI.GSlider
__get.titleType = function(self) end

---@param self FairyGUI.GSlider
---@param val FairyGUI.ProgressTitleType
__set.titleType = function(self, val) end

---@param self FairyGUI.GSlider
__get.max = function(self) end

---@param self FairyGUI.GSlider
---@param val number
__set.max = function(self, val) end

---@param self FairyGUI.GSlider
__get.value = function(self) end

---@param self FairyGUI.GSlider
---@param val number
__set.value = function(self, val) end


FairyGUI.GSlider = GSlider
return GSlider