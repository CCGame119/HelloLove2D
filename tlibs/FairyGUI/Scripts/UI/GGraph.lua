--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:37
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local IColorGear = FairyGUI.IColorGear


---@class FairyGUI.GGraph:FairyGUI.GObject @implement IColorGear
---GGraph class.
---对应编辑器里的图形对象。图形有两个用途，一是用来显示简单的图形，例如矩形等；二是作为一个占位的用途，
---可以将本对象替换为其他对象，或者在它的前后添加其他对象，相当于一个位置和深度的占位；还可以直接将内容设置
---为原生对象。
---@field private _shape FairyGUI.Shape
local GGraph = Class.inheritsFrom('GGraph', nil, GObject, {IColorGear})

function GGraph:__ctor()
    GObject.__ctor(self)
end

---Replace this object to another object in the display list.
---在显示列表中，将指定对象取代这个图形对象。这个图形对象相当于一个占位的用途。
---@param target FairyGUI.GObject
function GGraph:ReplaceMe(target) end

---Add another object before this object.
---在显示列表中，将另一个对象插入到这个对象的前面。
---@param target FairyGUI.GObject
function GGraph:AddBeforeMe(target) end

---Add another object after this object.
---在显示列表中，将另一个对象插入到这个对象的后面。
---@param target FairyGUI.GObject
function GGraph:AddAfterMe(target) end

---设置内容为一个原生对象。这个图形对象相当于一个占位的用途。
---@param obj FairyGUI.DisplayObject
function GGraph:SetNativeObject(obj) end

---Draw a rectangle.
---画矩形。
---@param aWidth number
---@param aHeight number
---@param lineSize number
---@param lineColor Love2DEngine.Color
---@param fillColor Love2DEngine.Color
function GGraph:DrawRect(aWidth, aHeight, lineSize, lineColor, fillColor) end

---@param aWidth number
---@param aHeight number
---@param fillColor Love2DEngine.Color
---@param corner number[]
function GGraph:DrawRoundRect(aWidth, aHeight, fillColor, corner) end

---@param aWidth number
---@param aHeight number
---@param fillColor Love2DEngine.Color
function GGraph:DrawEllipse(aWidth, aHeight, fillColor) end

---@param aWidth number
---@param aHeight number
---@param ponumbers Love2DEngine.Vector2[]
---@param fillColor Love2DEngine.Color
function GGraph:DrawPolygon(aWidth, aHeight, points, fillColor) end

function GGraph:Setup_BeforeAdd(buffer, beginPos)
end

--TODO: FairyGUI.GGraph

local __get = Class.init_get(GGraph)
local __set = Class.init_set(GGraph)

---@param self FairyGUI.GGraph
__get.color = function(self) end

---@param self FairyGUI.GGraph
---@param val Love2DEngine.Color
__set.color = function(self, val) end

---@param self FairyGUI.GGraph
__get.shape = function(self) end

FairyGUI.GGraph = GGraph
return GGraph