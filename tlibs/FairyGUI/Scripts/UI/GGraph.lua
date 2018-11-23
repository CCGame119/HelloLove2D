--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:37
--

local Class = require('libs.Class')

local Color = Love2DEngine.Color

local GObject = FairyGUI.GObject
local IColorGear = FairyGUI.IColorGear
local Shape = FairyGUI.Shape


---@class FairyGUI.GGraph:FairyGUI.GObject @implement IColorGear
---GGraph class.
---对应编辑器里的图形对象。图形有两个用途，一是用来显示简单的图形，例如矩形等；二是作为一个占位的用途，
---可以将本对象替换为其他对象，或者在它的前后添加其他对象，相当于一个位置和深度的占位；还可以直接将内容设置
---为原生对象。
---@field private _shape FairyGUI.Shape
---@field public color Love2DEngine.Color
---@field public shape FairyGUI.Shape @获取图形的原生对象，可用于绘制图形。
local GGraph = Class.inheritsFrom('GGraph', nil, GObject, {IColorGear})

function GGraph:__ctor()
    GObject.__ctor(self)
end

---Replace this object to another object in the display list.
---在显示列表中，将指定对象取代这个图形对象。这个图形对象相当于一个占位的用途。
---@param target FairyGUI.GObject
function GGraph:ReplaceMe(target)
    if (self.parent == nil) then
        error("parent not set")
    end

    target.name = self.name
    target.alpha = self.alpha
    target.rotation = self.rotation
    target.visible = self.visible
    target.touchable = self.touchable
    target.grayed = self.grayed
    target:SetXY(self.x, self.y)
    target:SetSize(self.width, self.height)

    local index = self.parent:GetChildIndex(self)
    self.parent:AddChildAt(target, index)
    target.relations:CopyFrom(self.relations)

    self.parent:RemoveChild(self, true)
end

---Add another object before this object.
---在显示列表中，将另一个对象插入到这个对象的前面。
---@param target FairyGUI.GObject
function GGraph:AddBeforeMe(target)
    if (self.parent == nil) then
        error("parent not set")
    end

    local index = self.parent:GetChildIndex(self)
    self.parent:AddChildAt(target, index)
end

---Add another object after this object.
---在显示列表中，将另一个对象插入到这个对象的后面。
---@param target FairyGUI.GObject
function GGraph:AddAfterMe(target)
    if (self.parent == nil) then
        error("parent not set")
    end

    local index = self.parent:GetChildIndex(self)
    index = index + 1
    self.parent:AddChildAt(target, index)
end

---设置内容为一个原生对象。这个图形对象相当于一个占位的用途。
---@param obj FairyGUI.DisplayObject
function GGraph:SetNativeObject(obj)
    if (self.displayObject == obj) then
        return
    end

    if (self.displayObject ~= nil) then
        if (self.displayObject.parent ~= nil) then
            self.displayObject.parent:RemoveChild(self.displayObject, true)
        else
            self.displayObject:Dispose()
        end
        self._shape = nil
        self.displayObject.gOwner = nil
        self.displayObject = nil
    end

    self.displayObject = obj

    if (self.displayObject ~= nil) then
        self.displayObject.alpha = self.alpha
        self.displayObject.rotation = self.rotation
        self.displayObject.visible = self.visible
        self.displayObject.touchable = self.touchable
        self.displayObject.gOwner = self
    end

    if (self.parent ~= nil) then
        self.parent:ChildStateChanged(self)
    end
    self:HandlePositionChanged()
end

---Draw a rectangle.
---画矩形。
---@param aWidth number
---@param aHeight number
---@param lineSize number
---@param lineColor Love2DEngine.Color
---@param fillColor Love2DEngine.Color
function GGraph:DrawRect(aWidth, aHeight, lineSize, lineColor, fillColor)
    self:SetSize(aWidth, aHeight)
    self.shape:DrawRect(lineSize, lineColor, fillColor)
end

---@param aWidth number
---@param aHeight number
---@param fillColor Love2DEngine.Color
---@param corner number[]
function GGraph:DrawRoundRect(aWidth, aHeight, fillColor, corner)
    self:SetSize(aWidth, aHeight)
    self.shape:DrawRoundRect(fillColor, corner)
end

---@param aWidth number
---@param aHeight number
---@param fillColor Love2DEngine.Color
function GGraph:DrawEllipse(aWidth, aHeight, fillColor)
    self:SetSize(aWidth, aHeight)
    self.shape:DrawEllipse(fillColor)
end

---@param aWidth number
---@param aHeight number
---@param ponumbers Love2DEngine.Vector2[]
---@param fillColor Love2DEngine.Color
function GGraph:DrawPolygon(aWidth, aHeight, points, fillColor)
    self:SetSize(aWidth, aHeight)
    self.shape:DrawPolygon(points, fillColor)
end

function GGraph:Setup_BeforeAdd(buffer, beginPos)
    buffer:Seek(beginPos, 5)

    local type = buffer:ReadByte()
    local lineSize = 0
    local lineColor = Color()
    local fillColor = Color()
    local cornerRadius = nil

    if (type ~= 0) then
        self._shape = Shape.new()
        self._shape.gOwner = self
        self.displayObject = self._shape

        lineSize = buffer:ReadInt()
        lineColor = buffer:ReadColor()
        fillColor = buffer:ReadColor()
        cornerRadius = nil
        if (buffer:ReadBool()) then
            cornerRadius = {}
            for i = 1, 4 do
                cornerRadius[i] = buffer:ReadFloat()
            end
        end
    end
        GObject.Setup_BeforeAdd(self, buffer, beginPos)

    if (self._shape ~= nil) then
        if (type == 1) then
            if (cornerRadius ~= nil) then
                self:DrawRoundRect(self.width, self.height, fillColor, cornerRadius)
            else
                self:DrawRect(self.width, self.height, lineSize, lineColor, fillColor)
            end
        else
            self:DrawEllipse(self.width, self.height, fillColor)
        end
    end
end


local __get = Class.init_get(GGraph)
local __set = Class.init_set(GGraph)

---@param self FairyGUI.GGraph
__get.color = function(self)
    if self._shape ~= nil then
        return self._shape.color
    end
    return Color.clear
end

---@param self FairyGUI.GGraph
---@param val Love2DEngine.Color
__set.color = function(self, val)
    if self._shape ~= nil and self._shape.color ~= val then
        self._shape.color:Assign(val)
        self:UpdateGear(4)
    end
end

---@param self FairyGUI.GGraph
__get.shape = function(self)
    if (self._shape ~= nil) then
        return self._shape
    end

    if (self.displayObject ~= nil) then
        self.displayObject:Dispose()
    end

    self._shape = Shape.new()
    self._shape.gOwner = self
    self.displayObject = self._shape
    if (self.parent ~= nil) then
        self.parent:ChildStateChanged(self)
    end
    self:HandleSizeChanged()
    self:HandleScaleChanged()
    self:HandlePositionChanged()
    self._shape.alpha = self.alpha
    self._shape.rotation = self.rotation
    self._shape.visible = self.visible

    return self._shape
end

FairyGUI.GGraph = GGraph
return GGraph