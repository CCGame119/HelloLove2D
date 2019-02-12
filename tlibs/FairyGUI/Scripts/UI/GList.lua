--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:36
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

local Rect = Love2DEngine.Rect
local Debug = Love2DEngine.Debug
local Vector2 = Love2DEngine.Vector2

local GComponent = FairyGUI.GComponent
local GObjectPool = FairyGUI.GObjectPool
local Container = FairyGUI.Container
local EventListener = FairyGUI.EventListener
local EventCallback1 = FairyGUI.EventCallback1
local TimerCallback = FairyGUI.TimerCallback
local Timers = FairyGUI.Timers
local ListLayoutType = FairyGUI.ListLayoutType
local GButton = FairyGUI.GButton
local ListSelectionMode = FairyGUI.ListSelectionMode
local GRoot = FairyGUI.GRoot
local UIConfig = FairyGUI.UIConfig
local UIPackage = FairyGUI.UIPackage
local ChildrenRenderOrder = FairyGUI.ChildrenRenderOrder
local OverflowType = FairyGUI.OverflowType
local VertAlignType = FairyGUI.VertAlignType
local AlignType = FairyGUI.AlignType

---@class FairyGUI.ListItemRenderer:Delegate @fun(index:number, item:FairyGUI.GObject)
local ListItemRenderer = Delegate.newDelegate('ListItemRenderer')

---@class FairyGUI.ListItemProvider:Delegate @fun(index:number):string
local ListItemProvider = Delegate.newDelegate('ListItemProvider')

--region FairyGUI.GList 类声明
---@class FairyGUI.GList:FairyGUI.GComponent
---@field public defaultItem string @Resource url of the default item.
---@field public foldInvisibleItems boolean @如果true，当item不可见时自动折叠，否则依然占位
---@field public selectionMode FairyGUI.ListSelectionMode @List selection mode
---@field public itemRenderer FairyGUI.ListItemRenderer @Callback function when an item is needed to update its look.
---@field public itemProvider FairyGUI.ListItemProvider @Callback funtion to return item resource url.
---@field public onClickItem FairyGUI.EventListener @Dispatched when a list item being clicked.
---@field public onRightClickItem FairyGUI.EventListener @Dispatched when a list item being clicked with right button.
---@field public scrollItemToViewOnClick boolean
---@field public numItems number @Set the list item count. If the list is not virtual, specified number of items will be created. If the list is virtual, only items in view will be created.
---@field public isVirtual boolean
---@field public touchItem FairyGUI.GObject @获取当前点击哪个item
---@field public selectionController FairyGUI.Controller
---@field public selectedIndex number
---@field public itemPool FairyGUI.GObjectPool
---@field public align FairyGUI.AlignType
---@field public verticalAlign FairyGUI.VertAlignType
---@field public autoResizeItem boolean
---@field public lineCount number
---@field public columnCount number
---@field public lineGap number
---@field public columnGap number
---@field public layout FairyGUI.ListLayoutType
---@field private _layout FairyGUI.ListLayoutType
---@field private _lineCount number
---@field private _columnCount number
---@field private _lineGap number
---@field private _columnGap number
---@field private _align FairyGUI.AlignType
---@field private _verticalAlign FairyGUI.VertAlignType
---@field private _autoResizeItem boolean
---@field private _selectionController FairyGUI.Controller
---@field private _pool FairyGUI.GObjectPool
---@field private _selectionHandled boolean
---@field private _lastSelectedIndex number
---@field private _virtual boolean
---@field private _loop boolean
---@field private _numItems number
---@field private _realNumItems number
---@field private _firstIndex number  -- the top left index
---@field private _curLineItemCount number  -- item count in one line
---@field private _curLineItemCount2 number  -- 只用在页面模式，表示垂直方向的项目数
---@field private _itemSize Love2DEngine.Vector2
---@field private _virtualListChanged number  -- 1-content changed, 2-size changed
---@field private _eventLocked boolean
---@field private itemInfoVer number  -- 用来标志item是否在本次处理中已经被重用了
---@field private enterCounter number  -- 因为HandleScroll是会重入的，这个用来避免极端情况下的死锁
---@field private _virtualItems FairyGUI.GList.ItemInfo[]
---@field private _itemClickDelegate FairyGUI.EventCallback1
---@field private _itemTouchBeginDelegate FairyGUI.EventCallback1
local GList = Class.inheritsFrom('GList', nil, GComponent)
--endregion

--region FairyGUI.GList.ItemInfo 类声明
---@class FairyGUI.GList.ItemInfo:ClassType
---@field public size Love2DEngine.Vector2
---@field public obj FairyGUI.GObject
---@field public updateFlag number
---@field public selected boolean
local ItemInfo = Class.inheritsFrom('ItemInfo')
--endregion

--region FairyGUI.GList 类函数
function GList:__ctor()
    GComponent.__ctor(self)

    self._trackBounds = true
    self.opaque = true
    self.scrollItemToViewOnClick = true

    self.container = Container.new()
    self.rootContainer:AddChild(self.container)
    self.rootContainer.gameObject.name = "GList"

    self._pool = GObjectPool.new(self.container.cachedTransform)

    self._itemClickDelegate = EventCallback1.new(self.__clickItem, self)
    self._itemTouchBeginDelegate = EventCallback1.new(self.__itemTouchBegin, self)
    self.onClickItem = EventListener.new(self, "onClickItem")
    self.onRightClickItem = EventListener.new(self, "onRightClickItem")

    self.RefreshVirtualListDelegate = TimerCallback.new(self.RefreshVirtualList, self)
    self.__scrolledDelegate = EventCallback1.new(self.__scrolled, self)
end

function GList:Dispose()
    self._pool:Clear()
    if (self._virtualListChanged ~= 0) then
        Timers.inst:Remove(self.RefreshVirtualListDelegate)
    end

    self._selectionController = nil
    self.scrollItemToViewOnClick = false
    self.itemRenderer = nil
    self.itemProvider = nil

    GComponent.Dispose(self)
end

---@param url string
---@return FairyGUI.GObject
function GList:GetFromPool(url)
    if (string.isNullOrEmpty(url)) then
        url = self.defaultItem
    end

    local ret = self._pool:GetObject(url)
    if (ret ~= nil) then
        ret.visible = true
    end
    return ret
end

---@param obj FairyGUI.GObject
function GList:ReturnToPool(obj)
    self._pool:ReturnObject(obj)
end

---@overload fun()
---@param url string
---@return FairyGUI.GObject
function GList:AddItemFromPool(url)
    local obj = self:GetFromPool(url)
    return self:AddChild(obj)
end

function GList:AddChildAt(child, index)
    GComponent.AddChildAt(self, child, index)

    if child:isa(GButton) then
        ---@type FairyGUI.GButton
        local button = child
        button.selected = false
        button.changeStateOnClick = false
    end

    child.onTouchBegin:Add(self._itemTouchBeginDelegate)
    child.onClick:Add(self._itemClickDelegate)
    child.onRightClick:Add(self._itemClickDelegate)

    return child
end

function GList:RemoveChildAt(index, dispose)
    local child = GComponent.RemoveChildAt(self, index, dispose)
    child.onTouchBegin:Remove(self._itemTouchBeginDelegate)
    child.onClick:Remove(self._itemClickDelegate)
    child.onRightClick:Remove(self._itemClickDelegate)

    return child
end

---@param index number
function GList:RemoveChildToPoolAt(index)
    local child = GComponent.RemoveChildAt(self, index)
    self:ReturnToPool(child)
end

---@param child FairyGUI.GObject
function GList:RemoveChildToPool(child)
    GComponent.RemoveChild(self, child)
    self:ReturnToPool(child)
end

---@overload fun()
---@param beginIndex number @default: 1
---@param endIndex number @default: -1
function GList:RemoveChildrenToPool(beginIndex, endIndex)
    beginIndex = beginIndex or 1
    endIndex = endIndex or -1

    if (endIndex < 1 or endIndex > #self._children) then
        endIndex = #self._children
    end

    for i = beginIndex, endIndex do
        self:RemoveChildToPoolAt(beginIndex)
    end
end

---@return number[]
function GList:GetSelection()
    local ret = {}
    if self._virtual then
        local cnt = self._realNumItems
        for i = 1, cnt do
            local ii = self._virtualItems[i]
            if (ii.obj:isa(GButton) and ii.obj.selected
                    or ii.obj == nil and ii.selected) then
                local j = i
                local continue = false
                if (self._loop) then
                    j = math.module(i, self._numItems)
                    if (ret:contain(j)) then
                        continue = true
                    end
                end
                if not continue then
                    table.insert(ret, j)
                end
            end
        end
    else
        local cnt = #self._children
        for i = 1, cnt do
            local obj = self._children[i].asButton
            if (obj ~= nil and obj.selected) then
                table.insert(ret, i)
            end
        end
    end
    return ret
end

---@param index number
---@param scrollItToView boolean
function GList:AddSelection(index, scrollItToView)
    if (self.selectionMode == ListSelectionMode.None) then
        return
    end

    self:CheckVirtualList()

    if (self.selectionMode == ListSelectionMode.Single) then
        self:ClearSelection()
    end

    if (scrollItToView) then
        self:ScrollToView(index)
    end

    self._lastSelectedIndex = index
    local obj = nil
    if (self._virtual) then
        local ii = self._virtualItems[index]
        if (ii.obj ~= nil) then
            obj = ii.obj.asButton
        end
        ii.selected = true
    else
        obj = self:GetChildAt(index).asButton
    end

    if (obj ~= nil and not obj.selected) then
        obj.selected = true
        self:UpdateSelectionController(index)
    end
end

---@param index number
function GList:RemoveSelection(index)
    if (self.selectionMode == ListSelectionMode.None) then
        return
    end

    local obj = nil
    if (self._virtual) then
        local ii = self._virtualItems[index]
        if (ii.obj ~= nil) then
            obj = ii.obj.asButton
        end
        ii.selected = false
    else
        obj = self:GetChildAt(index).asButton
    end

    if (obj ~= nil) then
        obj.selected = false
    end
end

function GList:ClearSelection()
    if (self._virtual) then
        local cnt = self._realNumItems
        for i = 1, cnt do
            local ii = self._virtualItems[i]
            if ii.obj:isa(GButton) then
                ii.obj.selected = false
            end
            ii.selected = false
        end
    else
        local cnt = #self._children
        for i = 1, cnt do
            local obj = self._children[i].asButton
            if (obj ~= nil) then
                obj.selected = false
            end
        end
    end
end

---@param g FairyGUI.GObject
function GList:ClearSelectionExcept(g)
    if (self._virtual) then
        local cnt = self._realNumItems
        for i = 1, cnt do
            local ii = self._virtualItems[i]
            if (ii.obj ~= g) then
                if (ii.obj:isa(GButton)) then
                    ii.obj.selected = false
                end
                ii.selected = false
            end
        end
    else
        local cnt = #self._children
        for i = 1, cnt do
            local obj = self._children[i].asButton
            if (obj ~= nil and obj ~= g) then
                obj.selected = false
            end
        end
    end
end

function GList:SelectAll()
    self:CheckVirtualList()

    local last = -1
    if (self._virtual) then
        local cnt = self._realNumItems
        for i = 1, cnt do
            local ii = self._virtualItems[i]
            if (ii.obj:isa(GButton) and not ii.obj.selected) then
                ii.obj.selected = true
                last = i
            end
            ii.selected = true
        end
    else
        local cnt = #self._children
        for i = 1, cnt do
            local obj = self._children[i].asButton
            if (obj ~= nil and not obj.selected) then
                obj.selected = true
                last = i
            end
        end
    end

    if (last ~= -1) then
        self:UpdateSelectionController(last)
    end
end

function GList:SelectNone()
    self:ClearSelection()
end

function GList:SelectReverse()
    self:CheckVirtualList()

    local last = -1
    if (self._virtual) then
        local cnt = self._realNumItems
        for i = 1, cnt do
            local ii = self._virtualItems[i]
            if (ii.obj:isa(GButton)) then
                ii.obj.selected = not ii.obj.selected
                if (ii.obj.selected) then
                    last = i
                end
            end
            ii.selected = not ii.selected
        end
    else
        local cnt = #self._children
        for i = 1, cnt do
            local obj = self._children[i].asButton
            if (obj ~= nil) then
                obj.selected = not obj.selected
                if (obj.selected) then
                    last = i
                end
            end
        end
    end

    if (last ~= -1) then
        self:UpdateSelectionController(last)
    end
end

---@param dir number
function GList:HandleArrowKey(dir)
    local _layout = self._layout
    local index = self.selectedIndex
    if (index == -1) then
        return
    end

    if dir == 1 then -- up
        if (_layout == ListLayoutType.SingleColumn or _layout == ListLayoutType.FlowVertical) then
            index = index - 1
            if (index >= 1) then
                self:ClearSelection()
                self:AddSelection(index, true)
            end
        elseif (_layout == ListLayoutType.FlowHorizontal or _layout == ListLayoutType.Pagination) then
            local current = self._children[index]
            local k = 0
            local i = index - 1
            while i > 0 do
                local obj = self._children[i]
                if (obj.y ~= current.y) then
                    current = obj
                    break
                end
                k = k + 1
                i = i - 1
            end
            while i > 0 do
                local obj = self._children[i]
                if (obj.y ~= current.y) then
                    self:ClearSelection()
                    self:AddSelection(i + k + 1, true)
                    break
                end
                i = i - 1
            end
        end
    elseif dir == 3 then -- right
        if (_layout == ListLayoutType.SingleRow or _layout == ListLayoutType.FlowHorizontal or _layout == ListLayoutType.Pagination) then
            index = index + 1
            if index <= #self._children then
                self:ClearSelection()
                self:AddSelection(index, true)
            end
        elseif (_layout == ListLayoutType.FlowVertical) then
            local current = self._children[index]
            local k = 0
            local cnt = #self._children
            local i = index + 1
            while i <= cnt do
                local obj = self._children[i]
                if (obj.x ~= current.x) then
                    current = obj
                    break
                end
                k = k + 1
                i = i + 1
            end
            while i <= cnt  do
                local obj = self._children[i]
                if (obj.x ~= current.x) then
                    self:ClearSelection()
                    self:AddSelection(i - k - 1, true)
                    break
                end
                i = i + 1
            end
        end
    elseif dir == 5 then -- down
        if (_layout == ListLayoutType.SingleColumn or _layout == ListLayoutType.FlowVertical) then
            index = index + 1
            if index <= #self._children then
                self:ClearSelection()
                self:AddSelection(index, true)
            end
        elseif (_layout == ListLayoutType.FlowHorizontal or _layout == ListLayoutType.Pagination) then
            local current = self._children[index]
            local k = 0
            local cnt = #self._children
            local i = index + 1
            while i <= cnt do
                local obj = self._children[i]
                if (obj.y ~= current.y) then
                    current = obj
                    break
                end
                k = k + 1
                i = i + 1
            end
            while i <= cnt do
                local obj = self._children[i]
                if (obj.y ~= current.y) then
                    self:ClearSelection()
                    self:AddSelection(i - k - 1, true)
                    break
                end
                i = i + 1
            end
        end
    elseif dir == 7 then -- left
        if (_layout == ListLayoutType.SingleRow or _layout == ListLayoutType.FlowHorizontal or _layout == ListLayoutType.Pagination) then
            index = index - 1
            if (index >= 1) then
                self:ClearSelection()
                self:AddSelection(index, true)
            end
        elseif (_layout == ListLayoutType.FlowVertical) then
            local current = self._children[index]
            local k = 0
            local i = index - 1
            while i >= 1 do
                local obj = self._children[i]
                if (obj.x ~= current.x) then
                    current = obj
                    break
                end
                k = k + 1
                i = i -1
            end
            while i >= 1 do
                local obj = self._children[i]
                if (obj.x ~= current.x) then
                    self:ClearSelection()
                    self:AddSelection(i + k + 1, true)
                    break
                end
                i = i - 1
            end
        end
    end
end

---@param context FairyGUI.EventContext
function GList:__itemTouchBegin(context)
    ---@type FairyGUI.GButton
    local item = context.sender
    if (item == nil or self.selectionMode == ListSelectionMode.None) then
        return
    end

    self._selectionHandled = false

    if (UIConfig.defaultScrollTouchEffect
            and (self.scrollPane ~= nil or self.parent ~= nil and self.parent.scrollPane ~= nil)) then
        return
    end

    if (self.selectionMode == ListSelectionMode.Single) then
        self:SetSelectionOnEvent(item, context.inputEvent)
    else
        if not item.selected then
            self:SetSelectionOnEvent(item, context.inputEvent)
        end
        -- 如果item.selected，这里不处理selection，因为可能用户在拖动
    end
end

---@param context FairyGUI.EventContext
function GList:__clickItem(context)
    ---@type FairyGUI.GObject
    local item = context.sender
    if (not self._selectionHandled) then
        self:SetSelectionOnEvent(item, context.inputEvent)
    end
    self._selectionHandled = false

    if (self.scrollPane ~= nil and self.scrollItemToViewOnClick) then
        self.scrollPane:ScrollToView(item, true)
    end

    if (context.type == item.onRightClick.type) then
        self.onRightClickItem:Call(item)
    else
        self.onClickItem:Call(item)
    end
end

---@param item FairyGUI.GObject
---@param evt FairyGUI.InputEvent
function GList:SetSelectionOnEvent(item, evt)
    if (not item:isa(GButton) or self.selectionMode == ListSelectionMode.None) then
        return
    end

    self._selectionHandled = true
    local dontChangeLastIndex = false
    ---@type FairyGUI.GButton
    local button = item
    local index = self:ChildIndexToItemIndex(self:GetChildIndex(item))

    if (self.selectionMode == ListSelectionMode.Single) then
        if (not button.selected) then
            self:ClearSelectionExcept(button)
            button.selected = true
        end
    else
        if (evt.shift) then
            if (not button.selected) then
                if (self._lastSelectedIndex ~= -1) then
                    local min = math.min(self._lastSelectedIndex, index)
                    local max = math.max(self._lastSelectedIndex, index)
                    max = math.min(max, self.numItems)
                    if (self._virtual) then
                        for i = min, max do
                            local ii = self._virtualItems[i]
                            if ii.obj:isa(GButton) then
                                ii.obj.selected = true
                            end
                            ii.selected = true
                        end
                    else
                        for i = min, max do
                            local obj = self:GetChildAt(i).asButton
                            if (obj ~= nil and not obj.selected) then
                                obj.selected = true
                            end
                        end
                    end

                    dontChangeLastIndex = true
                else
                    button.selected = true
                end
            end
        elseif (evt.ctrl or self.selectionMode == ListSelectionMode.Multiple_SingleClick) then
            button.selected = not button.selected
        else
            if (not button.selected) then
                self:ClearSelectionExcept(button)
                button.selected = true
            else
                self:ClearSelectionExcept(button)
            end
        end
    end

    if (not dontChangeLastIndex) then
        self._lastSelectedIndex = index
    end

    if (button.selected) then
        self:UpdateSelectionController(index)
    end
end

--- Resize to list size to fit specified item count.
--- If list layout is single column or flow horizontally, the height will change to fit.
--- If list layout is single row or flow vertically, the width will change to fit.
---@overload fun(itemCount:number)
---@param itemCount number
---@param minSize number @default: 0
function GList:ResizeToFit(itemCount, minSize)
    minSize = minSize or 0

    local _layout = self._layout

    self:EnsureBoundsCorrect()

    local curCount = self.numItems
    if (itemCount > curCount) then
        itemCount = curCount
    end

    if (self._virtual) then
        local lineCount = math.ceil(itemCount / self._curLineItemCount)
        if (_layout == ListLayoutType.SingleColumn or _layout == ListLayoutType.FlowHorizontal) then
            self.viewHeight = lineCount * self._itemSize.y + math.max(0, lineCount - 1) * self._lineGap
        else
            self.viewWidth = lineCount * self._itemSize.x + math.max(0, lineCount - 1) * self._columnGap
        end
    elseif (itemCount == 0) then
        if (_layout == ListLayoutType.SingleColumn or _layout == ListLayoutType.FlowHorizontal) then
            self.viewHeight = minSize
        else
            self.viewWidth = minSize
        end
    else
        local i = itemCount
        local obj = nil
        while (i >= 1) do
            obj = self:GetChildAt(i)
            if (not self.foldInvisibleItems or obj.visible) then
                break
            end
            i = i - 1
        end
        if (i <= 0) then
            if (_layout == ListLayoutType.SingleColumn or _layout == ListLayoutType.FlowHorizontal) then
                self.viewHeight = minSize
            else
                self.viewWidth = minSize
            end
        else
            local size
            if (_layout == ListLayoutType.SingleColumn or _layout == ListLayoutType.FlowHorizontal) then
                size = obj.y + obj.height
                if (size < minSize) then
                    size = minSize
                end
                self.viewHeight = size
            else
                size = obj.x + obj.width
                if (size < minSize) then
                    size = minSize
                end
                self.viewWidth = size
            end
        end
    end
end

function GList:HandleSizeChanged()
    GComponent.HandleSizeChanged(self)

    self:SetBoundsChangedFlag()
    if self._virtual then
        self:SetVirtualListChangedFlag(true)
    end
end

function GList:HandleControllerChanged(c)
    GComponent.HandleControllerChanged(self, c)

    if self._selectionController then
        self.selectedIndex = c.selectedIndex
    end
end

---@param index number
function GList:UpdateSelectionController(index)
    if (self._selectionController ~= nil and not self._selectionController.changing
            and index < self._selectionController.pageCount) then
        local c = self._selectionController
        self._selectionController = nil
        c.selectedIndex = index
        self._selectionController = c
    end
end

---Scroll the list to make an item with certain index visible.
---@overload fun(index:number)
---@overload fun(index:number, ani:boolean)
---@param index number
---@param ani boolean @default: false
---@param setFirst boolean default: false
function GList:ScrollToView(index, ani, setFirst)
    ani = ani or false
    setFirst = setFirst or false

    local parent = self.parent
    if (self._virtual) then
        if (self._numItems == 0) then
            return
        end

        self:CheckVirtualList()

        if (index > #self._virtualItems) then
            error("Invalid child index: " .. index .. ">" .. #self.self._virtualItems)
        end

        if (self._loop) then
            index = math.floor(self._firstIndex / self._numItems) * self._numItems + index
        end

        local rect
        local ii = self._virtualItems[index]
        if (self._layout == ListLayoutType.SingleColumn or self._layout == ListLayoutType.FlowHorizontal) then
            local pos = 0
            for i = 1, index - 1, self._curLineItemCount do
                pos = pos + self._virtualItems[i].size.y + self._lineGap
            end
            rect = Rect(0, pos, self._itemSize.x, ii.size.y)
        elseif (self._layout == ListLayoutType.SingleRow or self._layout == ListLayoutType.FlowVertical) then
            local pos = 0
            for i = 1, index - 1, self._curLineItemCount do
                pos = pos + self._virtualItems[i].size.x + self._columnGap
            end
            rect = Rect(pos, 0, ii.size.x, self._itemSize.y)
        else
            local page = index / (self._curLineItemCount * self._curLineItemCount2)
            rect = Rect(page * self.viewWidth + (index - 1 % self._curLineItemCount) * (ii.size.x + self._columnGap),
                    (index / self._curLineItemCount) % self._curLineItemCount2 * (ii.size.y + self._lineGap),
                    ii.size.x, ii.size.y)
        end

        setFirst = true --因为在可变item大小的情况下，只有设置在最顶端，位置才不会因为高度变化而改变，所以只能支持setFirst=true
        if (self.scrollPane ~= nil) then
            self.scrollPane:ScrollToView(rect, ani, setFirst)
        elseif (parent ~= nil and parent.scrollPane ~= nil) then
            parent.scrollPane:ScrollToView(self:TransformRect(rect, parent), ani, setFirst)
        end
    else
        local obj = self:GetChildAt(index)
        if (self.scrollPane ~= nil) then
            self.scrollPane:ScrollToView(obj, ani, setFirst)
        elseif (parent ~= nil and parent.scrollPane ~= nil) then
            parent.scrollPane:ScrollToView(obj, ani, setFirst)
        end
    end
end

---@return number
function GList:GetFirstChildInView()
    return self:ChildIndexToItemIndex(GComponent.GetFirstChildInView(self))
end

---@param index number
---@return number @itemIndex
function GList:ChildIndexToItemIndex(index)
    if (not self._virtual) then
        return index
    end

    if (self._layout == ListLayoutType.Pagination) then
        for i = self._firstIndex, self._realNumItems do
            if (self._virtualItems[i].obj ~= nil) then
                index = index - 1
                if (index < 1) then
                    return i
                end
            end
        end

        return index
    else
        index = index + self._firstIndex
        if (self._loop and self._numItems > 0) then
            index = math.module(index, self._numItems)
        end

        return index
    end
end

---@param index number
---@return number @childIndex
function GList:ItemIndexToChildIndex(index)
    if (not self._virtual) then
        return index
    end

    if (self._layout == ListLayoutType.Pagination) then
        return self:GetChildIndex(self._virtualItems[index].obj)
    else
        if (self._loop and self._numItems > 0) then
            local j = math.module(self._firstIndex, self._numItems)
            if (index >= j) then
                index = index - j
            else
                index = self._numItems - j + index
            end
        else
            index = index - self._firstIndex
        end

        return index
    end
end


function GList:SetVirtualAndLoop()
    self:SetVirtual(true)
end

--- Set the list to be virtual list.
--- 设置列表为虚拟列表模式。在虚拟列表模式下，列表不会为每一条列表数据创建一个实体对象，而是根据视口大小创建最小量的显示对象，然后通过itemRenderer指定的回调函数设置列表数据。
--- 在虚拟模式下，你不能通过AddChild、RemoveChild等方式管理列表，只能通过设置numItems设置列表数据的长度。
--- 如果要刷新列表，可以通过重新设置numItems，或者调用RefreshVirtualList完成。
--- ‘单行’或者‘单列’的列表布局可支持不等高的列表项目。
--- 除了‘页面’的列表布局，其他布局均支持使用不同资源构建列表项目，你可以在itemProvider里返回。如果不提供，默认使用defaultItem。
---@overload fun()
---@param loop boolean @default: false
function GList:SetVirtual(loop)
    loop = loop or false

    if not self._virtual then
        if (self.scrollPane == nil) then
            Debug.LogError("FairyGUI: Virtual list must be scrollable!")
        end

        if (loop) then
            if (self._layout == ListLayoutType.FlowHorizontal or self._layout == ListLayoutType.FlowVertical) then
                Debug.LogError("FairyGUI: Loop list is not supported for FlowHorizontal or FlowVertical layout!")
            end

            self.scrollPane.bouncebackEffect = false
        end

        self._virtual = true
        self._loop = loop
        self._virtualItems = {}
        self:RemoveChildrenToPool()

        if (self._itemSize.x == 0 or self._itemSize.y == 0) then
            local obj = self:GetFromPool(nil)
            if (obj == nil) then
                Debug.LogError("FairyGUI: Virtual List must have a default list item resource.")
                self._itemSize = Vector2(100, 100)
            else
                self._itemSize = obj.size
                self._itemSize.x = math.ceil(self._itemSize.x)
                self._itemSize.y = math.ceil(self._itemSize.y)
                self:ReturnToPool(obj)
            end
        end

        if (self._layout == ListLayoutType.SingleColumn or self._layout == ListLayoutType.FlowHorizontal) then
            self.scrollPane.scrollStep = self._itemSize.y
            if (self._loop) then
                self.scrollPane._loop = 2
            end
        else
            self.scrollPane.scrollStep = self._itemSize.x
            if (self._loop) then
                self.scrollPane._loop = 1
            end
        end

        self.scrollPane.onScroll:AddCapture(self.__scrolledDelegate)
        self:SetVirtualListChangedFlag(true)
    end
end

function GList:CheckVirtualList()
    if self._virtualListChanged ~= 0 then
        self:RefreshVirtualList(nil)
        Timers.inst:Remove(self.RefreshVirtualListDelegate)
    end
end

---@param layoutChanged boolean
function GList:SetVirtualListChangedFlag(layoutChanged)
    if (layoutChanged) then
        self._virtualListChanged = 2
    elseif (self._virtualListChanged == 0) then
        self._virtualListChanged = 1
    end

    Timers.inst:CallLater(self.RefreshVirtualListDelegate, self)
end

---@overload fun()
---@param param any
function GList:RefreshVirtualList(param)
    if nil == param then
        if not self._virtual then
            error("FairyGUI: not virtual list")
        end

        self:SetVirtualListChangedFlag(false)
        return
    end

    local layoutChanged = self._virtualListChanged == 2
    self._virtualListChanged = 0
    self._eventLocked = true

    if (layoutChanged) then
        if (self._layout == ListLayoutType.SingleColumn or self._layout == ListLayoutType.SingleRow) then
            self._curLineItemCount = 1
        elseif (self._layout == ListLayoutType.FlowHorizontal) then
            if (self._columnCount > 0) then
                self._curLineItemCount = self._columnCount
            else
                self._curLineItemCount = math.floor((self.scrollPane.viewWidth + self._columnGap) / (self._itemSize.x + self._columnGap))
                if (self._curLineItemCount <= 0) then
                    self._curLineItemCount = 1
                end
            end
        elseif (self._layout == ListLayoutType.FlowVertical) then
            if (self._lineCount > 0) then
                self._curLineItemCount = self._lineCount
            else
                self._curLineItemCount = math.floor((self.scrollPane.viewHeight + self._lineGap) / (self._itemSize.y + self._lineGap))
                if (self._curLineItemCount <= 0) then
                    self._curLineItemCount = 1
                end
            end
        else -- pagination
            if (self._columnCount > 0) then
                self._curLineItemCount = self._columnCount
            else
                self._curLineItemCount = math.floor((self.scrollPane.viewWidth + self._columnGap) / (self._itemSize.x + self._columnGap))
                if (self._curLineItemCount <= 0) then
                    self._curLineItemCount = 1
                end
            end

            if (self._lineCount > 0) then
                self._curLineItemCount2 = self._lineCount
            else
                self._curLineItemCount2 = math.floor((self.scrollPane.viewHeight + self._lineGap) / (self._itemSize.y + self._lineGap))
                if (self._curLineItemCount2 <= 0) then
                    self._curLineItemCount2 = 1
                end
            end
        end
    end

    local ch, cw = 0, 0
    if (self._realNumItems > 0) then
        local len = math.ceil(self._realNumItems / self._curLineItemCount) * self._curLineItemCount
        local len2 = math.min(self._curLineItemCount, self._realNumItems)
        if (self._layout == ListLayoutType.SingleColumn or self._layout == ListLayoutType.FlowHorizontal) then
            for i = 1, len, self._curLineItemCount do
                ch = ch + self._virtualItems[i].size.y + self._lineGap
            end
            if (ch > 0) then
                ch = ch - self._lineGap
            end

            if (self._autoResizeItem) then
                cw = self.scrollPane.viewWidth
            else
                for i = 1, len2 do
                    cw = cw + self._virtualItems[i].size.x + self._columnGap
                end
                if (cw > 0) then
                    cw = cw - self._columnGap
                end
            end
        elseif (self._layout == ListLayoutType.SingleRow or self._layout == ListLayoutType.FlowVertical) then
            for i = 1, len, self._curLineItemCount do
                cw = cw + self._virtualItems[i].size.x + self._columnGap
            end
            if (cw > 0) then
                cw = cw - self._columnGap
            end

            if (self._autoResizeItem) then
                ch = self.scrollPane.viewHeight
            else
                for i = 1, len2 do
                    ch = ch + self._virtualItems[i].size.y + self._lineGap
                end
                if (ch > 0) then
                    ch = ch - self._lineGap
                end
            end
        else
            local pageCount = math.ceil(len / (self._curLineItemCount * self._curLineItemCount2))
            cw = pageCount * self.viewWidth
            ch = self.viewHeight
        end
    end

    self:HandleAlign(cw, ch)
    self.scrollPane:SetContentSize(cw, ch)

    self._eventLocked = false

    self:HandleScroll(true)
end

---@param context FairyGUI.EventContext
function GList:__scrolled(context)
    self:HandleScroll(false)
end

---@param pos number @ref
---@param forceUpdate boolean
---@return number, number @index, pos
function GList:GetIndexOnPos1(pos, forceUpdate)
    if (self._realNumItems < self._curLineItemCount) then
        pos = 0
        return 0, pos
    end

    if (self.numChildren > 0 and not forceUpdate) then
        local pos2 = self:GetChildAt(1).y
        if (pos2 + (self._lineGap > 0 and 0 or -self._lineGap) > pos) then
            for i = self._firstIndex - self._curLineItemCount, 1, -self._curLineItemCount do
                pos2 = pos2 - (self._virtualItems[i].size.y + self._lineGap)
                if (pos2 <= pos) then
                    pos = pos2
                    return i, pos
                end
            end

            pos = 0
            return 0, pos
        else
            local testGap = self._lineGap > 0 and self._lineGap or 0
            for i = self._firstIndex, self._realNumItems, self._curLineItemCount do
                local pos3 = pos2 + self._virtualItems[i].size.y
                if (pos3 + testGap > pos) then
                    pos = pos2
                    return i, pos
                end
                pos2 = pos3 + self._lineGap
            end

            pos = pos2
            return self._realNumItems - self._curLineItemCount, pos
        end
    else
        local pos2 = 0
        local testGap = self._lineGap > 0 and self._lineGap or 0
        for i = 1, self._realNumItems, self._curLineItemCount do
            local pos3 = pos2 + self._virtualItems[i].size.y
            if (pos3 + testGap > pos) then
                pos = pos2
                return i, pos
            end
            pos2 = pos3 + self._lineGap
        end

        pos = pos2
        return self._realNumItems - self._curLineItemCount, pos
    end
end

---@param pos number @ref
---@param forceUpdate boolean
---@return number, number @index, pos
function GList:GetIndexOnPos2(pos, forceUpdate)
    if (self._realNumItems < self._curLineItemCount) then
        pos = 0
        return 0, pos
    end

    if (self.numChildren > 0 and not forceUpdate) then
        local pos2 = self:GetChildAt(1).x
        if (pos2 + (self._columnGap > 0 and 0 or -self._columnGap) > pos) then
            for i = self._firstIndex - self._curLineItemCount, 1, -self._curLineItemCount do
                pos2 = pos2 - (self._virtualItems[i].size.x + self._columnGap)
                if (pos2 <= pos) then
                    pos = pos2
                    return i, pos
                end
            end

            pos = 0
            return 0, pos
        else
            local testGap = self._columnGap > 0 and self._columnGap or 0
            for i = self._firstIndex, self._realNumItems, self._curLineItemCount do
                local pos3 = pos2 + self._virtualItems[i].size.x
                if (pos3 + testGap > pos) then
                    pos = pos2
                    return i, pos
                end
                pos2 = pos3 + self._columnGap
            end

            pos = pos2
            return self._realNumItems - self._curLineItemCount, pos
        end
    else
        local pos2 = 0
        local testGap = self._columnGap > 0 and self._columnGap or 0
        for i = 1, self._realNumItems, self._curLineItemCount do
            local pos3 = pos2 + self._virtualItems[i].size.x
            if (pos3 + testGap > pos) then
                pos = pos2
                return i, pos
            end
            pos2 = pos3 + self._columnGap
        end

        pos = pos2
        return self._realNumItems - self._curLineItemCount, pos
    end
end

---@param pos number @ref
---@param forceUpdate boolean
---@return number, number @index, pos
function GList:GetIndexOnPos3(pos, forceUpdate)
    if (self._realNumItems < self._curLineItemCount) then
        pos = 0
        return 0, pos
    end

    local viewWidth = self.viewWidth
    local page = math.floor(pos / viewWidth)
    local startIndex = page * (self._curLineItemCount * self._curLineItemCount2)
    local pos2 = page * viewWidth
    local testGap = self._columnGap > 0 and self._columnGap or 0
    for i = 1, self._curLineItemCount do
        local pos3 = pos2 + self._virtualItems[startIndex + i].size.x
        if (pos3 + testGap > pos) then
            pos = pos2
            return startIndex + i, pos
        end
        pos2 = pos3 + self._columnGap
    end

    pos = pos2
    return startIndex + self._curLineItemCount - 1, pos
end

---@param forceUpdate boolean
function GList:HandleScroll(forceUpdate)
    local _layout = self._layout
    if self._eventLocked then
        return
    end

    self.enterCounter = 0
    if (_layout == ListLayoutType.SingleColumn or _layout == ListLayoutType.FlowHorizontal) then
        self:HandleScroll1(forceUpdate)
        self:HandleArchOrder1()
    elseif (_layout == ListLayoutType.SingleRow or _layout == ListLayoutType.FlowVertical) then
        self:HandleScroll2(forceUpdate)
        self:HandleArchOrder2()
    else
        self:HandleScroll3(forceUpdate)
    end

    self._boundsChanged = false
end

---@param forceUpdate boolean
function GList:HandleScroll1(forceUpdate)
    local scrollPane = self.scrollPane

    self.enterCounter = self.enterCounter + 1
    if (self.enterCounter > 3) then
        Debug.Log("FairyGUI: list will never be filled as the item renderer function always returns a different size.")
        return
    end

    local pos = scrollPane.scrollingPosY
    local max = pos + scrollPane.viewHeight
    local End = max == scrollPane.contentHeight -- 这个标志表示当前需要滚动到最末，无论内容变化大小

    -- 寻找当前位置的第一条项目
    local newFirstIndex, pos = self:GetIndexOnPos1(pos, forceUpdate)
    if (newFirstIndex == self._firstIndex and not forceUpdate) then
        return
    end

    local oldFirstIndex = self._firstIndex
    self._firstIndex = newFirstIndex
    local curIndex = newFirstIndex
    local forward = oldFirstIndex > newFirstIndex
    local oldCount = self.numChildren
    local lastIndex = oldFirstIndex + oldCount
    local reuseIndex = forward and lastIndex or oldFirstIndex
    local curX, curY = 0, pos
    local needRender
    local deltaSize = 0
    local firstItemDeltaSize = 0
    local url = self.defaultItem
    local partSize = math.floor((scrollPane.viewWidth - self._columnGap * (self._curLineItemCount - 1)) / self._curLineItemCount)

    self.itemInfoVer = self.itemInfoVer + 1
    while (curIndex <= self._realNumItems and (End or curY < max)) do
        local ii = self._virtualItems[curIndex]

        if (ii.obj == nil or forceUpdate) then
            if (self.itemProvider ~= nil) then
                url = self.itemProvider(math.module(curIndex, self._numItems))
                if (url == nil) then
                    url = self.defaultItem
                end
                url = UIPackage.NormalizeURL(url)
            end

            if (ii.obj ~= nil and ii.obj.resourceURL ~= url) then
                if ii.obj:isa(GButton) then
                    ii.selected = ii.obj.selected
                end
                self:RemoveChildToPool(ii.obj)
                ii.obj = nil
            end
        end

        if (ii.obj == nil) then
            -- 搜索最适合的重用item，保证每次刷新需要新建或者重新render的item最少
            if (forward) then
                for j = reuseIndex, oldFirstIndex, -1 do
                    local ii2 = self._virtualItems[j]
                    if (ii2.obj ~= nil and ii2.updateFlag ~= self.itemInfoVer and ii2.obj.resourceURL == url) then
                        if ii2.obj:isa(GButton) then
                            ii2.selected = ii2.obj.selected
                        end
                        ii.obj = ii2.obj
                        ii2.obj = nil
                        if (j == reuseIndex) then
                            reuseIndex = reuseIndex - 1
                        end
                        break
                    end
                end
            else
                for j = reuseIndex, lastIndex do
                    local ii2 = self._virtualItems[j]
                    if (ii2.obj ~= nil and ii2.updateFlag ~= self.itemInfoVer and ii2.obj.resourceURL == url) then
                        if ii2.obj:isa(GButton) then
                            ii2.selected = ii2.obj.selected
                        end
                        ii.obj = ii2.obj
                        ii2.obj = nil
                        if (j == reuseIndex) then
                            reuseIndex = reuseIndex + 1
                        end
                        break
                    end
                end
            end

            if (ii.obj ~= nil) then
                self:SetChildIndex(ii.obj, forward and curIndex - newFirstIndex or self.numChildren)
            else
                ii.obj = self._pool:GetObject(url)
                if (forward) then
                    self:AddChildAt(ii.obj, curIndex - newFirstIndex)
                else
                    self:AddChild(ii.obj)
                end
            end
            if ii.obj:isa(GButton) then
                ii.obj.selected = ii.selected
            end

            needRender = true
        else
            needRender = forceUpdate
        end

        if (needRender) then
            if (self._autoResizeItem and (self._layout == ListLayoutType.SingleColumn or self._columnCount > 0)) then
                ii.obj:SetSize(partSize, ii.obj.height, true)
            end

            self.itemRenderer(math.module(curIndex, self._numItems), ii.obj)
            if (math.module(curIndex, self._curLineItemCount) == 0) then
                deltaSize = deltaSize + math.ceil(ii.obj.size.y) - ii.size.y
                if (curIndex == newFirstIndex and oldFirstIndex > newFirstIndex) then
                    -- 当内容向下滚动时，如果新出现的项目大小发生变化，需要做一个位置补偿，才不会导致滚动跳动
                    firstItemDeltaSize = math.ceil(ii.obj.size.y) - ii.size.y
                end
            end
            ii.size.x = math.ceil(ii.obj.size.x)
            ii.size.y = math.ceil(ii.obj.size.y)
        end

        ii.updateFlag = self.itemInfoVer
        ii.obj:SetXY(curX, curY)
        if (curIndex == newFirstIndex) then  -- 要显示多一条才不会穿帮
            max = max + ii.size.y
        end

        curX = curX + ii.size.x + self._columnGap

        if (math.module(curIndex, self._curLineItemCount) == self._curLineItemCount - 1) then
            curX = 0
            curY = curY + ii.size.y + self._lineGap
        end
        curIndex = curIndex + 1
    end

    for i = 1, oldCount do
        local ii = self._virtualItems[oldFirstIndex + i]
        if (ii.updateFlag ~= self.itemInfoVer and ii.obj ~= nil) then
            if ii.obj:isa(GButton) then
                ii.selected = ii.obj.selected
            end
            self:RemoveChildToPool(ii.obj)
            ii.obj = nil
        end
    end

    if (deltaSize ~= 0 or firstItemDeltaSize ~= 0) then
        self.scrollPane:ChangeContentSizeOnScrolling(0, deltaSize, 0, firstItemDeltaSize)
    end

    if (curIndex > 0 and self.numChildren > 0 and self.container.y < 0 and self:GetChildAt(1).y > -self.container.y) then -- 最后一页没填满！
        self:HandleScroll1(false)
    end
end

---@param forceUpdate boolean
function GList:HandleScroll2(forceUpdate)
    local scrollPane = self.scrollPane

    self.enterCounter = self.enterCounter + 1
    if (self.enterCounter > 3) then
        Debug.Log("FairyGUI: list will never be filled as the item renderer function always returns a different size.")
        return
    end

    local pos = scrollPane.scrollingPosX
    local max = pos + scrollPane.viewWidth
    local End = pos == scrollPane.contentWidth -- 这个标志表示当前需要滚动到最末，无论内容变化大小

    -- 寻找当前位置的第一条项目
    local newFirstIndex, pos = self:GetIndexOnPos2(pos, forceUpdate)
    if (newFirstIndex == self._firstIndex and not forceUpdate) then
        return
    end

    local oldFirstIndex = self._firstIndex
    self._firstIndex = newFirstIndex
    local curIndex = newFirstIndex
    local forward = oldFirstIndex > newFirstIndex
    local oldCount = self.numChildren
    local lastIndex = oldFirstIndex + oldCount
    local reuseIndex = forward and lastIndex or oldFirstIndex
    local curX, curY = pos, 0
    local needRender
    local deltaSize = 0
    local firstItemDeltaSize = 0
    local url = self.defaultItem
    local partSize = math.floor((scrollPane.viewHeight - self._lineGap * (self._curLineItemCount - 1)) / self._curLineItemCount)

    self.itemInfoVer = self.itemInfoVer + 1
    while (curIndex <= self._realNumItems and (End or curX < max)) do
        local ii = self._virtualItems[curIndex]

        if (ii.obj == nil or forceUpdate) then
            if (self.itemProvider ~= nil) then
                url = self.itemProvider(math.module(curIndex, self._numItems))
                if (url == nil) then
                    url = self.defaultItem
                end
                url = UIPackage.NormalizeURL(url)
            end

            if (ii.obj ~= nil and ii.obj.resourceURL ~= url) then
                if ii.obj:isa(GButton) then
                    ii.selected = ii.obj.selected
                end
                self:RemoveChildToPool(ii.obj)
                ii.obj = nil
            end
        end

        if (ii.obj == nil) then
            if (forward) then
                for j = reuseIndex, oldFirstIndex, -1 do
                    local ii2 = self._virtualItems[j]
                    if (ii2.obj ~= nil and ii2.updateFlag ~= self.itemInfoVer and ii2.obj.resourceURL == url) then
                        if ii2.obj:isa(GButton) then
                            ii2.selected = ii2.obj.selected
                        end
                        ii.obj = ii2.obj
                        ii2.obj = nil
                        if (j == reuseIndex) then
                            reuseIndex = reuseIndex - 1
                        end
                        break
                    end
                end
            else
                for j = reuseIndex, lastIndex do
                    local ii2 = self._virtualItems[j]
                    if (ii2.obj ~= nil and ii2.updateFlag ~= self.itemInfoVer and ii2.obj.resourceURL == url) then
                        if ii2.obj:isa(GButton) then
                            ii2.selected = ii2.obj.selected
                        end
                        ii.obj = ii2.obj
                        ii2.obj = nil
                        if (j == reuseIndex) then
                            reuseIndex = reuseIndex + 1
                        end
                        break
                    end
                end
            end

            if (ii.obj ~= nil) then
                self:SetChildIndex(ii.obj, forward and curIndex - newFirstIndex or self.numChildren)
            else
                ii.obj = self._pool:GetObject(url)
                if (forward) then
                    self:AddChildAt(ii.obj, curIndex - newFirstIndex)
                else
                    self:AddChild(ii.obj)
                end
            end
            if ii.obj:isa(GButton) then
                ii.obj.selected = ii.selected
            end

            needRender = true
        else
            needRender = forceUpdate
        end

        if (needRender) then
            if (self._autoResizeItem and (self._layout == ListLayoutType.SingleRow or self._lineCount > 0)) then
                ii.obj:SetSize(ii.obj.width, partSize, true)
            end

            self.itemRenderer(math.module(curIndex, self._numItems), ii.obj)
            if (math.module(curIndex, self._curLineItemCount) == 0) then
                deltaSize = deltaSize + math.ceil(ii.obj.size.x) - ii.size.x
                if (curIndex == newFirstIndex and oldFirstIndex > newFirstIndex) then
                    -- 当内容向下滚动时，如果新出现的项目大小发生变化，需要做一个位置补偿，才不会导致滚动跳动
                    firstItemDeltaSize = math.ceil(ii.obj.size.x) - ii.size.x
                end
            end
            ii.size.x = math.ceil(ii.obj.size.x)
            ii.size.y = math.ceil(ii.obj.size.y)
        end

        ii.updateFlag = self.itemInfoVer
        ii.obj:SetXY(curX, curY)
        if (curIndex == newFirstIndex) then  -- 要显示多一条才不会穿帮
            max = max + ii.size.x
        end

        curY = curY + ii.size.y + self._lineGap

        if (math.module(curIndex, self._curLineItemCount) == self._curLineItemCount - 1) then
            curY = 0
            curX = curX + ii.size.x + self._columnGap
        end
        curIndex = curIndex + 1
    end

    for i = 1, oldCount do
        local ii = self._virtualItems[oldFirstIndex + i]
        if (ii.updateFlag ~= self.itemInfoVer and ii.obj ~= nil) then
            if ii.obj:isa(GButton) then
                ii.selected = ii.obj.selected
            end
            self:RemoveChildToPool(ii.obj)
            ii.obj = nil
        end
    end

    if (deltaSize ~= 0 or firstItemDeltaSize ~= 0) then
        self.scrollPane:ChangeContentSizeOnScrolling(deltaSize, 0, firstItemDeltaSize, 0)
    end

    if (curIndex > 0 and self.numChildren > 0 and self.container.x < 0 and self:GetChildAt(1).x > -self.container.x) then -- 最后一页没填满！
        self:HandleScroll2(false)
    end
end

---@param forceUpdate boolean
function GList:HandleScroll3(forceUpdate)
    local scrollPane = self.scrollPane
    local pos = scrollPane.scrollingPosX

    -- 寻找当前位置的第一条项目
    local newFirstIndex, pos = self:GetIndexOnPos3(pos, forceUpdate)
    if (newFirstIndex == self._firstIndex and not forceUpdate) then
        return
    end

    local oldFirstIndex = self._firstIndex
    self._firstIndex = newFirstIndex

    -- 分页模式不支持不等高，所以渲染满一页就好了

    local reuseIndex = oldFirstIndex
    local virtualItemCount = #self._virtualItems
    local pageSize = self._curLineItemCount * self._curLineItemCount2
    local startCol = math.module(newFirstIndex, self._curLineItemCount)
    local viewWidth = self.viewWidth
    local page = math.floor(newFirstIndex / pageSize)
    local startIndex = page * pageSize + 1
    local lastIndex = startIndex + pageSize * 2 -- 测试两页
    local needRender
    local url = self.defaultItem
    local partWidth = math.floor((scrollPane.viewWidth - self._columnGap * (self._curLineItemCount - 1)) / self._curLineItemCount)
    local partHeight = math.floor((scrollPane.viewHeight - self._lineGap * (self._curLineItemCount2 - 1)) / self._curLineItemCount2)
    self.itemInfoVer = self.itemInfoVer + 1

    -- 先标记这次要用到的项目
    for i = startIndex, lastIndex do
        if (i >= self._realNumItems) then
            --continue
        else
            local continue = false
            local col = math.module(i, self._curLineItemCount)
            if (i - startIndex < pageSize) then
                if (col < startCol) then
                    continue = true
                end
            else
                if (col > startCol) then
                    continue = true
                end
            end
            if not continue then
                local ii = self._virtualItems[i]
                ii.updateFlag = self.itemInfoVer
            end
        end
    end

    local lastObj = nil
    local insertIndex = 0
    for i = startIndex,  lastIndex do
        if (i > self._realNumItems) then
            --continue
        else
            local ii = self._virtualItems[i]
            if (ii.updateFlag ~= self.itemInfoVer) then
                --continue
            else
                if (ii.obj == nil) then
                    -- 寻找看有没有可重用的
                    while (reuseIndex < virtualItemCount) do
                        local ii2 = self._virtualItems[reuseIndex]
                        if (ii2.obj ~= nil and ii2.updateFlag ~= self.itemInfoVer) then
                            if ii2.obj:isa(GButton) then
                                ii2.selected = ii2.obj.selected
                            end
                            ii.obj = ii2.obj
                            ii2.obj = nil
                            break
                        end
                        reuseIndex = reuseIndex + 1
                    end

                    if (insertIndex == -1) then
                        insertIndex = self:GetChildIndex(lastObj) + 1
                    end

                    if (ii.obj == nil) then
                        if (self.itemProvider ~= nil) then
                            url = self.itemProvider(math.module(i, _numItems))
                            if (url == nil) then
                                url = self.defaultItem
                            end
                            url = UIPackage.NormalizeURL(url)
                        end

                        ii.obj = self._pool:GetObject(url)
                        self:AddChildAt(ii.obj, insertIndex)
                    else
                        insertIndex = self:SetChildIndexBefore(ii.obj, insertIndex)
                    end
                    insertIndex = insertIndex + 1

                    if ii.obj:isa(GButton) then
                        ii.obj.selected = ii.selected
                    end

                    needRender = true
                else
                    needRender = forceUpdate
                    insertIndex = -1
                    lastObj = ii.obj
                end

                if (needRender) then
                    if (self._autoResizeItem) then
                        if (self._curLineItemCount == self._columnCount and self._curLineItemCount2 == self._lineCount) then
                            ii.obj:SetSize(partWidth, partHeight, true)
                        elseif (self._curLineItemCount == self._columnCount) then
                            ii.obj:SetSize(partWidth, ii.obj.height, true)
                        elseif (self._curLineItemCount2 == self._lineCount) then
                            ii.obj:SetSize(ii.obj.width, partHeight, true)
                        end
                    end

                    self.itemRenderer(math.module(i, self._numItems), ii.obj)
                    ii.size.x = math.ceil(ii.obj.size.x)
                    ii.size.y = math.ceil(ii.obj.size.y)
                end
            end
        end
    end

    -- 排列item
    local borderX = (startIndex / pageSize) * viewWidth
    local xx = borderX
    local yy = 0
    local lineHeight = 0
    for i = startIndex, lastIndex do
        if (i > self._realNumItems) then
            --continue
        else
            local ii = self._virtualItems[i]
            if (ii.updateFlag == self.itemInfoVer) then
                ii.obj:SetXY(xx, yy)
            end

            if (ii.size.y > lineHeight) then
                lineHeight = ii.size.y
            end
            if (math.module(i, self._curLineItemCount) == self._curLineItemCount) then
                xx = borderX
                yy = yy + lineHeight + self._lineGap
                lineHeight = 0

                if (i == startIndex + pageSize - 1) then
                    borderX = borderX + viewWidth
                    xx = borderX
                    yy = 0
                end
            else
                xx = xx + ii.size.x + self._columnGap
            end
        end
    end

    -- 释放未使用的
    for i = reuseIndex, virtualItemCount do
        local ii = self._virtualItems[i]
        if (ii.updateFlag ~= self.itemInfoVer and ii.obj ~= nil) then
            if ii.obj:isa(GButton) then
                ii.selected = ii.obj.selected
            end
            self:RemoveChildToPool(ii.obj)
            ii.obj = nil
        end
    end
end

function GList:HandleArchOrder1()
    if (self.childrenRenderOrder == ChildrenRenderOrder.Arch) then
        local mid = self.scrollPane.posY + self.viewHeight / 2
        local minDist = math.maxval, self.dist
        local apexIndex = 1
        local cnt = self.numChildren
        for i = 1, cnt do
            local obj = self:GetChildAt(i)
            if (not self.foldInvisibleItems or obj.visible) then
                self.dist = math.abs(mid - obj.y - obj.height / 2)
                if (self.dist < minDist) then
                    minDist = self.dist
                    apexIndex = i
                end
            end
        end
        self.apexIndex = apexIndex
    end
end

function GList:HandleArchOrder2()
    if (self.childrenRenderOrder == ChildrenRenderOrder.Arch) then
        local mid = self.scrollPane.posX + self.viewWidth / 2
        local minDist = math.maxval, self.dist
        local apexIndex = 1
        local cnt = self.numChildren
        for i = 1, cnt do
            local obj = self:GetChildAt(i)
            if (not self.foldInvisibleItems or obj.visible) then
                self.dist = math.abs(mid - obj.x - obj.width / 2)
                if (self.dist < minDist) then
                    minDist = self.dist
                    apexIndex = i
                end
            end
        end
        self.apexIndex = apexIndex
    end
end

---@param xValue number @ref
---@param yValue number @ref
---@return number, number
function GList:GetSnappingPosition(xValue, yValue)
    if (self._virtual) then
        if (self._layout == ListLayoutType.SingleColumn or self._layout == ListLayoutType.FlowHorizontal) then
            local saved = yValue
            local index, yValue = self:GetIndexOnPos1(yValue, false)
            if (index < self._virtualItems.Count and saved - yValue > self._virtualItems[index].size.y / 2 and index < self._realNumItems) then
                yValue = yValue + self._virtualItems[index].size.y + self._lineGap
            end
        elseif (self._layout == ListLayoutType.SingleRow or self._layout == ListLayoutType.FlowVertical) then
            local saved = xValue
            local index, xValue = self:GetIndexOnPos2(xValue, false)
            if (index < self._virtualItems.Count and saved - xValue > self._virtualItems[index].size.x / 2 and index < self._realNumItems) then
                xValue = xValue + self._virtualItems[index].size.x + self._columnGap
            end
        else
            local saved = xValue
            local index, xValue = self:GetIndexOnPos3(xValue, false)
            if (index < self._virtualItems.Count and saved - xValue > self._virtualItems[index].size.x / 2 and index < self._realNumItems) then
                xValue = xValue + self._virtualItems[index].size.x + self._columnGap
            end
        end

        return xValue, yValue
    else
        return GComponent.GetSnappingPosition(self, xValue, yValue)
    end
end

---@param contentWidth number
---@param contentHeight number
function GList:HandleAlign(contentWidth, contentHeight)
    local newOffset = Vector2.zero

    if (contentHeight < self.viewHeight) then
        if (self._verticalAlign == VertAlignType.Middle) then
            newOffset.y = math.floor((self.viewHeight - contentHeight) / 2)
        elseif (self._verticalAlign == VertAlignType.Bottom) then
            newOffset.y = self.viewHeight - contentHeight
        end
    end

    if (contentWidth < self.viewWidth) then
        if (self._align == AlignType.Center) then
            newOffset.x = math.floor((self.viewWidth - contentWidth) / 2)
        elseif (self._align == AlignType.Right) then
            newOffset.x = self.viewWidth - contentWidth
        end
    end

    if (newOffset ~= self._alignOffset) then
        self._alignOffset = newOffset
        if (self.scrollPane ~= nil) then
            self.scrollPane:AdjustMaskContainer()
        else
            self.container:SetXY(self._margin.left + self._alignOffset.x, self._margin.top + self._alignOffset.y)
        end
    end
end

function GList:UpdateBounds()
    if self._virtual then
        return
    end

    local cnt = #self._children
    local j = 0
    local child
    local curX = 0
    local curY = 0
    local cw, ch
    local maxWidth = 0
    local maxHeight = 0
    local viewWidth = self.viewWidth
    local viewHeight = self.viewHeight

    if (self._layout == ListLayoutType.SingleColumn) then
        for i = 1, cnt do
            child = self:GetChildAt(i)
            if (self.foldInvisibleItems and not child.visible) then
                --continue
            else
                if (curY ~= 0) then
                    curY = curY + self._lineGap
                end
                child.y = curY
                if (self._autoResizeItem) then
                    child:SetSize(viewWidth, child.height, true)
                end
                curY = curY + math.ceil(child.height)
                if (child.width > maxWidth) then
                    maxWidth = child.width
                end
            end
        end
        cw = math.ceil(maxWidth)
        ch = curY
    elseif (self._layout == ListLayoutType.SingleRow) then
        for i = 1, cnt do
            child = self:GetChildAt(i)
            if (self.foldInvisibleItems and not child.visible) then
                --continue
            else
                if (curX ~= 0) then
                    curX = curX + self._columnGap
                end
                child.x = curX
                if (self._autoResizeItem) then
                    child:SetSize(child.width, viewHeight, true)
                end
                curX = curX + math.ceil(child.width)
                if (child.height > maxHeight) then
                    maxHeight = child.height
                end
            end
        end
        cw = curX
        ch = math.ceil(maxHeight)
    elseif (self._layout == ListLayoutType.FlowHorizontal) then
        if (self._autoResizeItem and self._columnCount > 0) then
            local lineSize = 0
            local lineStart = 0
            local ratio

            for i = 1, cnt do
                child = self:GetChildAt(i)
                if (self.foldInvisibleItems and not child.visible) then
                    --continue
                else
                    lineSize = lineSize + child.sourceWidth
                    j = j + 1
                    if (j == self._columnCount or i == cnt - 1) then
                        ratio = (viewWidth - lineSize - (j - 1) * self._columnGap) / lineSize
                        curX = 0
                        for j = lineStart, i  do
                            child = self:GetChildAt(j)
                            if (self.foldInvisibleItems and not child.visible) then
                                --continue
                            else
                                child:SetXY(curX, curY)

                                if (j < i) then
                                    child:SetSize(child.sourceWidth + math.round(child.sourceWidth * ratio), child.height, true)
                                    curX = curX + math.ceil(child.width) + self._columnGap
                                else
                                    child:SetSize(viewWidth - curX, child.height, true)
                                end
                                if (child.height > maxHeight) then
                                    maxHeight = child.height
                                end
                            end
                        end
                        -- new line
                        curY = curY + math.ceil(maxHeight) + self._lineGap
                        maxHeight = 0
                        j = 0
                        lineStart = i + 1
                        lineSize = 0
                    end
                end
            end
            ch = curY + math.ceil(maxHeight)
            cw = viewWidth
        else
            for i = 1, cnt do
                child = self:GetChildAt(i)
                if (self.foldInvisibleItems and not child.visible) then
                    --continue
                else
                    if (curX ~= 0) then
                        curX = curX + self._columnGap
                    end

                    if (self._columnCount ~= 0 and j >= self._columnCount
                            or self._columnCount == 0 and curX + child.width > viewWidth and maxHeight ~= 0) then
                        -- new line
                        curX = 0
                        curY = curY + math.ceil(maxHeight) + self._lineGap
                        maxHeight = 0
                        j = 0
                    end
                    child:SetXY(curX, curY)
                    curX = curX + math.ceil(child.width)
                    if (curX > maxWidth) then
                        maxWidth = curX
                    end
                    if (child.height > maxHeight) then
                        maxHeight = child.height
                    end
                    j = j + 1
                end
            end
            ch = curY + math.ceil(maxHeight)
            cw = math.ceil(maxWidth)
        end

    elseif (self._layout == ListLayoutType.FlowVertical) then
        if (self._autoResizeItem and self._lineCount > 0) then
            local lineSize = 0
            local lineStart = 0
            local ratio

            for i = 1, cnt do
                child = self:GetChildAt(i)
                if (self.foldInvisibleItems and not child.visible) then
                    --continue
                else
                    lineSize = lineSize + child.sourceHeight
                    j = j + 1
                    if (j == self._lineCount or i == cnt - 1) then
                        ratio = (viewHeight - lineSize - (j - 1) * self._lineGap) / lineSize
                        curY = 0
                        for j = lineStart, i do
                            child = self:GetChildAt(j)
                            if (self.foldInvisibleItems and not child.visible) then
                                --continue
                            else
                                child:SetXY(curX, curY)

                                if (j < i) then
                                    child:SetSize(child.width, child.sourceHeight + math.round(child.sourceHeight * ratio), true)
                                    curY = curY + math.ceil(child.height) + self._lineGap
                                else
                                    child:SetSize(child.width, viewHeight - curY, true)
                                end
                                if (child.width > maxWidth) then
                                    maxWidth = child.width
                                end
                            end
                        end
                        -- new line
                        curX = curX + math.ceil(maxWidth) + self._columnGap
                        maxWidth = 0
                        j = 0
                        lineStart = i + 1
                        lineSize = 0
                    end
                end
            end
            cw = curX + math.ceil(maxWidth)
            ch = viewHeight
        else
            for i = 1, cnt do
                child = self:GetChildAt(i)
                if (self.foldInvisibleItems and not child.visible) then
                    --continue
                else
                    if (curY ~= 0) then
                        curY = curY + self._lineGap
                    end

                    if (self._lineCount ~= 0 and j >= self._lineCount
                            or self._lineCount == 0 and curY + child.height > viewHeight and maxWidth ~= 0) then
                        curY = 0
                        curX = curX + math.ceil(maxWidth) + self._columnGap
                        maxWidth = 0
                        j = 0
                    end
                    child:SetXY(curX, curY)
                    curY = curY + child.height
                    if (curY > maxHeight) then
                        maxHeight = curY
                    end
                    if (child.width > maxWidth) then
                        maxWidth = child.width
                    end
                    j = j + 1
                end
            end
            cw = curX + math.ceil(maxWidth)
            ch = math.ceil(maxHeight)
        end

    else -- pagination
        local page = 0
        local k = 0
        local eachHeight = 0
        if (self._autoResizeItem and self._lineCount > 0) then
            eachHeight = math.floor((viewHeight - (self._lineCount - 1) * self._lineGap) / self._lineCount)
        end

        if (self._autoResizeItem and self._columnCount > 0) then
            local lineSize = 0
            local lineStart = 0
            local ratio

            for i = 1, cnt do
                child = self:GetChildAt(i)
                if (self.foldInvisibleItems and not child.visible) then
                    --continue
                else
                    if (j == 0 and (self._lineCount ~= 0 and k >= self._lineCount
                            or self._lineCount == 0 and curY + (self._lineCount > 0 and eachHeight or child.height) > viewHeight)) then
                        -- new page
                        page = page + 1
                        curY = 0
                        k = 0
                    end

                    lineSize = lineSize + child.sourceWidth
                    j = j + 1
                    if (j == self._columnCount or i == cnt - 1) then
                        ratio = (viewWidth - lineSize - (j - 1) * self._columnGap) / lineSize
                        curX = 0
                        for j = lineStart, i do
                            child = self:GetChildAt(j)
                            if (self.foldInvisibleItems and not child.visible) then
                                --continue
                            else
                                child:SetXY(page * viewWidth + curX, curY)

                                if (j < i) then
                                    child:SetSize(child.sourceWidth + math.round(child.sourceWidth * ratio),
                                            self._lineCount > 0 and eachHeight or child.height, true)
                                curX = curX + math.ceil(child.width) + self._columnGap
                                else
                                    child:SetSize(viewWidth - curX, self._lineCount > 0 and eachHeight or child.height, true)
                                end
                                if (child.height > maxHeight) then
                                    maxHeight = child.height
                                end
                            end
                        end
                        -- new line
                        curY = curY + math.ceil(maxHeight) + self._lineGap
                        maxHeight = 0
                        j = 0
                        lineStart = i + 1
                        lineSize = 0

                        k = k + 1
                    end
                end
            end
        else
            for i = 1, cnt do
                child = self:GetChildAt(i)
                if (self.foldInvisibleItems and not child.visible) then
                    --continue
                else
                    if (curX ~= 0) then
                        curX = curX + self._columnGap
                    end

                    if (self._autoResizeItem and self._lineCount > 0) then
                        child:SetSize(child.width, eachHeight, true)
                    end

                    if (self._columnCount ~= 0 and j >= self._columnCount
                            or self._columnCount == 0 and curX + child.width > viewWidth and maxHeight ~= 0) then
                        curX = 0
                        curY = curY + maxHeight + self._lineGap
                        maxHeight = 0
                        j = 0
                        k = k + 1

                        if (self._lineCount ~= 0 and k >= self._lineCount
                                or self._lineCount == 0 and curY + child.height > viewHeight and maxWidth ~= 0) then -- new page
                            page = page + 1
                            curY = 0
                            k = 0
                        end
                    end
                    child:SetXY(page * viewWidth + curX, curY)
                    curX = curX + math.ceil(child.width)
                    if (curX > maxWidth) then
                        maxWidth = curX
                    end
                    if (child.height > maxHeight) then
                        maxHeight = child.height
                    end
                    j = j + 1
                end
            end
        end
        ch = page > 0 and viewHeight or (curY + math.ceil(maxHeight))
        cw = (page + 1) * viewWidth
    end

    self:HandleAlign(cw, ch)
    self:SetBounds(0, 0, cw, ch)

    self:InvalidateBatchingState(true)
end

function GList:Setup_BeforeAdd(buffer, beginPos)
    GComponent.Setup_BeforeAdd(self, buffer, beginPos)

    buffer:Seek(beginPos, 5)

    self._layout = buffer:ReadByte()
    self.selectionMode = buffer:ReadByte()
    self._align = buffer:ReadByte()
    self._verticalAlign = buffer:ReadByte()
    self._lineGap = buffer:ReadShort()
    self._columnGap = buffer:ReadShort()
    self._lineCount = buffer:ReadShort()
    self._columnCount = buffer:ReadShort()
    self._autoResizeItem = buffer:ReadBool()
    self._childrenRenderOrder = buffer:ReadByte()
    self._apexIndex = buffer:ReadShort()

    if (buffer:ReadBool()) then
        self._margin.top = buffer:ReadInt()
        self._margin.bottom = buffer:ReadInt()
        self._margin.left = buffer:ReadInt()
        self._margin.right = buffer:ReadInt()
    end

    local overflow = buffer:ReadByte()
    if (overflow == OverflowType.Scroll) then
        local savedPos = buffer.position
        buffer:Seek(beginPos, 7)
        self:SetupScroll(buffer)
        buffer.position = savedPos
    else
        self:SetupOverflow(overflow)
    end

    if (buffer:ReadBool()) then
        local i1 = buffer:ReadInt()
        local i2 = buffer:ReadInt()
        self.clipSoftness = Vector2(i1, i2)
    end

    buffer:Seek(beginPos, 8)

    self.defaultItem = buffer:ReadS()
    local itemCount = buffer:ReadShort()
    for i = 1, itemCount do
        local nextPos = buffer:ReadShort()
        nextPos = nextPos + buffer.position

        local continue = false
        local str = buffer:ReadS()
        if (str == nil) then
            str = self.defaultItem
            if (string.isNullOrEmpty(str)) then
                buffer.position = nextPos
                continue = true
            end
        end
        if not continue then
            local obj = self:GetFromPool(str)
            if (obj ~= nil) then
                self:AddChild(obj)
                str = buffer:ReadS()
                if (str ~= nil) then
                    obj.text = str
                end
                str = buffer:ReadS()
                if (str ~= nil and obj:isa(GButton)) then
                    obj.selectedTitle = str
                end
                str = buffer:ReadS()
                if (str ~= nil) then
                    obj.icon = str
                end
                str = buffer:ReadS()
                if (str ~= nil and obj:isa(GButton)) then
                    obj.selectedIcon = str
                end
                str = buffer:ReadS()
                if (str ~= nil) then
                    obj.name = str
                end
                if obj:isa(GComponent) then
                    local cnt = buffer:ReadShort()
                    for j = 1, cnt do
                        local cc = obj:GetController(buffer:ReadS())
                        str = buffer:ReadS()
                        if (cc ~= nil) then
                            cc.selectedPageId = str
                        end
                    end
                end
            end

            buffer.position = nextPos
        end
    end
end

function GList:Setup_AfterAdd(buffer, beginPos)
    GComponent.Setup_AfterAdd(self, buffer, beginPos)

    buffer:Seek(beginPos, 6)

    local i = buffer:ReadShort()
    if i ~= -1 then
        self._selectionController = self.parent:GetController(i + 1)
    end
end
--endregion


--region FairyGUI.GList 类属性
local __get = Class.init_get(GList)
local __set = Class.init_set(GList)

---@param self FairyGUI.GList
__get.layout = function(self) return self._layout end

---@param self FairyGUI.GList
---@param val FairyGUI.ListLayoutType
__set.layout = function(self, val)
    if self._layout ~= val then
        self._layout = val
        self:SetBoundsChangedFlag()
        if self._virtual then
            self:SetVirtualListChangedFlag(true)
        end
    end
end

---@param self FairyGUI.GList
__get.lineCount = function(self) return self._lineCount end

---@param self FairyGUI.GList
---@param val number
__set.lineCount = function(self, val)
    if self._lineCount ~= val then
        self._lineCount = val
        if self._layout == ListLayoutType.FlowVertical or self._layout == ListLayoutType.Pagination then
            self:SetBoundsChangedFlag()
            if self._virtual then
                self:SetVirtualListChangedFlag(true)
            end
        end
    end
end

---@param self FairyGUI.GList
__get.columnCount = function(self) return self._columnCount end

---@param self FairyGUI.GList
---@param val number
__set.columnCount = function(self, val)
    if (self._columnCount ~= val) then
        self._columnCount = val
        if (self._layout == ListLayoutType.FlowHorizontal or self._layout == ListLayoutType.Pagination) then
            self:SetBoundsChangedFlag()
            if (self._virtual) then
                self:SetVirtualListChangedFlag(true)
            end
        end
    end
end

---@param self FairyGUI.GList
__get.lineGap = function(self) return self._lineGap end

---@param self FairyGUI.GList
---@param val number
__set.lineGap = function(self, val)
    if (self._lineGap ~= val) then
        self._lineGap = val
        self:SetBoundsChangedFlag()
        if (self._virtual) then
            self:SetVirtualListChangedFlag(true)
        end
    end
end

---@param self FairyGUI.GList
__get.columnGap = function(self) return self._columnGap end

---@param self FairyGUI.GList
---@param val number
__set.columnGap = function(self, val)
    if (self._columnGap ~= val) then
        self._columnGap = val
        self:SetBoundsChangedFlag()
        if (self._virtual) then
            self:SetVirtualListChangedFlag(true)
        end
    end
end

---@param self FairyGUI.GList
__get.align = function(self) return self._align end

---@param self FairyGUI.GList
---@param val FairyGUI.AlignType
__set.align = function(self, val)
    if (self._align ~= val) then
        self._align = val
        self:SetBoundsChangedFlag()
        if (self._virtual) then
            self:SetVirtualListChangedFlag(true)
        end
    end
end

---@param self FairyGUI.GList
__get.verticalAlign = function(self) return self._verticalAlign end

---@param self FairyGUI.GList
---@param val FairyGUI.VertAlignType
__set.verticalAlign = function(self, val)
    if (self._verticalAlign ~= val) then
        self._verticalAlign = val
        self:SetBoundsChangedFlag()
        if (self._virtual) then
            self:SetVirtualListChangedFlag(true)
        end
    end
end

---@param self FairyGUI.GList
__get.autoResizeItem = function(self) return self._autoResizeItem end

---@param self FairyGUI.GList
---@param val boolean
__set.autoResizeItem = function(self, val)
    if (self._autoResizeItem ~= val) then
        self._autoResizeItem = val
        self:SetBoundsChangedFlag()
        if (self._virtual) then
            self:SetVirtualListChangedFlag(true)
        end
    end
end

---@param self FairyGUI.GList
__get.itemPool = function(self) return self._pool end

---@param self FairyGUI.GList
__get.selectedIndex = function(self)
    if (self._virtual) then
        local cnt = self._realNumItems
        for i = 1, cnt do
            local ii = self._virtualItems[i]
            if (ii.obj:isa(GButton) and ii.obj.selected
                    or ii.obj == nil and ii.selected) then
                if (self._loop) then
                    return math.module(i, self._numItems)
                else
                    return i
                end
            end
        end
    else
        local cnt = #self._children
        for i = 1, cnt do
            local obj = self._children[i].asButton
            if (obj ~= nil and obj.selected) then
                return i
            end
        end
    end
    return -1
end

---@param self FairyGUI.GList
---@param val number
__set.selectedIndex = function(self, val)
    if (val >= 0 and val < self.numItems) then
        if (self.selectionMode ~= ListSelectionMode.Single) then
            self:ClearSelection()
        end
        self:AddSelection(val, false)
    else
        self:ClearSelection()
    end
end

---@param self FairyGUI.GList
__get.selectionController = function(self) return self._selectionController end

---@param self FairyGUI.GList
---@param val FairyGUI.Controller
__set.selectionController = function(self, val) self._selectionController = val end

---@param self FairyGUI.GList
__get.touchItem = function(self)
    -- find out which item is under finger
    -- 逐层往上知道查到点击了那个item
    local obj = GRoot.inst.touchTarget
    local p = obj.parent
    while (p ~= nil) do
        if (p == self) then
            return obj
        end

        obj = p
        p = p.parent
    end

    return nil
end

---@param self FairyGUI.GList
__get.isVirtual = function(self) return self._virtual end

---@param self FairyGUI.GList
__get.numItems = function(self)
    if self._virtual then
        return self._numItems
    end
    return #self._children
end

---@param self FairyGUI.GList
---@param val number
__set.numItems = function(self, val)
    if (self._virtual) then
        if (self.itemRenderer == nil) then
            error("FairyGUI: Set itemRenderer first!")
        end

        self._numItems = val
        if (self._loop) then
            self._realNumItems = self._numItems * 6 -- 设置6倍数量，用于循环滚动
        else
            self._realNumItems = self._numItems
        end

        -- _virtualItems的设计是只增不减的
        local oldCount = #self._virtualItems
        if (self._realNumItems > oldCount) then
            for i = oldCount + 1, self._realNumItems do
                local ii = ItemInfo.new()
                ii.size = self._itemSize

                self._virtualItems:Add(ii)
            end
        else
            for i = self._realNumItems + 1, oldCount do
                self._virtualItems[i].selected = false
            end
        end

        if (self.self._virtualListChanged ~= 0) then
            Timers.inst:Remove(self.RefreshVirtualListDelegate)
        end
        -- 立即刷新
        self:RefreshVirtualList(nil)
    else
        local cnt = #self._children
        if (val > cnt) then
            for i = cnt + 1, val do
                if (self.itemProvider == nil) then
                    self:AddItemFromPool()
                else
                    self:AddItemFromPool(self.itemProvider(i))
                end
            end
        else
            self:RemoveChildrenToPool(val, cnt)
        end

        if (self.itemRenderer ~= nil) then
            for i = 1, val do
                self.itemRenderer(i, self:GetChildAt(i))
            end
        end
    end
end
--endregion

GList.ItemInfo = ItemInfo
FairyGUI.GList = GList
FairyGUI.ListItemRenderer = ListItemRenderer
FairyGUI.ListItemProvider = ListItemProvider
return GList