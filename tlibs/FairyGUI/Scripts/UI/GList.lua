--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:36
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

local GComponent = FairyGUI.GComponent

---@class FairyGUI.ListItemRenderer:Delegate @fun(index:number, item:FairyGUI.GObject)
local ListItemRenderer = Delegate.newDelegate('ListItemRenderer')

---@class FairyGUI.ListItemProvider:Delegate @fun(index:number):string
local ListItemProvider = Delegate.newDelegate('ListItemProvider')

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

---@class FairyGUI.GList.ItemInfo:ClassType
---@field public size Love2DEngine.Vector2
---@field public obj FairyGUI.GObject
---@field public updateFlag number
---@field public selected boolean
local ItemInfo = Class.inheritsFrom('ItemInfo')


function GList.__ctor()
    GComponent.__ctor(self)
end

function GList:Dispose()
end

---@param url string
---@return FairyGUI.GObject
function GList:GetFromPool(url) end

---@param obj FairyGUI.GObject
function GList:ReturnToPool(obj) end

---@overload fun()
---@param url string
---@return FairyGUI.GObject
function GList:AddItemFromPool(url) end

function GList:AddChildAt(child, index)
end

function GList:RemoveChildAt(index, dispose)
end

---@param index number
function GList:RemoveChildToPoolAt(index) end

---@param child FairyGUI.GObject
function GList:RemoveChildToPool(child) end

---@overload fun()
---@param beginIndex number @default: 0
---@param endIndex number @default: -1
function GList:RemoveChildrenToPool(beginIndex, endIndex) end

---@return number[]
function GList:GetSelection() end

---@param index number
---@param scrollItToView boolean
function GList:AddSelection(index, scrollItToView) end

function GList:RemoveSelection() end

function GList:ClearSelection() end

---@param g FairyGUI.GObject
function GList:ClearSelectionExcept(g) end

function GList:SelectAll() end

function GList:SelectNone() end

function GList:SelectReverse() end

---@param dir number
function GList:HandleArrowKey(dir) end

---@param context FairyGUI.EventContext
function GList:__itemTouchBegin(context) end

---@param context FairyGUI.EventContext
function GList:__clickItem(context) end

---@param item FairyGUI.GObject
---@param evt FairyGUI.InputEvent
function GList:SetSelectionOnEvent(item, evt) end

--- Resize to list size to fit specified item count.
--- If list layout is single column or flow horizontally, the height will change to fit.
--- If list layout is single row or flow vertically, the width will change to fit.
---@overload fun(itemCount:number)
---@param itemCount number
---@param minSize number @default: 0
function GList:ResizeToFit(itemCount, minSize) end

function GList:HandleSizeChanged()
end

function GList:HandleControllerChanged(c)
end

---@param index number
function GList:UpdateSelectionController(index) end

---Scroll the list to make an item with certain index visible.
---@overload fun(index:number)
---@param index number
---@param ani boolean @default: false
function GList:ScrollToView(index, ani) end

function GList:GetFirstChildInView()
end

---@param index number
---@return number @itemIndex
function GList:ChildIndexToItemIndex(index) end

---@param index number
---@return number @childIndex
function GList:ItemIndexToChildIndex(index) end


function GList:SetVirtualAndLoop() end

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
end

function GList:RefreshVirtualList() end

function GList:CheckVirtualList() end

---@param layoutChanged boolean
function GList:SetVirtualListChangedFlag(layoutChanged) end

---@param param any
function GList:RefreshVirtualList(param) end

---@param context FairyGUI.EventContext
function GList:__scrolled(context) end

---@param pos number @ref
---@param forceUpdate boolean
---@return number, number @index, pos
function GList:GetIndexOnPos1(pos, forceUpdate) end

---@param pos number @ref
---@param forceUpdate boolean
---@return number, number @index, pos
function GList:GetIndexOnPos2(pos, forceUpdate) end

---@param pos number @ref
---@param forceUpdate boolean
---@return number, number @index, pos
function GList:GetIndexOnPos3(pos, forceUpdate) end

---@param forceUpdate boolean
function GList:HandleScroll(forceUpdate) end

---@param forceUpdate boolean
function GList:HandleScroll1(forceUpdate) end

---@param forceUpdate boolean
function GList:HandleScroll2(forceUpdate) end

---@param forceUpdate boolean
function GList:HandleScroll3(forceUpdate) end

function GList:HandleArchOrder1() end

function GList:HandleArchOrder2() end

function GList:GetSnappingPosition(xValue, yValue)
end

---@param contentWidth number
---@param contentHeight number
function GList:HandleAlign(contentWidth, contentHeight) end

function GList:UpdateBounds()
end

function GList:Setup_BeforeAdd(buffer, beginPos)
end

function GList:Setup_AfterAdd(buffer, beginPos)
end

--TODO: FairyGUI.GList

local __get = Class.init_get(GList)
local __set = Class.init_set(GList)

---@param self FairyGUI.GList
__get.layout = function(self) end

---@param self FairyGUI.GList
---@param val FairyGUI.ListLayoutType
__set.layout = function(self, val) end

---@param self FairyGUI.GList
__get.lineCount = function(self) end

---@param self FairyGUI.GList
---@param val number
__set.lineCount = function(self, val) end

---@param self FairyGUI.GList
__get.columnCount = function(self) end

---@param self FairyGUI.GList
---@param val number
__set.columnCount = function(self, val) end

---@param self FairyGUI.GList
__get.lineGap = function(self) end

---@param self FairyGUI.GList
---@param val number
__set.lineGap = function(self, val) end

---@param self FairyGUI.GList
__get.columnGap = function(self) end

---@param self FairyGUI.GList
---@param val number
__set.columnGap = function(self, val) end

---@param self FairyGUI.GList
__get.align = function(self) end

---@param self FairyGUI.GList
---@param val FairyGUI.AlignType
__set.align = function(self, val) end

---@param self FairyGUI.GList
__get.verticalAlign = function(self) end

---@param self FairyGUI.GList
---@param val FairyGUI.VertAlignType
__set.verticalAlign = function(self, val) end

---@param self FairyGUI.GList
__get.autoResizeItem = function(self) end

---@param self FairyGUI.GList
---@param val boolean
__set.autoResizeItem = function(self, val) end

---@param self FairyGUI.GList
__get.itemPool = function(self) end

---@param self FairyGUI.GList
__get.selectedIndex = function(self) end

---@param self FairyGUI.GList
---@param val number
__set.selectedIndex = function(self, val) end

---@param self FairyGUI.GList
__get.selectionController = function(self) end

---@param self FairyGUI.GList
---@param val FairyGUI.Controller
__set.selectionController = function(self, val) end

---@param self FairyGUI.GList
__get.touchItem = function(self) end

---@param self FairyGUI.GList
__get.isVirtual = function(self) end

---@param self FairyGUI.GList
__get.numItems = function(self) end

---@param self FairyGUI.GList
---@param val number
__set.numItems = function(self, val) end


FairyGUI.ListItemRenderer = ListItemRenderer
FairyGUI.ListItemProvider = ListItemProvider
GList.ItemInfo = ItemInfo
FairyGUI.GList = GList
return GList