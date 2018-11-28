--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:43
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2
local Debug = Love2DEngine.Debug

local GComponent = FairyGUI.GComponent
local EventCallback1 = FairyGUI.EventCallback1

---@class FairyGUI.GScrollBar:FairyGUI.GComponent
---@field public displayPerc number
---@field public scrollPerc number
---@field public minSize number
---@field private _grip FairyGUI.GObject
---@field private _arrowButton1 FairyGUI.GObject
---@field private _arrowButton2 FairyGUI.GObject
---@field private _bar FairyGUI.GObject
---@field private _target FairyGUI.ScrollPane
---@field private _vertical boolean
---@field private _scrollPerc number
---@field private _fixedGripSize boolean
---@field private _dragOffset Love2DEngine.Vector2
local GScrollBar = Class.inheritsFrom('GScrollBar', nil, GComponent)

function GScrollBar:__ctor()
    GComponent.__ctor(self)
    self._scrollPerc = 0

    self.__gripTouchBeginDelegate = EventCallback1.new(self.__gripTouchBegin, self)
    self.__gripTouchMoveDelegate = EventCallback1.new(self.__gripTouchMove, self)
    self.__touchBeginDelegate = EventCallback1.new(self.__touchBegin, self)
    self.__arrowButton1ClickDelegate = EventCallback1.new(self.__arrowButton1Click, self)
    self.__arrowButton2ClickDelegate = EventCallback1.new(self.__arrowButton2Click, self)
end

---@param target FairyGUI.ScrollPane
---@param vertical boolean
function GScrollBar:SetScrollPane(target, vertical)
    self._target = target
    self._vertical = vertical
end

function GScrollBar:ConstructExtension(buffer)
    buffer:Seek(0, 6)

    self._fixedGripSize = buffer:ReadBool()

    self._grip = self:GetChild("grip")
    if (self._grip == nil) then
        Debug.LogWarn("FairyGUI: " .. self.resourceURL .. " should define grip")
        return
    end

    self._bar = self:GetChild("bar")
    if (self._bar == nil) then
        Debug.LogWarn("FairyGUI: " .. self.resourceURL .. " should define bar")
        return
    end

    self._arrowButton1 = self:GetChild("arrow1")
    self._arrowButton2 = self:GetChild("arrow2")

    self._grip.onTouchBegin:Add(self.__gripTouchBeginDelegate)
    self._grip.onTouchMove:Add(self.__gripTouchMoveDelegate)

    self.onTouchBegin:Add(self.__touchBeginDelegate)
    if (self._arrowButton1 ~= nil) then
        self._arrowButton1.onTouchBegin:Add(self.__arrowButton1ClickDelegate)
    end
    if (self._arrowButton2 ~= nil) then
        self._arrowButton2.onTouchBegin:Add(self.__arrowButton2ClickDelegate)
    end
end

---@param context FairyGUI.EventContext
function GScrollBar:__gripTouchBegin(context)
    if (self._bar == nil) then
        return
    end

    context:StopPropagation()

    local evt = context.inputEvent
    if (evt.button ~= 0) then
        return
    end

    context:CaptureTouch()

    self._dragOffset = self:GlobalToLocal(Vector2(evt.x, evt.y)) - self._grip.xy
end

---@param context FairyGUI.EventContext
function GScrollBar:__gripTouchMove(context)
    local evt = context.inputEvent
    local pt = self:GlobalToLocal(Vector2(evt.x, evt.y))
    if (math.isNaN(pt.x)) then
        return
    end

    if (self._vertical) then
        local curY = pt.y - self._dragOffset.y
        local diff = self._bar.height - self._grip.height
        if (diff == 0) then
            self._target.percY = 0
        else
            self._target.percY = (curY - self._bar.y) / diff
        end
    else
        local curX = pt.x - self._dragOffset.x
        local diff = self._bar.width - self._grip.width
        if (diff == 0) then
            self._target.percX = 0
        else
            self._target.percX = (curX - self._bar.x) / diff
        end
    end
end

---@param context FairyGUI.EventContext
function GScrollBar:__arrowButton1Click(context)
    context:StopPropagation()

    if (self._vertical) then
        self._target:ScrollUp()
    else
        self._target:ScrollLeft()
    end
end

---@param context FairyGUI.EventContext
function GScrollBar:__arrowButton2Click(context)
    context:StopPropagation()

    if (self._vertical) then
        self._target:ScrollDown()
    else
        self._target:ScrollRight()
    end
end

---@param context FairyGUI.EventContext
function GScrollBar:__touchBegin(context)
    context:StopPropagation()

    local evt = context.inputEvent
    local pt = self._grip:GlobalToLocal(Vector2(evt.x, evt.y))
    if (self._vertical) then
        if (pt.y < 0) then
            self._target:ScrollUp(4, false)
        else
            self._target:ScrollDown(4, false)
        end
    else
        if (pt.x < 0) then
            self._target:ScrollLeft(4, false)
        else
            self._target:ScrollRight(4, false)
        end
    end
end


local __get = Class.init_get(GScrollBar)
local __set = Class.init_set(GScrollBar)

---@param self FairyGUI.GScrollBar
---@param val number
__set.displayPerc = function(self, val)
    local _scrollPerc = self._scrollPerc
    local _bar = self._bar
    local _grip = self.grip
    local _fixedGripSize = self._fixedGripSize

    if (self._vertical) then
        if (not _fixedGripSize) then
            _grip.height = math.floor(val * _bar.height)
        end
        _grip.y = math.round(_bar.y + (_bar.height - _grip.height) * _scrollPerc)
    else
        if (not _fixedGripSize) then
            _grip.width = math.floor(val * _bar.width)
        end
        _grip.x = math.round(_bar.x + (_bar.width - _grip.width) * _scrollPerc)
    end
end

---@param self FairyGUI.GScrollBar
---@param val number
__set.scrollPerc = function(self, val)
    self._scrollPerc = val
    local _scrollPerc = self._scrollPerc
    local _bar = self._bar
    local _grip = self.grip
    if self._vertical then
        _grip.y = math.round(_bar.y + (_bar.height - _grip.height) * _scrollPerc)
    else
        _grip.x = math.round(_bar.x + (_bar.width - _grip.width) * _scrollPerc)
    end
end

---@param self FairyGUI.GScrollBar
__get.minSize = function(self)
    local _arrowButton1 = self._arrowButton1
    local _arrowButton2 = self._arrowButton2
    if self._vertical then
        return (_arrowButton1 ~= nil and _arrowButton1.height or 0) + (_arrowButton2 ~= nil and _arrowButton2.height or 0)
    else
        return (_arrowButton1 ~= nil and _arrowButton1.width or 0) + (_arrowButton2 ~= nil and _arrowButton2.width or 0)
    end
end


FairyGUI.GScrollBar = GScrollBar
return GScrollBar