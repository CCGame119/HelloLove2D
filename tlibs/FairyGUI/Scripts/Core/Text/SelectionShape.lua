--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 15:03
--

local Class = require('libs.Class')

local Color = Love2DEngine.Color
local Rect = Love2DEngine.Rect

local ToolSet = Utils.ToolSet

local DisplayObject = FairyGUI.DisplayObject
local NGraphics = FairyGUI.NGraphics
local NTexture = FairyGUI.NTexture
local HitTestContext = FairyGUI.HitTestContext

---@class FairyGUI.SelectionShape:FairyGUI.DisplayObject
---@field private _rects Love2DEngine.Rect[]
---@field private _color Love2DEngine.Color
local SelectionShape = Class.inheritsFrom('SelectionShape', nil, DisplayObject)

function SelectionShape:__ctor()
    DisplayObject.__ctor(self)

    self:CreateGameObject('SelectionShape')
    self.graphics = NGraphics.new()
    self.graphics.texture = NTexture.Empty
    self._color = Color.white
end

function SelectionShape:Clear()
    if (_rects ~= nil and _rects.Count > 0) then
        self._rects = {}
        self._contentRect:Set(0, 0, 0, 0)
        self:OnSizeChanged(true, true)
        self._requireUpdateMesh = true
    end
end

function SelectionShape:Update(context)
    local graphics = self.graphics

    if (self._requireUpdateMesh) then
        self._requireUpdateMesh = false
        if (self._rects ~= nil and #self._rects > 0) then
            local count = #self._rects * 4
            graphics:Alloc(count)
            local uvRect = Rect(0, 0, 1, 1)
            for i = 1, count, 4 do
                graphics:FillVerts(i, self._rects[math.floor((i - 1) / 4)])
                graphics:FillUV(i, uvRect)
            end
            graphics:FillColors(self._color)
            graphics:FillTriangles()
            graphics:UpdateMesh()
        else
            graphics:ClearMesh()
        end
    end

    DisplayObject.Update(self, context)
end

function SelectionShape:HitTest()
    if (self._rects == nil) then
        return nil
    end

    local count = #self._rects
    if (count == 0) then
        return nil
    end

    local localPoint = self:WorldToLocal(HitTestContext.worldPoint, HitTestContext.direction)
    if (not self._contentRect:Contains(localPoint)) then
        return nil
    end

    for i = 1, count do
        if (self._rects[i]:Contains(localPoint)) then
            return self
        end
    end

    return nil
end


local __get = Class.init_get(SelectionShape)
local __set = Class.init_set(SelectionShape)

---@param self FairyGUI.SelectionShape
__get = function(self) return self._rects end

---@param self FairyGUI.SelectionShape
---@param val Love2DEngine.Rect[]
__set = function(self, val)
    self._rects = val
    if self._rects ~= nil then
        local count = #self._rects
        if count > 0 then
            self._contentRect = self._rects[1]
            local tmp
            for i = 2, count do
                tmp = self._rects[i]
                self._contentRect = ToolSet.Union(self._contentRect, tmp)
            end
        else
            self._contentRect:Set(0, 0, 0, 0)
        end
    else
        self._contentRect:Set(0, 0, 0, 0)
    end
    self:OnSizeChanged(true, true)
    self._requireUpdateMesh = true
end

---@param self FairyGUI.SelectionShape
__get = function(self) return self._color end

---@param self FairyGUI.SelectionShape
---@param val Love2DEngine.Color
__set = function(self, val)
    if self._color ~= val then
        self._color = val
        self.graphics:Tint(self._color)
    end
end

FairyGUI.SelectionShape = SelectionShape
return SelectionShape