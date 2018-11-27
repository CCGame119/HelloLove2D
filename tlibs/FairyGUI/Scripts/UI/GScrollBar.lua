--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:43
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent

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
end

---@param target FairyGUI.ScrollPane
---@param vertical boolean
function GScrollBar:SetScrollPane(target, vertical)

end

function GScrollBar:ConstructExtension(buffer)
end

---@param context FairyGUI.EventContext
function GScrollBar:__gripTouchBegin(context)

end

---@param context FairyGUI.EventContext
function GScrollBar:__gripTouchMove(context)

end

---@param context FairyGUI.EventContext
function GScrollBar:__arrowButton1Click(context)

end

---@param context FairyGUI.EventContext
function GScrollBar:__arrowButton2Click(context)

end

---@param context FairyGUI.EventContext
function GScrollBar:__touchBegin(context)

end

--TODO: FairyGUI.GScrollBar

local __get = Class.init_get(GScrollBar)
local __set = Class.init_set(GScrollBar)

---@param self FairyGUI.GScrollBar
__get.displayPerc = function(self) end

---@param self FairyGUI.GScrollBar
---@param val number
__set.displayPerc = function(self, val) end

---@param self FairyGUI.GScrollBar
__get.scrollPerc = function(self) end

---@param self FairyGUI.GScrollBar
---@param val number
__set.scrollPerc = function(self, val) end

---@param self FairyGUI.GScrollBar
__get.minSize = function(self) end

---@param self FairyGUI.GScrollBar
---@param val number
__set.minSize = function(self, val) end


FairyGUI.GScrollBar = GScrollBar
return GScrollBar