--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:22
--

local Class = require('libs.Class')
local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

local GObject = FairyGUI.GObject
local EventCallback0 = FairyGUI.EventCallback0
local GroupLayoutType = FairyGUI.GroupLayoutType
local UpdateContext = FairyGUI.UpdateContext

---@class FairyGUI.GGroup:FairyGUI.GObject
---GGroup class.
---组对象，对应编辑器里的高级组。
---@field public layout FairyGUI.GroupLayoutType @Group layout type.
---@field public lineGap number
---@field public columnGap number
---@field private _layout FairyGUI.GroupLayoutType
---@field private _lineGap number
---@field private _columnGap number
---@field private _percentReady boolean
---@field private _boundsChanged boolean
---@field private _refreshDelegate FairyGUI.EventCallback0
---@field private _updating number
local GGroup = Class.inheritsFrom('GGroup', nil, GObject)

function GGroup:__ctor()
    GObject.__ctor(self)
    self._refreshDelegate = EventCallback0.new(self.EnsureBoundsCorrect, self)
end

--- Update group bounds.
--- 更新组的包围.
---@param childSizeChanged boolean @default: false
function GGroup:SetBoundsChangedFlag(childSizeChanged)
    childSizeChanged = childSizeChanged or false

    if (self._updating == 0 and parent ~= nil) then
        if (childSizeChanged) then
            self._percentReady = false
        end

        if (not self._boundsChanged) then
            self._boundsChanged = true

            if (self._layout ~= GroupLayoutType.None) then
                UpdateContext.OnBegin:Remove(self._refreshDelegate)
                UpdateContext.OnBegin:Add(self._refreshDelegate)
            end
        end
    end
end

function GGroup:EnsureBoundsCorrect()
    if self._boundsChanged then
        self:UpdateBounds()
    end
end

function GGroup:UpdateBounds()
    local parent = self.parent
    UpdateContext.OnBegin:Remove(self._refreshDelegate)

    self._boundsChanged = false

    if (parent == nil) then
        return
    end

    self:HandleLayout()

    local cnt = parent.numChildren
    local i
    local child
    local ax, ay = math.maxval, math.maxval
    local ar, ab = math.minval, math.minval
    local tmp
    local empty = true

    for i = 1,  cnt do
        child = parent:GetChildAt(i)
        if (child.group ~= self) then
            --continue
        else
            tmp = child.x
            if (tmp < ax) then
                ax = tmp
            end
            tmp = child.y
            if (tmp < ay) then
                ay = tmp
            end
            tmp = child.x + child.width
            if (tmp > ar) then
                ar = tmp
            end
            tmp = child.y + child.height
            if (tmp > ab) then
                ab = tmp
            end

            empty = false
        end
    end

    if (not empty) then
        self._updating = 1
        self:SetXY(ax, ay)
        self._updating = 2
        self:SetSize(ar - ax, ab - ay)
    else
        self._updating = 2
        self:SetSize(0, 0)
    end

    self._updating = 0
end

function GGroup:HandleLayout()
    self._updating = bor(self._updating, 1)

    if (self._layout == GroupLayoutType.Horizontal) then
        local curX = math.nan
        local cnt = parent.numChildren
        for i = 1, cnt do
            local child = parent:GetChildAt(i)
            if (child.group ~= self) then
                -- continue
            else
                if (math.isNaN(curX)) then
                    curX = math.floor(child.x)
                else
                    child.x = curX
                end
                if (child.width ~= 0) then
                    curX = curX + math.floor(child.width + self._columnGap)
                end
            end
        end
        if (not self._percentReady) then
            self:UpdatePercent()
        end
    elseif (self._layout == GroupLayoutType.Vertical) then
        local curY = math.nan
        local cnt = parent.numChildren
        for i = 1, cnt do
            local child = parent:GetChildAt(i)
            if (child.group ~= self) then
                --continue
            else
                if (math.isNaN(curY)) then
                    curY = math.floor(child.y)
                else
                    child.y = curY
                end
                if (child.height ~= 0) then
                    curY = curY + math.floor(child.height + self._lineGap)
                end
            end
        end
        if (not self._percentReady) then
            self:UpdatePercent()
        end
    end

    self._updating = band(self._updating, 2)
end

function GGroup:UpdatePercent()
    local parent = self.parent
    self._percentReady = true

    local cnt = parent.numChildren
    local i
    local child
    local size = 0
    if (self._layout == GroupLayoutType.Horizontal) then
        for i =1, cnt do
            child = parent:GetChildAt(i)
            if (child.group ~= self) then
                --continue
            else
                size = size + child.width
            end
        end

        for i = 1, cnt do
            child = parent:GetChildAt(i)
            if (child.group ~= self) then
                --continue
            else
                if (size > 0) then
                    child._sizePercentInGroup = child.width / size
                else
                    child._sizePercentInGroup = 0
                end
            end
        end
    else
        for i = 1, cnt do
            child = parent:GetChildAt(i)
            if (child.group ~= self) then
                --continue
            else
                size = size + child.height
            end
        end

        for i = 1, cnt do
            child = parent:GetChildAt(i)
            if (child.group ~= self) then
                --continue
            else
                if (size > 0) then
                    child._sizePercentInGroup = child.height / size
                else
                    child._sizePercentInGroup = 0
                end
            end
        end
    end
end

---@param dx number
---@param dy number
function GGroup:MoveChildren(dx, dy)
    local parent = self.parent
    if (band(self._updating, 1) ~= 0 or parent == nil) then
        return
    end

    self._updating = bor(self._updating, 1)

    local cnt = parent.numChildren
    local i
    local child
    for i = 1, cnt do
        child = parent:GetChildAt(i)
        if (child.group == self) then
            child:SetXY(child.x + dx, child.y + dy)
        end
    end

    self._updating = band(self._updating, 2)
end

---@param dw number
---@param dh number
function GGroup:ResizeChildren(dw, dh)
    local parent = self.parent

    if (self._layout == GroupLayoutType.None or band(self._updating, 2) ~= 0 or parent == nil) then
        return
    end

    self._updating = bor(self._updating, 2)

    if (not self._percentReady) then
        self:UpdatePercent()
    end

    local cnt = parent.numChildren
    local i
    local j
    local child
    local last = -1
    local numChildren = 0
    local lineSize = 0
    local remainSize = 0
    local found = false

    for i = 1, cnt do
        child = parent:GetChildAt(i)
        if (child.group ~= self) then
            --continue
        else
            last = i
            numChildren = numChildren + 1
        end
    end

    if (self._layout == GroupLayoutType.Horizontal) then
        lineSize = self.width - (numChildren - 1) * self._columnGap
        remainSize = lineSize
        local curX = math.nan
        local nw
        for i = 1, cnt do
            child = parent:GetChildAt(i)
            if (child.group ~= self) then
                --continue
            else

                if (math.isNaN(curX)) then
                    curX = math.floor(child.x)
                else
                    child.x = curX
                end
                if (last == i) then
                    nw = remainSize
                else
                    nw = math.round(child._sizePercentInGroup * lineSize)
                end
                child:SetSize(nw, child._rawHeight + dh, true)
                remainSize = remainSize - child.width
                if (last == i) then
                    if (remainSize >= 1) then -- 可能由于有些元件有宽度限制，导致无法铺满
                        for j = 1, i do
                            child = parent:GetChildAt(j)
                            if (child.group ~= self) then
                                -- continue
                            else
                                if (not found) then
                                    nw = child.width + remainSize
                                    if ((child.maxWidth == 0 or nw < child.maxWidth)
                                            and (child.minWidth == 0 or nw > child.minWidth)) then
                                        child:SetSize(nw, child.height, true)
                                        found = true
                                    end
                                else
                                    child.x = child.x + remainSize
                                end
                            end
                        end
                    end
                else
                    curX = curX + (child.width + self._columnGap)
                end
            end
        end
    elseif (self._layout == GroupLayoutType.Vertical) then
        lineSize = self.height - (numChildren - 1) * self._lineGap
        remainSize = lineSize
        local curY = math.nan
        local nh
        for i = 1, cnt do
            child = parent:GetChildAt(i)
            if (child.group ~= self) then
                --continue
            else

                if (math.isNaN(curY)) then
                    curY = math.floor(child.y)
                else
                    child.y = curY
                end
                if (last == i) then
                    nh = remainSize
                else
                    nh = math.round(child._sizePercentInGroup * lineSize)
                end
                child:SetSize(child._rawWidth + dw, nh, true)
                remainSize = remainSize - child.height
                if (last == i) then
                    if (remainSize >= 1) then -- 可能由于有些元件有宽度限制，导致无法铺满
                        for j = 1, i do
                            child = parent:GetChildAt(j)
                            if (child.group ~= self) then
                                --continue
                            else
                                if (not found) then
                                    nh = child.height + remainSize
                                    if ((child.maxHeight == 0 or nh < child.maxHeight)
                                            and (child.minHeight == 0 or nh > child.minHeight)) then
                                        child:SetSize(child.width, nh, true)
                                        found = true
                                    end
                                else
                                    child.y = child.y + remainSize
                                end
                            end
                        end
                    end
                else
                    curY = curY + (child.height + self._lineGap)
                end
            end
        end
    end

    self._updating = band(self._updating, 1)
end

function GGroup:HandleAlphaChanged()
    GObject.HandleAlphaChanged(self)

    if self.underConstruct then
        return
    end

    local a= self.alpha
    for i = 1, self.parent.numChildren do
        local child = self.parent:GetChildAt(i)
        if child.group == self then
            child.alpha = a
        end
    end
end

function GGroup:HandleVisibleChanged()
    if self.parent == nil then
        return
    end

    for i = 1, self.parent.numChildren do
        local child = self.parent:GetChildAt(i)
        if child.group == self then
            child:HandleVisibleChanged()
        end
    end
end

function GGroup:Setup_BeforeAdd(buffer, beginPos)
    GObject.Setup_BeforeAdd(self, buffer, beginPos)

    buffer:Seek(beginPos, 5)

    self._layout = buffer:ReadByte()
    self._lineGap = buffer:ReadInt()
    self._columnGap = buffer:ReadInt()
end

function GGroup:Setup_AfterAdd(buffer, beginPos)
    GObject.Setup_AfterAdd(self, buffer, beginPos)

    if not self.visible then
        self:HandleVisibleChanged()
    end
end


local __get = Class.init_get(GGroup)
local __set = Class.init_set(GGroup)

---@param self FairyGUI.GGroup
__get.layout = function(self) return self._layout end

---@param self FairyGUI.GGroup
---@param val FairyGUI.GroupLayoutType
__set.layout = function(self, val)
    if self._layout ~= val then
        self._layout = val
        self:SetBoundsChangedFlag(true)
    end
end


---@param self FairyGUI.GGroup
__get.lineGap = function(self) return self._lineGap end

---@param self FairyGUI.GGroup
---@param val number
__set.lineGap = function(self, val)
    if self._lineGap ~= val then
        self._lineGap = val
        self:SetBoundsChangedFlag()
    end
end


---@param self FairyGUI.GGroup
__get.columnGap = function(self) return self._columnGap end

---@param self FairyGUI.GGroup
---@param val number
__set.columnGap = function(self, val)
    if self._columnGap ~= val then
        self._columnGap = val
        self:SetBoundsChangedFlag()
    end
end


FairyGUI.GGroup = GGroup
return GGroup