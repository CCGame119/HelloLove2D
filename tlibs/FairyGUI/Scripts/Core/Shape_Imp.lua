--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2019/1/26 10:54
--

local Class = require('libs.Class')

local Color = Love2DEngine.Color
local Rect = Love2DEngine.Rect

local DisplayObject = FairyGUI.DisplayObject
local NGraphics = FairyGUI.NGraphics
local NTexture = FairyGUI.NTexture
local HitTestContext = FairyGUI.HitTestContext

---@class FairyGUI.Shape:FairyGUI.DisplayObject
---@field public empty boolean
---@field public color Love2DEngine.Color
---@field private _type number
---@field private _lineSize number
---@field private _lineColor Love2DEngine.Color
---@field private _fillColor Love2DEngine.Color
---@field private _colors Love2DEngine.Color[]
---@field private _polygonPoints Love2DEngine.Vector2[]
---@field private _cornerRadius number[]
local Shape = FairyGUI.Shape

function Shape:__ctor()
    DisplayObject.__ctor(self)

    self:CreateGameObject("Shape")
    self.graphics = NGraphics.new(self.gameObject)
    self.graphics.texture = NTexture.Empty
end

---@param lineSize number
---@param lineColor Love2DEngine.Color|Love2DEngine.Color[]
---@param fillColor Love2DEngine.Color
function Shape:DrawRect(lineSize, lineColor, fillColor)
    self._type = 1
    self._lineSize = lineSize

    if Class.isa(lineColor, Color) then
        self._lineColor = lineColor
        self._fillColor = fillColor
        self._colors = nil
    else
        self._colors = lineColor
    end

    self._touchDisabled = false
    self._requireUpdateMesh = true
end

---@param fillColor Love2DEngine.Color
---@param cornerRadius number[]
function Shape:DrawRoundRect(fillColor, cornerRadius)
    self._type = 4
    self._fillColor = fillColor
    self._cornerRadius = cornerRadius

    self._touchDisabled = false
    self._requireUpdateMesh = true
end

---@param fillColor Love2DEngine.Color|Love2DEngine.Color[]
function Shape:DrawEllipse(fillColor)
    self._type = 2
    if Class.isa(fillColor, Color) then
        self._fillColor = fillColor
        self._colors = nil
    else
        self._colors = fillColor
    end

    self._touchDisabled = false
    self._requireUpdateMesh = true
end

---@param points Love2DEngine.Vector2[]
---@param fillColor Love2DEngine.Color|Love2DEngine.Color[]
function Shape:DrawPolygon(points, fillColor)
    self._type = 3
    self._polygonPoints = points
    if Class.isa(fillColor, Color) then
        self._fillColor = fillColor
        self._colors = nil
    else
        self._colors = fillColor
    end

    self._touchDisabled = false
    self._requireUpdateMesh = true
end

function Shape:Clear()
    self._type = 0
    self._touchDisabled = true
    self.graphics:ClearMesh()
end

---@param context FairyGUI.UpdateContext
function Shape:Update(context)
    if self._requireUpdateMesh then
        self._requireUpdateMesh = false
        if self._type ~= 0 then
            if (self._contentRect.width > 0 and self._contentRect.height > 0) then
                if self._type == 1 then
                    self.graphics:DrawRect(self._contentRect, Rect(0, 0, 1, 1), self._lineSize, self._lineColor, self._fillColor)
                    if (self._colors ~= nil) then
                        self.graphics:FillColors(self._colors)
                    end
                elseif self._type == 2 then
                    self.graphics:DrawEllipse(self._contentRect, Rect(0, 0, 1, 1), self._fillColor)
                    if (self._colors ~= nil) then
                        self.graphics:FillColors(self._colors)
                    end
                elseif self._type == 3 then
                    self.graphics:DrawPolygon(self._contentRect, Rect(0, 0, 1, 1), self._polygonPoints, self._fillColor)
                    if (self._colors ~= nil) then
                        self.graphics:FillColors(self._colors)
                    end
                elseif self._type == 4 then
                    if (self._cornerRadius.Length >= 4) then
                        self.graphics:DrawRoundRect(self._contentRect, Rect(0, 0, 1, 1), self._fillColor,
                                self._cornerRadius[1], self._cornerRadius[2], self._cornerRadius[3], self._cornerRadius[4])
                    else
                        self.graphics:DrawRoundRect(self._contentRect, Rect(0, 0, 1, 1), self._fillColor,
                                self._cornerRadius[1], self._cornerRadius[1], self._cornerRadius[1], self._cornerRadius[1])
                    end
                end

                self.graphics:UpdateMesh()
            else
                self.graphics:ClearMesh()
            end
        end
    end

    DisplayObject.Update(self, context)
end

---@return FairyGUI.DisplayObject
function Shape:HitTest()
    if self._type == 2 then
        local localPoint = self:WorldToLocal(HitTestContext.worldPoint, HitTestContext.direction)
        if not self._contentRect:Contains(localPoint) then
            return nil
        end

        --圆形加多一个在圆内的判断
        local xx = localPoint.x - self._contentRect.width * 0.5
        local yy = localPoint.y - self._contentRect.height * 0.5
        local pow1 = math.pow((xx / (self._contentRect.width * 0.5)), 2)
        local pow2 = math.pow((yy / (self._contentRect.height * 0.5)), 2)
        if pow1 + pow2 < 1 then
            return self
        end

        return nil
    end

    if self._type == 3 then
        local localPoint = self:WorldToLocal(HitTestContext.worldPoint, HitTestContext.direction)
        if (not self._contentRect:Contains(localPoint)) then
            return nil
        end

        -- Algorithm & implementation thankfully taken from:
        -- -> http://alienryderflex.com/polygon/
        -- inspired by Starling

        local len = self._polygonPoints.Length
        local i
        local j = len
        local oddNodes = false

        for i = 1, len do
            local ix = self._polygonPoints[i].x
            local iy = self._polygonPoints[i].y
            local jx = self._polygonPoints[j].x
            local jy = self._polygonPoints[j].y

            if (iy < localPoint.y and jy >= localPoint.y or jy < localPoint.y and iy >= localPoint.y) and
                    (ix <= localPoint.x or jx <= localPoint.x) then
                if (ix + (localPoint.y - iy) / (jy - iy) * (jx - ix) < localPoint.x) then
                    oddNodes = not oddNodes
                end
            end
            j = i
        end
        return oddNodes and self or nil
    end
    return DisplayObject.HitTest(self)
end

local __get = Class.init_get(Shape)
local __set = Class.init_set(Shape)

__get.empty = function(self) return self._type == 0 end

__get.color = function(self) return self._fillColor  end
__set.color = function(self, val)
    if self._fillColor ~= val then
        self._fillColor = val
        self._requireUpdateMesh = true
    end
end