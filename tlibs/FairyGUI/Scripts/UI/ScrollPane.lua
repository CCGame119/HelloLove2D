--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:51
--

local Class = require('libs.Class')
local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

local Vector2 = Love2DEngine.Vector2
local Vector4 = Love2DEngine.Vector4
local Rect = Love2DEngine.Rect
local Debug = Love2DEngine.Debug
local Time = Love2DEngine.Time
local Application = Love2DEngine.Application

local EventDispatcher = FairyGUI.EventDispatcher
local EventListener = FairyGUI.EventListener
local UIConfig = FairyGUI.UIConfig
local UIPackage = FairyGUI.UIPackage
local GComponent = FairyGUI.GComponent
local Container = FairyGUI.Container
local EventCallback0 = FairyGUI.EventCallback0
local EventCallback1 = FairyGUI.EventCallback1
local TimerCallback = FairyGUI.TimerCallback
local ScrollType = FairyGUI.ScrollType
local ScrollBarDisplayType = FairyGUI.ScrollBarDisplayType
local Timers = FairyGUI.Timers
local GObject = FairyGUI.GObject
local Stage = FairyGUI.Stage
local UpdateContext = FairyGUI.UpdateContext
local Margin = FairyGUI.Margin

---@class FairyGUI.ScrollPane:FairyGUI.EventDispatcher
---@field public onScroll FairyGUI.EventListener @在滚动时派发该事件。
---@field public onScrollEnd FairyGUI.EventListener @在滚动结束时派发该事件。
---@field public onPullDownRelease FairyGUI.EventListener @向下拉过上边缘后释放则派发该事件。
---@field public onPullUpRelease FairyGUI.EventListener @向上拉过下边缘后释放则派发该事件。
---@field public draggingPane FairyGUI.ScrollPane @ static 当前被拖拽的滚动面板。同一时间只能有一个在进行此操作。
---@field public owner FairyGUI.GComponent
---@field public hzScrollBar GScrollBar
---@field public vtScrollBar GScrollBar
---@field public header FairyGUI.GComponent
---@field public footer FairyGUI.GComponent
---@field public pageController FairyGUI.Controller
---@field public bouncebackEffect boolean @滚动到达边缘时是否允许回弹效果。
---@field public touchEffect boolean @是否允许拖拽内容区域进行滚动。
---@field public inertiaDisabled boolean @是否允许惯性滚动。
---@field public softnessOnTopOrLeftSide boolean @是否允许在左/上边缘显示虚化效果。
---@field public scrollStep number @ 当调用ScrollPane.scrollUp/Down/Left/Right时，或者点击滚动条的上下箭头时，滑动的距离。鼠标滚轮触发一次滚动的距离设定为defaultScrollStep*2
---@field public snapToItem boolean @ 滚动位置是否保持贴近在某个元件的边缘。
---@field public pageMode boolean @ 是否页面滚动模式。
---@field public pageController FairyGUI.Controller @
---@field public mouseWheelEnabled boolean @ 是否允许使用鼠标滚轮进行滚动。
---@field public decelerationRate number @ 当处于惯性滚动时减速的速率。默认值是UIConfig.defaultScrollDecelerationRate。越接近1，减速越慢，意味着滑动的时间和距离更长。
---@field public percX number @ 当前X轴滚动位置百分比，0~1（包含）。
---@field public percY number @ 当前Y轴滚动位置百分比，0~1（包含）。
---@field public posX number @ 当前X轴滚动位置，值范围是viewWidth与contentWidth之差。
---@field public posY number @ 当前Y轴滚动位置，值范围是viewHeight与contentHeight之差。
---@field public currentPageX number @ 如果处于分页模式，返回当前在X轴的页码。
---@field public isBottomMost boolean @返回当前滚动位置是否在最下边。
---@field public isRightMost boolean @返回当前滚动位置是否在最右边。
---@field public scrollingPosX number @这个值与PosX不同在于，他反映的是实时位置，而PosX在有缓动过程的情况下只是终值。
---@field public scrollingPosY number @这个值与PosY不同在于，他反映的是实时位置，而PosY在有缓动过程的情况下只是终值。
---@field public contentWidth number @显示内容宽度。
---@field public contentHeight number @显示内容高度。
---@field public viewWidth number @显示区域宽度。
---@field public viewHeight number @显示区域高度。
---@field private _scrollType FairyGUI.ScrollType
---@field private _scrollStep number
---@field private _mouseWheelStep number
---@field private _scrollBarMargin FairyGUI.Margin
---@field private _bouncebackEffect boolean
---@field private _touchEffect boolean
---@field private _scrollBarDisplayAuto boolean
---@field private _vScrollNone boolean
---@field private _hScrollNone boolean
---@field private _needRefresh boolean
---@field private _refreshBarAxis number
---@field private _displayOnLeft boolean
---@field private _snapToItem boolean
---@field private _displayInDemand boolean
---@field private _mouseWheelEnabled boolean
---@field private _softnessOnTopOrLeftSide boolean
---@field private _pageMode boolean
---@field private _pageSize Love2DEngine.Vector2
---@field private _inertiaDisabled boolean
---@field private _maskDisabled boolean
---@field private _decelerationRate number
---@field private _xPos number
---@field private _yPos number
---@field private _viewSize Love2DEngine.Vector2
---@field private _contentSize Love2DEngine.Vector2
---@field private _overlapSize Love2DEngine.Vector2
---@field private _containerPos Love2DEngine.Vector2
---@field private _beginTouchPos Love2DEngine.Vector2
---@field private _lastTouchPos Love2DEngine.Vector2
---@field private _lastTouchGlobalPos Love2DEngine.Vector2
---@field private _velocity Love2DEngine.Vector2
---@field private _velocityScale number
---@field private _lastMoveTime number
---@field private _isMouseMoved boolean
---@field private _isHoldAreaDone boolean
---@field private _aniFlag number
---@field private _scrollBarVisible boolean
---@field private _loop number
---@field private _headerLockedSize number
---@field private _footerLockedSize number
---@field private _tweening number
---@field private _tweenStart Love2DEngine.Vector2
---@field private _tweenChange Love2DEngine.Vector2
---@field private _tweenTime Love2DEngine.Vector2
---@field private _tweenDuration Love2DEngine.Vector2
---@field private _refreshDelegate FairyGUI.EventCallback0
---@field private _tweenUpdateDelegate FairyGUI.TimerCallback
---@field private _showScrollBarDelegate FairyGUI.TimerCallback
---@field private _owner FairyGUI.GComponent
---@field private _maskContainer FairyGUI.Container
---@field private _container FairyGUI.Container
---@field private _hzScrollBar FairyGUI.GScrollBar
---@field private _vtScrollBar FairyGUI.GScrollBar
---@field private _header FairyGUI.GComponent
---@field private _footer FairyGUI.GComponent
---@field private _pageController FairyGUI.Controller
local ScrollPane = Class.inheritsFrom('ScrollPane', {
    _scrollType = ScrollType.Both, _scrollStep = 0, _mouseWheelStep = 0,
    _bouncebackEffect = false, _touchEffect = false, _scrollBarDisplayAuto = false,
    _vScrollNone = false, _hScrollNone = false, _needRefresh = false,
    _refreshBarAxis = 0, _decelerationRate = 0,
    _displayOnLeft = false, _snapToItem = false, _displayInDemand = false, _mouseWheelEnabled = false,
    _softnessOnTopOrLeftSide = false, _pageMode = false, _inertiaDisabled = false, _maskDisabled = false,
    _decelerationRate = 0, _xPos = 0, _yPos = 0,
    _velocityScale = 0, _lastMoveTime = 0,
    _isMouseMoved = false, _isHoldAreaDone = false,
    _aniFlag = 0, _scrollBarVisible = false, _loop = 0,
    _headerLockedSize = 0, _footerLockedSize = 0,
    _tweening = 0
}, EventDispatcher)

ScrollPane._gestureFlag = 0
ScrollPane.TWEEN_TIME_GO = 0.5  -- 调用SetPos(ani)时使用的缓动时间
ScrollPane.TWEEN_TIME_DEFAULT = 0.3  -- 惯性滚动的最小缓动时间
ScrollPane.PULL_RATIO = 0.5  -- 下拉过顶或者上拉过底时允许超过的距离占显示区域的比例

---@param owner FairyGUI.GComponent
function ScrollPane:__ctor(owner)
    self._scrollBarMargin = Margin.zero

    self._viewSize = Vector2.zero
    self._contentSize = Vector2.zero
    self._overlapSize = Vector2.zero
    self._containerPos = Vector2.zero
    self._beginTouchPos = Vector2.zero
    self._lastTouchPos = Vector2.zero
    self._lastTouchGlobalPos = Vector2.zero
    self._velocity = Vector2.zero

    self._tweenStart = Vector2.zero
    self._tweenChange = Vector2.zero
    self._tweenTime = Vector2.zero
    self._tweenDuration = Vector2.zero

    self.onScroll = EventListener.new(self, "onScroll")
    self.onScrollEnd = EventListener.new(self, "onScrollEnd")
    self.onPullDownRelease = EventListener.new(self, "onPullDownRelease")
    self.onPullUpRelease = EventListener.new(self, "onPullUpRelease")

    self._scrollStep = UIConfig.defaultScrollStep
    self._mouseWheelStep = self._scrollStep * 2
    self._softnessOnTopOrLeftSide = UIConfig.allowSoftnessOnTopOrLeftSide
    self._decelerationRate = UIConfig.defaultScrollDecelerationRate
    self._touchEffect = UIConfig.defaultScrollTouchEffect
    self._bouncebackEffect = UIConfig.defaultScrollBounceEffect
    self._scrollBarVisible = true
    self._mouseWheelEnabled = true
    self._pageSize = Vector2.one

    self._refreshDelegate = EventCallback0.new(self.Refresh, self)
    self._tweenUpdateDelegate = TimerCallback.new(self.TweenUpdate, self)
    self._showScrollBarDelegate = TimerCallback.new(self.onShowScrollBar, self)

    self._owner = owner

    self._maskContainer = Container.new()
    self._owner.rootContainer:AddChild(self._maskContainer)

    self._container = self._owner.container
    self._container:SetXY(0, 0)
    self._maskContainer:AddChild(self._container)

    self.__mouseWheelDelegate = EventCallback1.new(self.__mouseWheel, self)
    self.__touchBeginDelegate = EventCallback1.new(self.__touchBegin, self)
    self.__touchMoveDelegate = EventCallback1.new(self.__touchMove, self)
    self.__touchEndDelegate = EventCallback1.new(self.__touchEnd, self)

    self._owner.rootContainer.onMouseWheel:Add(self.__mouseWheelDelegate)
    self._owner.rootContainer.onTouchBegin:Add(self.__touchBeginDelegate)
    self._owner.rootContainer.onTouchMove:Add(self.__touchMoveDelegate)
    self._owner.rootContainer.onTouchEnd:Add(self.__touchEndDelegate)
end

---@param buffer Utils.ByteBuffer
function ScrollPane:Setup(buffer)
    self._scrollType = buffer:ReadByte()
    ---@type FairyGUI.ScrollBarDisplayType
    local scrollBarDisplay = buffer:ReadByte()
    local flags = buffer:ReadInt()

    if (buffer:ReadBool()) then
        self._scrollBarMargin.top = buffer:ReadInt()
        self._scrollBarMargin.bottom = buffer:ReadInt()
        self._scrollBarMargin.left = buffer:ReadInt()
        self._scrollBarMargin.right = buffer:ReadInt()
    end

    local vtScrollBarRes = buffer:ReadS()
    local hzScrollBarRes = buffer:ReadS()
    local headerRes = buffer:ReadS()
    local footerRes = buffer:ReadS()

    self._displayOnLeft = band(flags, 1) ~= 0
    self._snapToItem = band(flags, 2) ~= 0
    self._displayInDemand = band(flags, 4) ~= 0
    self._pageMode = band(flags, 8) ~= 0
    if (band(flags, 16) ~= 0) then
        self._touchEffect = true
    elseif (band(flags, 32) ~= 0) then
        self._touchEffect = false
    end
    if (band(flags, 64) ~= 0) then
        self._bouncebackEffect = true
    elseif (band(flags, 128) ~= 0) then
        self._bouncebackEffect = false
    end
    self._inertiaDisabled = band(flags, 256) ~= 0
    self._maskDisabled = band(flags, 512) ~= 0

    if (scrollBarDisplay == ScrollBarDisplayType.Default) then
        if (Application.isMobilePlatform) then
            scrollBarDisplay = ScrollBarDisplayType.Auto
        else
            scrollBarDisplay = UIConfig.defaultScrollBarDisplay
        end
    end

    if (scrollBarDisplay ~= ScrollBarDisplayType.Hidden) then
        if (self._scrollType == ScrollType.Both or self._scrollType == ScrollType.Vertical) then
            local res = vtScrollBarRes ~= nil and vtScrollBarRes or UIConfig.verticalScrollBar
            if (not string.isNullOrEmpty(res)) then
                self._vtScrollBar = UIPackage.CreateObjectFromURL(res)
                if (self._vtScrollBar == nil) then
                    Debug.LogWarn("FairyGUI: cannot create scrollbar from " .. res)
                else
                    self._vtScrollBar:SetScrollPane(self, true)
                    self._owner.rootContainer:AddChild(self._vtScrollBar.displayObject)
                end
            end
        end
        if (self._scrollType == ScrollType.Both or self._scrollType == ScrollType.Horizontal) then
            local res = hzScrollBarRes ~= nil and hzScrollBarRes or UIConfig.horizontalScrollBar
            if (not string.isNullOrEmpty(res)) then
                self._hzScrollBar = UIPackage.CreateObjectFromURL(res)
                if (self._hzScrollBar == nil) then
                    Debug.LogWarn("FairyGUI: cannot create scrollbar from " .. res)
                else
                    self._hzScrollBar:SetScrollPane(self, false)
                    self._owner.rootContainer:AddChild(self._hzScrollBar.displayObject)
                end
            end
        end

        self._scrollBarDisplayAuto = scrollBarDisplay == ScrollBarDisplayType.Auto
        if (self._scrollBarDisplayAuto) then
            if (self._vtScrollBar ~= nil) then
                self._vtScrollBar.displayObject.visible = false
            end
            if (self._hzScrollBar ~= nil) then
                self._hzScrollBar.displayObject.visible = false
            end
            self._scrollBarVisible = false

            self._owner.rootContainer.onRollOver:Add(self.__rollOverDelegate)
            self._owner.rootContainer.onRollOut:Add(self.__rollOutDelegate)
        end
    else
        self._mouseWheelEnabled = false
    end

    if (headerRes ~= nil) then
        self._header = UIPackage.CreateObjectFromURL(headerRes)
        if (self._header == nil) then
            Debug.LogWarn("FairyGUI: cannot create scrollPane header from " .. headerRes)
        end
    end

    if (footerRes ~= nil) then
        self._footer = UIPackage.CreateObjectFromURL(footerRes)
        if (self._footer == nil) then
            Debug.LogWarn("FairyGUI: cannot create scrollPane footer from " .. footerRes)
        end
    end

    if (self._header ~= nil or self._footer ~= nil) then
        self._refreshBarAxis = (self._scrollType == ScrollType.Both or self._scrollType == ScrollType.Vertical) and 1 or 0
    end

    if (not self._maskDisabled and (self._vtScrollBar ~= nil or self._hzScrollBar ~= nil)) then
        -- 当有滚动条对象时，为了避免滚动条变化时触发重新合批，这里给rootContainer也加上剪裁。但这可能会增加额外dc。
        self._owner.rootContainer.clipRect = Rect(0, 0, self._owner.width, self._owner.height)
    end

    self:SetSize(self.owner.width, self.owner.height)
end

function ScrollPane:Dispose()
    self:RemoveEventListeners()

    if (self._tweening ~= 0) then
        Timers.inst:Remove(self._tweenUpdateDelegate)
    end

    if (self.draggingPane == self) then
        self.draggingPane = nil
    end

    self._pageController = nil

    if (self._hzScrollBar ~= nil) then
        self._hzScrollBar:Dispose()
    end
    if (self._vtScrollBar ~= nil) then
        self._vtScrollBar:Dispose()
    end
    if (self._header ~= nil) then
        self._header:Dispose()
    end
    if (self._footer ~= nil) then
        self._footer:Dispose()
    end
end

---设置当前X轴滚动位置百分比，0~1（包含）。
---@param value number
---@param ani boolean 是否使用缓动到达目标。
function ScrollPane:SetPercX(value, ani)
    self._owner:EnsureBoundsCorrect()
    self:SetPosX(self._overlapSize.x * math.clamp01(value), ani)
end

---当前Y轴滚动位置百分比，0~1（包含）。
---@param value number
---@param ani boolean 是否使用缓动到达目标。
function ScrollPane:SetPercY(value, ani)
    self._owner:EnsureBoundsCorrect()
    self:SetPosY(self._overlapSize.y * math.clamp01(value), ani)
end

---设置当前X轴滚动位置
---@param value number
---@param ani boolean 是否使用缓动到达目标。
function ScrollPane:SetPosX(value, ani)
    self._owner:EnsureBoundsCorrect()

    if (self._loop == 1) then
        value = self:LoopCheckingNewPos(value, 0)
    end

    value = math.clamp(value, 0, self._overlapSize.x)
    if (value ~= self._xPos) then
        self._xPos = value
        self:PosChanged(ani)
    end
end

---设置当前Y轴滚动位置
---@param value number
---@param ani boolean 是否使用缓动到达目标。
function ScrollPane:SetPosY(value, ani)
    self._owner:EnsureBoundsCorrect()

    if (self._loop == 2) then
        value = self:LoopCheckingNewPos(value, 1)
    end

    value = math.clamp(value, 0, self._overlapSize.y)
    if (value ~= self._yPos) then
        self._yPos = value
        self:PosChanged(ani)
    end
end

---如果处于分页模式，可设置X轴的页码。
---@param value number
---@param ani boolean 是否使用缓动到达目标。
function ScrollPane:SetCurrentPageX(value, ani)
    if self._overlapSize.x > 0 then
        self:SetPosX(value * self._pageSize.x, ani)
    end
end

---如果处于分页模式，可设置Y轴的页码。
---@param value number
---@param ani boolean 是否使用缓动到达目标。
function ScrollPane:SetCurrentPageY(value, ani)
    if self._overlapSize.y > 0 then
        self:SetPosX(value * self._pageSize.y, ani)
    end
end

---@overload fun()
---@param ani boolean @default: false
function ScrollPane:ScrollTop(ani)
    ani = ani or false
    self:SetPercY(0, ani)
end

---@overload fun()
---@param ani boolean @default: false
function ScrollPane:ScrollBottom(ani)
    ani = ani or false
    self:SetPercY(1, ani)
end

---@overload fun()
---@param ratio number @default: 1
---@param ani boolean @default: false
function ScrollPane:ScrollUp(ratio, ani)
    ratio = ratio or 1
    ani = ani or false

    if (self._pageMode) then
        self:SetPosY(self._yPos - self._pageSize.y * ratio, ani)
    else
        self:SetPosY(self._yPos - self._scrollStep * ratio, ani)
    end
end

---@overload fun()
---@param ratio number @default: 1
---@param ani boolean @default: false
function ScrollPane:ScrollDown(ratio, ani)
    ratio = ratio or 1
    ani = ani or false

    if (self._pageMode) then
        self:SetPosY(self._yPos + self._pageSize.y * ratio, ani)
    else
        self:SetPosY(self._yPos + self._scrollStep * ratio, ani)
    end
end

---@overload fun()
---@param ratio number @default: 1
---@param ani boolean @default: false
function ScrollPane:ScrollLeft(ratio, ani)
    ratio = ratio or 1
    ani = ani or false

    if (self._pageMode) then
        self:SetPosX(self._xPos - self._pageSize.x * ratio, ani)
    else
        self:SetPosX(self._xPos - self._scrollStep * ratio, ani)
    end
end

---@overload fun()
---@param ratio number @default: 1
---@param ani boolean @default: false
function ScrollPane:ScrollRight(ratio, ani)
    ratio = ratio or 1
    ani = ani or false

    if (self._pageMode) then
        self:SetPosX(self._xPos + self._pageSize.x * ratio, ani)
    else
        self:SetPosX(self._xPos + self._scrollStep * ratio, ani)
    end
end

---@overload fun(obj:FairyGUI.GObject)
---@overload fun(obj:FairyGUI.GObject, ani:boolean)
---@overload fun(rect:Love2DEngine.Rect, ani:boolean, setFirst:boolean)
---@param obj FairyGUI.GObject
---@param ani boolean
---@param setFirst boolean
function ScrollPane:ScrollToView(obj, ani, setFirst)
    if obj:isa(GObject) then
        ani = ani or false
        setFirst = setFirst or false

        self._owner:EnsureBoundsCorrect()
        if (self._needRefresh) then
            self:Refresh()
        end

        local rect = Rect(obj.x, obj.y, obj.width, obj.height)
        if (obj.parent ~= self._owner) then
            rect = obj.parent:TransformRect(rect, self._owner)
        end
        self:ScrollToView(rect, ani, setFirst)
        return
    end

    self._owner:EnsureBoundsCorrect()
    if (self._needRefresh) then
        self:Refresh()
    end

    local rect = obj
    if (self._overlapSize.y > 0) then
        local bottom = self._yPos + self._viewSize.y
        if (setFirst or rect.y <= self._yPos or rect.height >= self._viewSize.y) then
            if (self._pageMode) then
                self:SetPosY(math.floor(rect.y / self._pageSize.y) * self._pageSize.y, ani)
            else
                self:SetPosY(rect.y, ani)
            end
        elseif (rect.y + rect.height > bottom) then
            if (self._pageMode) then
                self:SetPosY(math.floor(rect.y / self._pageSize.y) * self._pageSize.y, ani)
            elseif (rect.height <= self._viewSize.y / 2) then
                self:SetPosY(rect.y + rect.height * 2 - self._viewSize.y, ani)
            else
                self:SetPosY(rect.y + rect.height - self._viewSize.y, ani)
            end
        end
    end
    if (self._overlapSize.x > 0) then
        local right = self._xPos + self._viewSize.x
        if (setFirst or rect.x <= self._xPos or rect.width >= self._viewSize.x) then
            if (self._pageMode) then
                self:SetPosX(math.floor(rect.x / self._pageSize.x) * self._pageSize.x, ani)
            end
            self:SetPosX(rect.x, ani)
        elseif (rect.x + rect.width > right) then
            if (self._pageMode) then
                self:SetPosX(math.floor(rect.x / self._pageSize.x) * self._pageSize.x, ani)
            elseif (rect.width <= self._viewSize.x / 2) then
                self:SetPosX(rect.x + rect.width * 2 - self._viewSize.x, ani)
            else
                self:SetPosX(rect.x + rect.width - self._viewSize.x, ani)
            end
        end
    end

    if (not ani and self._needRefresh) then
        self:Refresh()
    end
end

---@param obj FairyGUI.GObject
---@return boolean
function ScrollPane:IsChildInView(obj)
    if (self._overlapSize.y > 0) then
        local dist = obj.y + self._container.y
        if (dist <= -obj.height or dist >= self._viewSize.y) then
            return false
        end
    end

    if (self._overlapSize.x > 0) then
        local dist = obj.x + self._container.x
        if (dist <= -obj.width or dist >= self._viewSize.x) then
            return false
        end
    end

    return true
end

---当滚动面板处于拖拽滚动状态或即将进入拖拽状态时，可以调用此方法停止或禁止本次拖拽。
function ScrollPane:CancelDragging()
    Stage.inst:RemoveTouchMonitor(self._owner.rootContainer)

    if (self.draggingPane == self) then
        self.draggingPane = nil
    end

    self._gestureFlag = 0
    self._isMouseMoved = false
end

---设置Header固定显示。如果size为0，则取消固定显示。
---@param size number @Header显示的大小
function ScrollPane:LockHeader(size)
    if (self._headerLockedSize == size) then
        return
    end

    self._headerLockedSize = size
    if (not self.onPullDownRelease.isDispatching and self._container.xy[self._refreshBarAxis] >= 0) then
        self._tweenStart = self._container.xy
        self._tweenChange = Vector2.zero
        self._tweenChange[self._refreshBarAxis] = self._headerLockedSize - self._tweenStart[self._refreshBarAxis]
        self._tweenDuration = Vector2(ScrollPane.TWEEN_TIME_DEFAULT, ScrollPane.TWEEN_TIME_DEFAULT)
        self._tweenTime = Vector2.zero
        self._tweening = 2
        Timers.inst:AddUpdate(self._tweenUpdateDelegate)
    end
end

---设置Footer固定显示。如果size为0，则取消固定显示。
---@param size number
function ScrollPane:LockFooter(size)
    if (self._footerLockedSize == size) then
        return
    end

    self._footerLockedSize = size
    if (not self.onPullUpRelease.isDispatching and self._container.xy[self._refreshBarAxis] <= -self._overlapSize[self._refreshBarAxis]) then
        self._tweenStart = self._container.xy
        self._tweenChange = Vector2.zero
        local max = self._overlapSize[self._refreshBarAxis]
        if (max == 0) then
            max = math.max(self._contentSize[self._refreshBarAxis] + self._footerLockedSize - self._viewSize[self._refreshBarAxis], 0)
        else
            max = max +self._footerLockedSize
        end
        self._tweenChange[self._refreshBarAxis] = -max - self._tweenStart[self._refreshBarAxis]
        self._tweenDuration = Vector2(ScrollPane.TWEEN_TIME_DEFAULT, ScrollPane.TWEEN_TIME_DEFAULT)
        self._tweenTime = Vector2.zero
        self._tweening = 2
        Timers.inst:AddUpdate(self._tweenUpdateDelegate)
    end
end

function ScrollPane:OnOwnerSizeChanged()
    self:SetSize(self._owner.width, self._owner.height)
    self:PosChanged(false)
end

---@param c FairyGUI.Controller
function ScrollPane:HandleControllerChanged(c)
    if (self._pageController == c) then
        if (self._scrollType == ScrollType.Horizontal) then
            self:SetCurrentPageX(c.selectedIndex, true)
        else
            self:SetCurrentPageY(c.selectedIndex, true)
        end
    end
end

function ScrollPane:UpdatePageController()
    if (self._pageController ~= nil and not self._pageController.changing) then
        local index
        if (self._scrollType == ScrollType.Horizontal) then
            index = self.currentPageX
        else
            index = self.currentPageY
        end
        if (index < self._pageController.pageCount) then
            local c = self._pageController
            self._pageController = nil  -- 防止HandleControllerChanged的调用
            c.selectedIndex = index
            self._pageController = c
        end
    end
end

function ScrollPane:AdjustMaskContainer()
    local mx, my
    if (self._displayOnLeft and self._vtScrollBar ~= nil) then
        mx = math.floor(self._owner.margin.left + self._vtScrollBar.width)
    else
        mx = self._owner.margin.left
    end
    my = self._owner.margin.top
    mx = mx + self._owner._alignOffset.x
    my = my + self._owner._alignOffset.y

    self._maskContainer:SetXY(mx, my)
end

---@param aWidth number
---@param aHeight number
function ScrollPane:SetSize(aWidth, aHeight)
    self:AdjustMaskContainer()

    if (self._hzScrollBar ~= nil) then
        self._hzScrollBar.y = aHeight - self._hzScrollBar.height
        if (self._vtScrollBar ~= nil) then
            self._hzScrollBar.width = aWidth - self._vtScrollBar.width - self._scrollBarMargin.left - self._scrollBarMargin.right
            if (self._displayOnLeft) then
                self._hzScrollBar.x = self._scrollBarMargin.left + self._vtScrollBar.width
            else
                self._hzScrollBar.x = self._scrollBarMargin.left
            end
        else
            self._hzScrollBar.width = aWidth - self._scrollBarMargin.left - self._scrollBarMargin.right
            self._hzScrollBar.x = self._scrollBarMargin.left
        end
    end
    if (self._vtScrollBar ~= nil) then
        if (not self._displayOnLeft) then
            self._vtScrollBar.x = aWidth - self._vtScrollBar.width
        end
        if (self._hzScrollBar ~= nil) then
            self._vtScrollBar.height = aHeight - self._hzScrollBar.height - self._scrollBarMargin.top - self._scrollBarMargin.bottom
        else
            self._vtScrollBar.height = aHeight - self._scrollBarMargin.top - self._scrollBarMargin.bottom
        end
        self._vtScrollBar.y = self._scrollBarMargin.top
    end

    self._viewSize.x = aWidth
    self._viewSize.y = aHeight
    if (self._hzScrollBar ~= nil and not self._hScrollNone) then
        self._viewSize.y = self._viewSize.y - self._hzScrollBar.height
    end
    if (self._vtScrollBar ~= nil and not self._vScrollNone) then
        self._viewSize.x = self._viewSize.x - self._vtScrollBar.width
    end
    self._viewSize.x = self._viewSize.x - (self._owner.margin.left + self._owner.margin.right)
    self._viewSize.y = self._viewSize.y - (self._owner.margin.top + self._owner.margin.bottom)

    self._viewSize.x = math.max(1, self._viewSize.x)
    self._viewSize.y = math.max(1, self._viewSize.y)
    self._pageSize.x = self._viewSize.x
    self._pageSize.y = self._viewSize.y

    self:HandleSizeChanged()
end

---@param aWidth number
---@param aHeight number
function ScrollPane:SetContentSize(aWidth, aHeight)
    if (math.Approximately(self._contentSize.x, aWidth) and math.Approximately(self._contentSize.y, aHeight)) then
        return
    end

    self._contentSize.x = aWidth
    self._contentSize.y = aHeight
    self:HandleSizeChanged()
end

---@param deltaWidth number
---@param deltaHeight number
---@param deltaPosX number
---@param deltaPosY number
function ScrollPane:ChangeContentSizeOnScrolling(deltaWidth, deltaHeight, deltaPosX, deltaPosY)
    local isRightmost = self._xPos == self._overlapSize.x
    local isBottom = self._yPos == self._overlapSize.y

    self._contentSize.x = self._contentSize.x + deltaWidth
    self._contentSize.y = self._contentSize.y + deltaHeight
    self:HandleSizeChanged()

    if (self._tweening == 1) then
        -- 如果原来滚动位置是贴边，加入处理继续贴边。
        if (deltaWidth ~= 0 and isRightmost and self._tweenChange.x < 0) then
            self._xPos = self._overlapSize.x
            self._tweenChange.x = -self._xPos - self._tweenStart.x
        end

        if (deltaHeight ~= 0 and isBottom and self._tweenChange.y < 0) then
            self._yPos = self._overlapSize.y
            self._tweenChange.y = -self._yPos - self._tweenStart.y
        end
    elseif (self._tweening == 2) then
        -- 重新调整起始位置，确保能够顺滑滚下去
        if (deltaPosX ~= 0) then
            self._container.x = self._container.x - deltaPosX
            self._tweenStart.x = self._tweenStart.x - deltaPosX
            self._xPos = -self._container.x
        end
        if (deltaPosY ~= 0) then
            self._container.y = self._container.y - deltaPosY
            self._tweenStart.y = self._tweenStart.y - deltaPosY
            self._yPos = -self._container.y
        end
    elseif (self._isMouseMoved) then
        if (deltaPosX ~= 0) then
            self._container.x = self._container.x - deltaPosX
            self._containerPos.x = self._containerPos.x - deltaPosX
            self._xPos = -self._container.x
        end
        if (deltaPosY ~= 0) then
            self._container.y = self._container.y - deltaPosY
            self._containerPos.y = self._containerPos.y - deltaPosY
            self._yPos = -self._container.y
        end
    else
        -- 如果原来滚动位置是贴边，加入处理继续贴边。
        if (deltaWidth ~= 0 and isRightmost) then
            self._xPos = self._overlapSize.x
            self._container.x = -self._xPos
        end

        if (deltaHeight ~= 0 and isBottom) then
            self._yPos = self._overlapSize.y
            self._container.y = -self._yPos
        end
    end

    if (self._pageMode) then
        self:UpdatePageController()
    end
end

function ScrollPane:HandleSizeChanged()
    if (self._displayInDemand) then
        if (self._vtScrollBar ~= nil) then
            if (self._contentSize.y <= self._viewSize.y) then
                if (not self._vScrollNone) then
                    self._vScrollNone = true
                    self._viewSize.x = self._viewSize.x + self._vtScrollBar.width
                end
            else
                if (self._vScrollNone) then
                    self._vScrollNone = false
                    self._viewSize.x = self._viewSize.x - self._vtScrollBar.width
                end
            end
        end
        if (self._hzScrollBar ~= nil) then
            if (self._contentSize.x <= self._viewSize.x) then
                if (not self._hScrollNone) then
                    self._hScrollNone = true
                    self._viewSize.y = self._viewSize.y + self._hzScrollBar.height
                end
            else
                if (self._hScrollNone) then
                    self._hScrollNone = false
                    self._viewSize.y = self._viewSize.y - self._hzScrollBar.height
                end
            end
        end
    end

    if (self._vtScrollBar ~= nil) then
        if (self._viewSize.y < self._vtScrollBar.minSize) then
            self._vtScrollBar.displayObject.visible = false
        else
            self._vtScrollBar.displayObject.visible = self._scrollBarVisible and not self._vScrollNone
            if (self._contentSize.y == 0) then
                self._vtScrollBar.displayPerc = 0
            else
                self._vtScrollBar.displayPerc = math.min(1, self._viewSize.y / self._contentSize.y)
            end
        end
    end
    if (self._hzScrollBar ~= nil) then
        if (self._viewSize.x < self._hzScrollBar.minSize) then
            self._hzScrollBar.displayObject.visible = false
        else
            self._hzScrollBar.displayObject.visible = self._scrollBarVisible and not self._hScrollNone
            if (self._contentSize.x == 0) then
                self._hzScrollBar.displayPerc = 0
            else
                self._hzScrollBar.displayPerc = math.min(1, self._viewSize.x / self._contentSize.x)
            end
        end
    end

    if (not self._maskDisabled) then
        self._maskContainer.clipRect = Rect(-self._owner._alignOffset.x, -self._owner._alignOffset.y, self._viewSize.x, self._viewSize.y)
    end

    if (self._scrollType == ScrollType.Horizontal or self._scrollType == ScrollType.Both) then
        self._overlapSize.x =math.ceil(math.max(0, self._contentSize.x - self._viewSize.x))
    else
        self._overlapSize.x = 0
    end
    if (self._scrollType == ScrollType.Vertical or self._scrollType == ScrollType.Both) then
        self._overlapSize.y =math.ceil(math.max(0, self._contentSize.y - self._viewSize.y))
    else
        self._overlapSize.y = 0
    end

    -- 边界检查
    self._xPos = math.clamp(self._xPos, 0, self._overlapSize.x)
    self._yPos = math.clamp(self._yPos, 0, self._overlapSize.y)
    local max = self._overlapSize[self._refreshBarAxis]
    if (max == 0) then
        max = math.max(self._contentSize[self._refreshBarAxis] + self._footerLockedSize - self._viewSize[self._refreshBarAxis], 0)
    else
        max = max + self._footerLockedSize
    end
    if (self._refreshBarAxis == 0) then
        self._container:SetXY(math.clamp(self._container.x, -max, self._headerLockedSize), math.clamp(self._container.y, -self._overlapSize.y, 0))
    else
        self._container:SetXY(math.clamp(self._container.x, -self._overlapSize.x, 0), math.clamp(self._container.y, -max, self._headerLockedSize))
    end

    if (self._header ~= nil) then
        if (self._refreshBarAxis == 0) then
            self._header.height = self._viewSize.y
        else
            self._header.width = self._viewSize.x
        end
    end

    if (self._footer ~= nil) then
        if (self._refreshBarAxis == 0) then
            self._footer.height = self._viewSize.y
        else
            self._footer.width = self._viewSize.x
        end
    end

    self:SyncScrollBar(true)
    self:CheckRefreshBar()
    if (self._pageMode) then
        self:UpdatePageController()
    end
end

---@param ani boolean
function ScrollPane:PosChanged(ani)
    -- 只要有1处要求不要缓动，那就不缓动
    if (self._aniFlag == 0) then
        self._aniFlag = ani and 1 or -1
    elseif (self._aniFlag == 1 and not ani) then
        self._aniFlag = -1
    end

    self._needRefresh = true

    UpdateContext.OnBegin:Remove(self._refreshDelegate, self)
    UpdateContext.OnBegin:Add(self._refreshDelegate, self)
end

function ScrollPane:Refresh()
    self._needRefresh = false
    UpdateContext.OnBegin:Remove(self._refreshDelegate, self)

    if (self._owner.displayObject == nil or self._owner.displayObject.isDisposed) then
        return
    end

    if (self._pageMode or self._snapToItem) then
        local pos = Vector2(-self._xPos, -self._yPos)
        self:AlignPosition(pos, false)
        self._xPos = -pos.x
        self._yPos = -pos.y
    end

    self:Refresh2()

    self.onScroll:Call()
    if (self._needRefresh) then -- 在onScroll事件里开发者可能修改位置，这里再刷新一次，避免闪烁
        self._needRefresh = false
        UpdateContext.OnBegin:Remove(self._refreshDelegate, self)

        self:Refresh2()
    end

    self:SyncScrollBar()
    self._aniFlag = 0
end

function ScrollPane:Refresh2()
    if (self._aniFlag == 1 and not self._isMouseMoved) then
        local pos = Vector2()

        if (self._overlapSize.x > 0) then
            pos.x = math.floor(-self._xPos)
        else
            if (self._container.x ~= 0) then
                self._container.x = 0
            end
            pos.x = 0
        end
        if (self._overlapSize.y > 0) then
            pos.y = math.floor(-self._yPos)
        else
            if (self._container.y ~= 0) then
                self._container.y = 0
            end
            pos.y = 0
        end

        if (pos.x ~= self._container.x or pos.y ~= self._container.y) then
            self._tweening = 1
            self._tweenTime = Vector2.zero
            self._tweenDuration = Vector2(ScrollPane.TWEEN_TIME_GO, ScrollPane.TWEEN_TIME_GO)
            self._tweenStart = self._container.xy
            self._tweenChange = pos - self._tweenStart
            Timers.inst:AddUpdate(self._tweenUpdateDelegate)
        elseif (self._tweening ~= 0) then
            self:KillTween()
        end
    else
        if (self._tweening ~= 0) then
            self:KillTween()
        end

        self._container:SetXY(math.floor(-self._xPos), math.floor(-self._yPos))

        self:LoopCheckingCurrent()
    end

    if (self._pageMode) then
        self:UpdatePageController()
    end
end

function ScrollPane:UpdateClipSoft()
    local softness = self._owner.clipSoftness
    if (softness.x ~= 0 or softness.y ~= 0) then
        self._maskContainer.clipSoftness = Vector4(
                (self._container.x >= 0 or not self._softnessOnTopOrLeftSide) and 0 or softness.x,
                (self._container.y >= 0 or not self._softnessOnTopOrLeftSide) and 0 or softness.y,
                (-self._container.x - self._overlapSize.x >= 0) and 0 or softness.x,
                (-self._container.y - self._overlapSize.y >= 0) and 0 or softness.y)
    else
        self._maskContainer.clipSoftness = nil
    end
end

---@param End boolean @default: false
function ScrollPane:SyncScrollBar(End)
    if (self._vtScrollBar ~= nil) then
        self._vtScrollBar.scrollPerc = self._overlapSize.y == 0 and 0 or math.clamp(-self._container.y, 0, self._overlapSize.y) / self._overlapSize.y
        if (self._scrollBarDisplayAuto) then
            self:ShowScrollBar(not End)
        end
    end
    if (self._hzScrollBar ~= nil) then
        self._hzScrollBar.scrollPerc = self._overlapSize.x == 0 and 0 or math.clamp(-self._container.x, 0, self._overlapSize.x) / self._overlapSize.x
        if (self._scrollBarDisplayAuto) then
            self:ShowScrollBar(not End)
        end
    end

    self:UpdateClipSoft()
end

---@param context FairyGUI.EventContext
function ScrollPane:__touchBegin(context)
    if (not self._touchEffect) then
        return
    end

    local evt = context.inputEvent
    if (evt.button ~= 0) then
        return
    end

    context:CaptureTouch()

    local pt = self._owner:GlobalToLocal(evt.position)

    if (self._tweening ~= 0) then
        self:KillTween()
        Stage.inst:CancelClick(evt.touchId)

        -- 立刻停止惯性滚动，可能位置不对齐，设定这个标志，使touchEnd时归位
        self._isMouseMoved = true
    else
        self._isMouseMoved = false
    end

    self._containerPos = self._container.xy
    self._beginTouchPos, self._lastTouchPos =pt:Clone(), pt:Clone()
    self._lastTouchGlobalPos = evt.position
    self._isHoldAreaDone = false
    self._velocity = Vector2.zero
    self._velocityScale = 1
    self._lastMoveTime = Time.unscaledTime
end

---@param context FairyGUI.EventContext
function ScrollPane:__touchMove(context)
    if (not self._touchEffect or self.draggingPane ~= nil and self.draggingPane ~= self or GObject.draggingObject ~= nil) then -- 已经有其他拖动
        return
    end

    local evt = context.inputEvent
    local pt = self._owner:GlobalToLocal(evt.position)
    if (math.nan(pt.x)) then
        return
    end

    local sensitivity
    if (Stage.touchScreen) then
        sensitivity = UIConfig.touchScrollSensitivity
    else
        sensitivity = 8
    end

    local diff
    local sv, sh = false, false

    if (self._scrollType == ScrollType.Vertical) then
        if (not self._isHoldAreaDone) then
            -- 表示正在监测垂直方向的手势
            self._gestureFlag = bor(self._gestureFlag, 1)

            diff = math.abs(self._beginTouchPos.y - pt.y)
            if (diff < sensitivity) then
                return
            end

            if (band(self._gestureFlag, 2) ~= 0) then -- 已经有水平方向的手势在监测，那么我们用严格的方式检查是不是按垂直方向移动，避免冲突
                local diff2 = math.abs(self._beginTouchPos.x - pt.x)
                if (diff < diff2) then -- 不通过则不允许滚动了
                    return
                end
            end
        end

        sv = true
    elseif (self._scrollType == ScrollType.Horizontal) then
        if (not self._isHoldAreaDone) then
            self._gestureFlag = bor(self._gestureFlag, 2)

            diff = math.abs(self._beginTouchPos.x - pt.x)
            if (diff < sensitivity) then
                return
            end

            if (band(self._gestureFlag, 1) ~= 0) then
                local diff2 = math.abs(self._beginTouchPos.y - pt.y)
                if (diff < diff2) then
                    return
                end
            end
        end

        sh = true
    else
        self._gestureFlag = 3

        if (not self._isHoldAreaDone) then
            diff = math.abs(self._beginTouchPos.y - pt.y)
            if (diff < sensitivity) then
                diff = math.abs(self._beginTouchPos.x - pt.x)
                if (diff < sensitivity) then
                    return
                end
            end
        end

        sv, sh = true, true
    end

    local newPos = self._containerPos + pt - self._beginTouchPos
    newPos.x = math.floor(newPos.x)
    newPos.y = math.floor(newPos.y)

    if (sv) then
        if (newPos.y > 0) then
            if (not self._bouncebackEffect) then
                self._container.y = 0
            elseif (self._header ~= nil and self._header.maxHeight ~= 0) then
                self._container.y = math.floor(math.min(newPos.y * 0.5, self._header.maxHeight))
            else
                self._container.y = math.floor(math.min(newPos.y * 0.5, self._viewSize.y * ScrollPane.PULL_RATIO))
            end
        elseif (newPos.y < -self._overlapSize.y) then
            if (not self._bouncebackEffect) then
                self._container.y = -self._overlapSize.y
            elseif (self._footer ~= nil and self._footer.maxHeight > 0) then
                self._container.y = math.floor(math.max((newPos.y + self._overlapSize.y) * 0.5, -self._footer.maxHeight) - self._overlapSize.y)
            else
                self._container.y = math.floor(math.max((newPos.y + self._overlapSize.y) * 0.5, -self._viewSize.y * ScrollPane.PULL_RATIO) - self._overlapSize.y)
            end
        else
            self._container.y = newPos.y
        end
    end

    if (sh) then
        if (newPos.x > 0) then
            if (not self._bouncebackEffect) then
                self._container.x = 0
            elseif (self._header ~= nil and self._header.maxWidth ~= 0) then
                self._container.x = math.floor(math.min(newPos.x * 0.5, self._header.maxWidth))
            else
                self._container.x = math.floor(math.min(newPos.x * 0.5, self._viewSize.x * ScrollPane.PULL_RATIO))
            end
        elseif (newPos.x < 0 - self._overlapSize.x) then
            if (not self._bouncebackEffect) then
                self._container.x = -self._overlapSize.x
            elseif (self._footer ~= nil and self._footer.maxWidth > 0) then
                self._container.x = math.floor(math.max((newPos.x + self._overlapSize.x) * 0.5, -self._footer.maxWidth) - self._overlapSize.x)
            else
                self._container.x = math.floor(math.max((newPos.x + self._overlapSize.x) * 0.5, -self._viewSize.x * ScrollPane.PULL_RATIO) - self._overlapSize.x)
            end
        else
            self._container.x = newPos.x
        end
    end

    -- 更新速度
    local deltaTime = Time.unscaledDeltaTime
    local elapsed = (Time.unscaledTime - self._lastMoveTime) * 60 - 1
    if (elapsed > 1) then -- 速度衰减
        self._velocity = self._velocity * math.pow(0.833, elapsed)
    end
    local deltaPosition = pt - self._lastTouchPos
    if (not sh) then
        deltaPosition.x = 0
    end
    if (not sv) then
        deltaPosition.y = 0
    end
    self._velocity = Vector2.Lerp(self._velocity, deltaPosition / deltaTime, deltaTime * 10)

    ---速度计算使用的是本地位移，但在后续的惯性滚动判断中需要用到屏幕位移，所以这里要记录一个位移的比例。
    ---后续的处理要使用这个比例但不使用坐标转换的方法的原因是，在曲面UI等异形UI中，还无法简单地进行屏幕坐标和本地坐标的转换。

    local deltaGlobalPosition = self._lastTouchGlobalPos - evt.position
    if (deltaPosition.x ~= 0) then
        self._velocityScale = math.abs(deltaGlobalPosition.x / deltaPosition.x)
    elseif (deltaPosition.y ~= 0) then
        self._velocityScale = math.abs(deltaGlobalPosition.y / deltaPosition.y)
    end

    self._lastTouchPos = pt
    self._lastTouchGlobalPos = evt.position
    self._lastMoveTime = Time.unscaledTime

    -- 同步更新pos值
    if (self._overlapSize.x > 0) then
        self._xPos = math.clamp(-self._container.x, 0, self._overlapSize.x)
    end
    if (self._overlapSize.y > 0) then
        self._yPos = math.clamp(-self._container.y, 0, self._overlapSize.y)
    end

    -- 循环滚动特别检查
    if (self._loop ~= 0) then
        newPos = self._container.xy
        if (self:LoopCheckingCurrent()) then
            self._containerPos = self._containerPos + self._container.xy - newPos
        end
    end

    self.draggingPane = self
    self._isHoldAreaDone = true
    self._isMouseMoved = true

    self:SyncScrollBar()
    self:CheckRefreshBar()
    if (self._pageMode) then
        self:UpdatePageController()
    end
    self.onScroll:Call()
end

---@param context FairyGUI.EventContext
function ScrollPane:__touchEnd(context)
    if (self.draggingPane == self) then
        self.draggingPane = nil
    end

    self._gestureFlag = 0

    if (not self._isMouseMoved or not self._touchEffect) then
        self._isMouseMoved = false
        return
    end

    self._isMouseMoved = false
    self._tweenStart = self._container.xy

    local endPos = self._tweenStart:Clone()
    local flag = false
    if (self._container.x > 0) then
        endPos.x = 0
        flag = true
    elseif (self._container.x < -self._overlapSize.x) then
        endPos.x = -self._overlapSize.x
        flag = true
    end
    if (self._container.y > 0) then
        endPos.y = 0
        flag = true
    elseif (self._container.y < -self._overlapSize.y) then
        endPos.y = -self._overlapSize.y
        flag = true
    end

    if (flag) then
        self._tweenChange = endPos - self._tweenStart
        if (self._tweenChange.x < -UIConfig.touchDragSensitivity or self._tweenChange.y < -UIConfig.touchDragSensitivity) then
            self.onPullDownRelease:Call()
        elseif (self._tweenChange.x > UIConfig.touchDragSensitivity or self._tweenChange.y > UIConfig.touchDragSensitivity) then
            self.onPullUpRelease:Call()
        end

        if (self._headerLockedSize > 0 and endPos[self._refreshBarAxis] == 0) then
            endPos[self._refreshBarAxis] = self._headerLockedSize
            self._tweenChange = endPos - self._tweenStart
        elseif (self._footerLockedSize > 0 and endPos[self._refreshBarAxis] == -self._overlapSize[self._refreshBarAxis])  then
            local max = self._overlapSize[self._refreshBarAxis]
            if (max == 0) then
                max = math.max(self._contentSize[self._refreshBarAxis] + self._footerLockedSize - self._viewSize[self._refreshBarAxis], 0)
            else
                max = max + self._footerLockedSize
            end
            endPos[self._refreshBarAxis] = -max
            self._tweenChange = endPos - self._tweenStart
        end

        self._tweenDuration:Set(ScrollPane.TWEEN_TIME_DEFAULT, ScrollPane.TWEEN_TIME_DEFAULT)
    else
        -- 更新速度
        if (not self._inertiaDisabled) then
            local elapsed = (Time.unscaledTime - self._lastMoveTime) * 60 - 1
            if (elapsed > 1) then
                self._velocity = self._velocity * math.pow(0.833, elapsed)
            end

            -- 根据速度计算目标位置和需要时间
            endPos = self:UpdateTargetAndDuration(self._tweenStart)
        else
            self._tweenDuration:Set(ScrollPane.TWEEN_TIME_DEFAULT, ScrollPane.TWEEN_TIME_DEFAULT)
        end
        local oldChange = endPos - self._tweenStart

        -- 调整目标位置
        self:LoopCheckingTarget(endPos)
        if (self._pageMode or self._snapToItem) then
            self:AlignPosition(endPos, true)
        end

        self._tweenChange = endPos - self._tweenStart
        if (self._tweenChange.x == 0 and self._tweenChange.y == 0) then
            if (self._scrollBarDisplayAuto) then
                self:ShowScrollBar(false)
            end
            return
        end

        -- 如果目标位置已调整，随之调整需要时间
        if (self._pageMode or self._snapToItem) then
            self:FixDuration(0, oldChange.x)
            self:FixDuration(1, oldChange.y)
        end
    end

    self._tweening = 2
    self._tweenTime = Vector2.zero
    Timers.inst:AddUpdate(self._tweenUpdateDelegate)
end

---@param context FairyGUI.EventContext
function ScrollPane:__mouseWheel(context)
    if (not self._mouseWheelEnabled) then
        return
    end

    local evt = context.inputEvent
    local delta = evt.mouseWheelDelta
    delta = math.sign(delta)
    if (self._overlapSize.x > 0 and self._overlapSize.y == 0) then
        if (self._pageMode) then
            self:SetPosX(self._xPos + self._pageSize.x * delta, false)
        else
            self:SetPosX(self._xPos + self._mouseWheelStep * delta, false)
        end
    else
        if (self._pageMode) then
            self:SetPosY(self._yPos + self._pageSize.y * delta, false)
        else
            self:SetPosY(self._yPos + self._mouseWheelStep * delta, false)
        end
    end
end

function ScrollPane:__rollOver()
    self:ShowScrollBar(true)
end

function ScrollPane:__rollOut()
    self:ShowScrollBar(false)
end

---@param val boolean
function ScrollPane:ShowScrollBar(val)
    if (val) then
        self:onShowScrollBar(true)
        Timers.inst:Remove(self._showScrollBarDelegate)
    else
        Timers.inst:Add(0.5, 1, self._showScrollBarDelegate, val)
    end
end

---@param obj any
function ScrollPane:onShowScrollBar(obj)
    if (self._owner.displayObject == nil or self._owner.displayObject.isDisposed) then
        return
    end

    self._scrollBarVisible = obj and self._viewSize.x > 0 and self._viewSize.y > 0
    if (self._vtScrollBar ~= nil) then
        self._vtScrollBar.displayObject.visible = self._scrollBarVisible and not self._vScrollNone
    end
    if (self._hzScrollBar ~= nil) then
        self._hzScrollBar.displayObject.visible = self._scrollBarVisible and not self._hScrollNone
    end
end

---@param division number
---@param axis
---@return number
function ScrollPane:GetLoopPartSize(division, axis)
    return (self._contentSize[axis] + (axis == 0 and self._owner.columnGap or self._owner.lineGap)) / division
end

---对当前的滚动位置进行循环滚动边界检查。当到达边界时，回退一半内容区域（循环滚动内容大小通常是真实内容大小的偶数倍）。
---@return boolean
function ScrollPane:LoopCheckingCurrent()
    local changed = false
    if (self._loop == 1 and self._overlapSize.x > 0) then
        if (self._xPos < 0.001) then
            self._xPos = self._xPos + self:GetLoopPartSize(2, 0)
            changed = true
        elseif (self._xPos >= self._overlapSize.x) then
            self._xPos = self._xPos - self:GetLoopPartSize(2, 0)
            changed = true
        end
    elseif (self._loop == 2 and self._overlapSize.y > 0) then
        if (self._yPos < 0.001) then
            self._yPos = self._yPos + self:GetLoopPartSize(2, 1)
            changed = true
        elseif (self._yPos >= self._overlapSize.y) then
            self._yPos = self._yPos - self:GetLoopPartSize(2, 1)
            changed = true
        end
    end

    if (changed) then
        self._container:SetXY(math.floor(-self._xPos), math.floor(-self._yPos))
    end

    return changed
end

---@overload fun(endPos:Love2DEngine.Vector2)
---@param endPos Love2DEngine.Vector2 @ref
---@param axis number
function ScrollPane:LoopCheckingTarget(endPos, axis)
    if nil == axis then
        if self._loop == 1 then axis = 0
        elseif self._loop == 2 then axis = 1
        else return end
    end

    if (endPos[axis] > 0) then
        local halfSize = self:GetLoopPartSize(2, axis)
        local tmp = self._tweenStart[axis] - halfSize
        if (tmp <= 0 and tmp >= -self._overlapSize[axis]) then
            endPos[axis] = endPos[axis] - halfSize
            self._tweenStart[axis] = tmp
        end
    elseif (endPos[axis] < -self._overlapSize[axis]) then
        local halfSize = self:GetLoopPartSize(2, axis)
        local tmp = self._tweenStart[axis] + halfSize
        if (tmp <= 0 and tmp >= -self._overlapSize[axis]) then
            endPos[axis] = endPos[axis] + halfSize
            self._tweenStart[axis] = tmp
        end
    end
end

---@param value number @ref
---@param axis number
---@return number
function ScrollPane:LoopCheckingNewPos(value, axis)
    if (self._overlapSize[axis] == 0) then
        return value
    end

    local pos = axis == 0 and self._xPos or self._yPos
    local changed = false
    if (value < 0.001) then
        value = value + self:GetLoopPartSize(2, axis)
        if (value > pos) then
            local v = self:GetLoopPartSize(6, axis)
            v = math.ceil((value - pos) / v) * v
            pos = math.clamp(pos + v, 0, self._overlapSize[axis])
            changed = true
        end
    elseif (value >= self._overlapSize[axis]) then
        value = value - self:GetLoopPartSize(2, axis)
        if (value < pos) then
            local v = self:GetLoopPartSize(6, axis)
            v = math.ceil((pos - value) / v) * v
            pos = math.clamp(pos - v, 0, self._overlapSize[axis])
            changed = true
        end
    end

    if (changed) then
        if (axis == 0) then
            self._container.x = -math.floor(pos)
        else
            self._container.y = -math.floor(pos)
        end
    end

    return value
end

---从oldPos滚动至pos，调整pos位置对齐页面、对齐item等（如果需要）。
---@param pos Love2DEngine.Vector2 @ref
---@param inertialScrolling boolean
function ScrollPane:AlignPosition(pos, inertialScrolling)
    if (self._pageMode) then
        pos.x = self:AlignByPage(pos.x, 0, inertialScrolling)
        pos.y = self:AlignByPage(pos.y, 1, inertialScrolling)
    elseif (self._snapToItem) then
        local tmpX = -pos.x
        local tmpY = -pos.y
        tmpX, tmpY = self._owner:GetSnappingPosition(tmpX, tmpY)
        if (pos.x < 0 and pos.x > -self._overlapSize.x) then
            pos.x = -tmpX
        end
        if (pos.y < 0 and pos.y > -self._overlapSize.y) then
            pos.y = -tmpY
        end
    end
end

---@param pos number
---@param axis number
---@param inertialScrolling boolean
---@return number
function ScrollPane:AlignByPage(pos, axis, inertialScrolling)
    local page

    if (pos > 0) then
        page = 0
    elseif (pos < -self._overlapSize[axis]) then
        page = math.ceil(self._contentSize[axis] / self._pageSize[axis]) - 1
    else
        page = math.floor(-pos / self._pageSize[axis])
        local change = inertialScrolling and (pos - self._containerPos[axis]) or (pos - self._container.xy[axis])
        local testPageSize = math.min(self._pageSize[axis], self._contentSize[axis] - (page + 1) * self._pageSize[axis])
        local delta = -pos - page * self._pageSize[axis]

        -- 页面吸附策略
        if (math.abs(change) > self._pageSize[axis]) then-- 如果滚动距离超过1页,则需要超过页面的一半，才能到更下一页
            if (delta > testPageSize * 0.5) then
                page = page + 1
            end
        else -- 否则只需要页面的1/3，当然，需要考虑到左移和右移的情况
            if (delta > testPageSize * (change < 0 and 0.3 or 0.7)) then
                page = page + 1
            end
        end

        -- 重新计算终点
        pos = -page * self._pageSize[axis]
        if (pos < -self._overlapSize[axis]) then -- 最后一页未必有pageSize那么大
            pos = -self._overlapSize[axis]
        end
    end

    -- 惯性滚动模式下，会增加判断尽量不要滚动超过一页
    if (inertialScrolling) then
        local oldPos = self._tweenStart[axis]
        local oldPage
        if (oldPos > 0) then
            oldPage = 0
        elseif (oldPos < -self._overlapSize[axis]) then
            oldPage = math.ceil(self._contentSize[axis] / self._pageSize[axis]) - 1
        else
            oldPage = math.floor(-oldPos / self._pageSize[axis])
        end
        local startPage = math.floor(-self._containerPos[axis] / self._pageSize[axis])
        if (math.abs(page - startPage) > 1 and math.abs(oldPage - startPage) <= 1) then
            if (page > startPage) then
                page = startPage + 1
            else
                page = startPage - 1
            end
            pos = -page * self._pageSize[axis]
        end
    end

    return pos
end

---根据当前速度，计算滚动的目标位置，以及到达时间。
---@overload fun(orignPos:Love2DEngine.Vector2):Love2DEngine.Vector2
---@param pos number
---@param axis number
---@return number
function ScrollPane:UpdateTargetAndDuration(pos, axis)
    if Class.isa(pos, Vector2) then
        local orignPos = pos
        local ret = Vector2.zero
        ret.x = self:UpdateTargetAndDuration(orignPos.x, 0)
        ret.y = self:UpdateTargetAndDuration(orignPos.y, 1)
        return ret
    end

    local v = self._velocity[axis]
    local duration = 0

    if (pos > 0) then
        pos = 0
    elseif (pos < -self._overlapSize[axis]) then
        pos = -self._overlapSize[axis]
    else
        -- 以屏幕像素为基准
        local v2 = math.abs(v) * self._velocityScale
        -- 在移动设备上，需要对不同分辨率做一个适配，我们的速度判断以1136分辨率为基准
        if (Stage.touchScreen) then
            v2 = v2 * 1136 / math.max(Screen.width, Screen.height)
        end
        -- 这里有一些阈值的处理，因为在低速内，不希望产生较大的滚动（甚至不滚动）
        local ratio = 0
        if (self._pageMode or not Stage.touchScreen) then
            if (v2 > 500) then
                ratio = math.pow((v2 - 500) / 500, 2)
            end
        else
            if (v2 > 1000) then
                ratio = math.pow((v2 - 1000) / 1000, 2)
            end
        end

        if (ratio ~= 0) then
            if (ratio > 1) then
                ratio = 1
            end

            v2 = v2 * ratio
            v = v * ratio
            self._velocity[axis] = v

            -- 算法：v*（self._decelerationRate的n次幂）= 60，即在n帧后速度降为60（假设每秒60帧）。
            duration = math.log(60 / v2, self._decelerationRate) / 60

            -- 计算距离要使用本地速度
            -- 理论公式貌似滚动的距离不够，改为经验公式
            -- float change = (int)((v/ 60 - 1) / (1 - self._decelerationRate))
            local change = math.floor(v * duration * 0.4)
            pos = pos + change
        end
    end

    if (duration < ScrollPane.TWEEN_TIME_DEFAULT) then
        duration = ScrollPane.TWEEN_TIME_DEFAULT
    end
    self._tweenDuration[axis] = duration

    return pos
end

---根据修改后的tweenChange重新计算减速时间。
---@param axis number
---@param oldChange number
function ScrollPane:FixDuration(axis, oldChange)
    if (self._tweenChange[axis] == 0 or math.abs(self._tweenChange[axis]) >= math.abs(oldChange)) then
        return
    end

    local newDuration = math.abs(self._tweenChange[axis] / oldChange) * self._tweenDuration[axis]
    if (newDuration < ScrollPane.TWEEN_TIME_DEFAULT) then
        newDuration = ScrollPane.TWEEN_TIME_DEFAULT
    end

    self._tweenDuration[axis] = newDuration
end

function ScrollPane:KillTween()
    if (self._tweening == 1) then -- 取消类型为1的tween需立刻设置到终点
        self._container.xy = self._tweenStart + self._tweenChange
        self.onScroll:Call()
    end

    self._tweening = 0
    Timers.inst:Remove(self._tweenUpdateDelegate)
    self.onScrollEnd:Call()
end

function ScrollPane:CheckRefreshBar()
    if (self._header == nil and self._footer == nil) then
        return
    end

    local pos = self._container.xy[self._refreshBarAxis]
    if (self._header ~= nil) then
        if (pos > 0) then
            if (self._header.displayObject.parent == nil) then
                self._maskContainer:AddChildAt(self._header.displayObject, 0)
            end
            local vec = self._header.size
            vec[self._refreshBarAxis] = pos
            self._header.size = vec
        else
            if (self._header.displayObject.parent ~= nil) then
                self._maskContainer:RemoveChild(self._header.displayObject)
            end
        end
    end

    if (self._footer ~= nil) then
        local max = self._overlapSize[self._refreshBarAxis]
        if (pos < -max or max == 0 and self._footerLockedSize > 0) then
            if (self._footer.displayObject.parent == nil) then
                self._maskContainer:AddChildAt(self._footer.displayObject, 0)
            end

            local vec  = self._footer.xy
            if (max > 0) then
                vec[self._refreshBarAxis] = pos + self._contentSize[self._refreshBarAxis]
            else
                vec[self._refreshBarAxis] = math.max(math.min(pos + self._viewSize[self._refreshBarAxis], self._viewSize[self._refreshBarAxis] - self._footerLockedSize), self._viewSize[self._refreshBarAxis] - self._contentSize[self._refreshBarAxis])
            end
            self._footer.xy = vec

            vec = self._footer.size
            if (max > 0) then
                vec[self._refreshBarAxis] = -max - pos
            else
                vec[self._refreshBarAxis] = self._viewSize[self._refreshBarAxis] - self._footer.xy[self._refreshBarAxis]
            end
            self._footer.size = vec
        else
            if (self._footer.displayObject.parent ~= nil) then
                self._maskContainer:RemoveChild(self._footer.displayObject)
            end
        end
    end
end

---@param param any
function ScrollPane:TweenUpdate(param)
    if (self._owner.displayObject == nil or self._owner.displayObject.isDisposed) then
        Timers.inst:Remove(self._tweenUpdateDelegate)
        return
    end

    local nx = self:RunTween(0)
    local ny = self:RunTween(1)

    self._container:SetXY(nx, ny)

    if (self._tweening == 2) then
        if (self._overlapSize.x > 0) then
            self._xPos = math.clamp(-nx, 0, self._overlapSize.x)
        end
        if (self._overlapSize.y > 0) then
            self._yPos = math.clamp(-ny, 0, self._overlapSize.y)
        end

        if (self._pageMode) then
            self:UpdatePageController()
        end
    end

    if (self._tweenChange.x == 0 and self._tweenChange.y == 0) then
        self._tweening = 0
        Timers.inst:Remove(self._tweenUpdateDelegate)

        self:LoopCheckingCurrent()

        self:SyncScrollBar(true)
        self:CheckRefreshBar()
        self.onScroll:Call()
        self.onScrollEnd:Call()
    else
        self:SyncScrollBar(false)
        self:CheckRefreshBar()
        self.onScroll:Call()
    end
end

---@param axis number
---@return number
function ScrollPane:RunTween(axis)
    local newValue
    if (self._tweenChange[axis] ~= 0) then
        self._tweenTime[axis] = self._tweenTime[axis] + Time.unscaledDeltaTime
        if (self._tweenTime[axis] >= self._tweenDuration[axis]) then
            newValue = self._tweenStart[axis] + self._tweenChange[axis]
            self._tweenChange[axis] = 0
        else
            local ratio = self:EaseFunc(self._tweenTime[axis], self._tweenDuration[axis])
            newValue = self._tweenStart[axis] + math.floor(self._tweenChange[axis] * ratio)
        end

        local threshold1 = 0
        local threshold2 = -self._overlapSize[axis]
        if (self._headerLockedSize > 0 and self._refreshBarAxis == axis) then
            threshold1 = self._headerLockedSize
        end
        if (self._footerLockedSize > 0 and self._refreshBarAxis == axis) then
            local max = self._overlapSize[self._refreshBarAxis]
            if (max == 0) then
                max = math.max(self._contentSize[self._refreshBarAxis] + self._footerLockedSize - self._viewSize[self._refreshBarAxis], 0)
            else
                max = max + self._footerLockedSize
            end
            threshold2 = -max
        end

        if (self._tweening == 2 and self._bouncebackEffect) then
            if (newValue > 20 + threshold1 and self._tweenChange[axis] > 0
                    or newValue > threshold1 and self._tweenChange[axis] == 0) then -- 开始回弹
                self._tweenTime[axis] = 0
                self._tweenDuration[axis] = ScrollPane.TWEEN_TIME_DEFAULT
                self._tweenChange[axis] = -newValue + threshold1
                self._tweenStart[axis] = newValue
            elseif (newValue < threshold2 - 20 and self._tweenChange[axis] < 0
                    or newValue < threshold2 and self._tweenChange[axis] == 0) then -- 开始回弹
                self._tweenTime[axis] = 0
                self._tweenDuration[axis] = ScrollPane.TWEEN_TIME_DEFAULT
                self._tweenChange[axis] = threshold2 - newValue
                self._tweenStart[axis] = newValue
            end
        else
            if (newValue > threshold1) then
                newValue = threshold1
                self._tweenChange[axis] = 0
            elseif (newValue < threshold2) then
                newValue = threshold2
                self._tweenChange[axis] = 0
            end
        end
    else
        newValue = self._container.xy[axis]
    end

    return newValue
end

---@param t number
---@param d number
function ScrollPane:EaseFunc(t, d)
    t = t / d - 1
    return t * t * t + 1
end


local __get = Class.init_get(ScrollPane)
local __set = Class.init_set(ScrollPane)

---@param self FairyGUI.ScrollPane
__get.owner = function(self) return self._owner end

---@param self FairyGUI.ScrollPane
__get.hzScrollBar = function(self) return self._hzScrollBar end

---@param self FairyGUI.ScrollPane
__get.vtScrollBar = function(self) return self._vtScrollBar end

---@param self FairyGUI.ScrollPane
__get.header = function(self) return self._header end

---@param self FairyGUI.ScrollPane
__get.footer = function(self) return self._footer end

---@param self FairyGUI.ScrollPane
__get.bouncebackEffect = function(self)  return self._bouncebackEffect  end

---@param self FairyGUI.ScrollPane
---@param val boolean
__set.bouncebackEffect = function(self, val)  self._bouncebackEffect = val  end

---@param self FairyGUI.ScrollPane
__get.touchEffect = function(self)  return self._touchEffect  end

---@param self FairyGUI.ScrollPane
---@param val boolean
__set.touchEffect = function(self, val)  self._touchEffect = val  end

---@param self FairyGUI.ScrollPane
__get.inertiaDisabled = function(self)  return self._inertiaDisabled  end

---@param self FairyGUI.ScrollPane
---@param val boolean
__set.inertiaDisabled = function(self, val)  self._inertiaDisabled = val  end

---@param self FairyGUI.ScrollPane
__get.softnessOnTopOrLeftSide = function(self)  return self._softnessOnTopOrLeftSide  end

---@param self FairyGUI.ScrollPane
---@param val boolean
__set.softnessOnTopOrLeftSide = function(self, val)  self._softnessOnTopOrLeftSide = val  end

---@param self FairyGUI.ScrollPane
__get.pageController = function(self) return self._pageController end

---@param self FairyGUI.ScrollPane
---@param val FairyGUI.Controller
__set.pageController = function(self, val) self._pageController = val end

---@param self FairyGUI.ScrollPane
__get.scrollStep = function(self)  return self._scrollStep  end

---@param self FairyGUI.ScrollPane
---@param val number
__set.scrollStep = function(self, val)
    self._scrollStep = val
    if (self._scrollStep == 0) then
        self._scrollStep = UIConfig.defaultScrollStep
    end
    self._mouseWheelStep = self._scrollStep * 2
end

---@param self FairyGUI.ScrollPane
__get.snapToItem = function(self)  return self._snapToItem  end

---@param self FairyGUI.ScrollPane
---@param val boolean
__set.snapToItem = function(self, val)  self._snapToItem = val  end

---@param self FairyGUI.ScrollPane
__get.pageMode = function(self)  return self._pageMode  end

---@param self FairyGUI.ScrollPane
---@param val boolean
__set.pageMode = function(self, val)  self._pageMode = val  end

---@param self FairyGUI.ScrollPane
__get.mouseWheelEnabled = function(self)  return self._mouseWheelEnabled  end

---@param self FairyGUI.ScrollPane
---@param val boolean
__set.mouseWheelEnabled = function(self, val)  self._mouseWheelEnabled = val  end

---@param self FairyGUI.ScrollPane
__get.decelerationRate = function(self)  return self._decelerationRate  end

---@param self FairyGUI.ScrollPane
---@param val number
__set.decelerationRate = function(self, val)  self._decelerationRate = val  end

---@param self FairyGUI.ScrollPane
__get.percX = function(self)  return self._overlapSize.x == 0 and 0 or self._xPos / self._overlapSize.x  end

---@param self FairyGUI.ScrollPane
---@param val number
__set.percX = function(self, val)  self:SetPercX(val, false)  end

---@param self FairyGUI.ScrollPane
__get.percY = function(self)  return self._overlapSize.y == 0 and 0 or self._yPos / self._overlapSize.y  end

---@param self FairyGUI.ScrollPane
---@param val number
__set.percY = function(self, val)  self:SetPercY(val, false)  end

---@param self FairyGUI.ScrollPane
__get.posX = function(self)  return self._xPos  end

---@param self FairyGUI.ScrollPane
---@param val number
__set.posX = function(self, val)  self:SetPosX(val, false)  end

---@param self FairyGUI.ScrollPane
__get.posY = function(self)  return self._yPos  end

---@param self FairyGUI.ScrollPane
---@param val number
__set.posY = function(self, val)  self:SetPosY(val, false)  end

---@param self FairyGUI.ScrollPane
__get.currentPageX = function(self)
    if (not self._pageMode) then
        return 0
    end

    local page = math.floor(self._xPos / self._pageSize.x)
    if (self._xPos - page * self._pageSize.x > self._pageSize.x * 0.5) then
        page = page + 1
    end

    return page
end

---@param self FairyGUI.ScrollPane
---@param val number
__set.currentPageX = function(self, val)
    if (not self._pageMode) then
        return
    end

    if (self._overlapSize.x > 0) then
        self:SetPosX(val * self._pageSize.x, false)
    end
end

---@param self FairyGUI.ScrollPane
__get.isBottomMost = function(self)  return self._yPos == self._overlapSize.y or self._overlapSize.y == 0  end

---@param self FairyGUI.ScrollPane
__get.isRightMost = function(self)  return self._xPos == self._overlapSize.x or self._overlapSize.x == 0  end

---@param self FairyGUI.ScrollPane
__get.currentPageY = function(self)
    if (not self._pageMode) then
        return 0
    end

    local page = math.floor(self._yPos / self._pageSize.y)
    if (self._yPos - page * self._pageSize.y > self._pageSize.y * 0.5) then
        page = page + 1
    end

    return page
end

---@param self FairyGUI.ScrollPane
---@param val number
__set.currentPageY = function(self, val)
    if (self._overlapSize.y > 0) then
        self:SetPosY(val * self._pageSize.y, false)
    end
end

---@param self FairyGUI.ScrollPane
__get.scrollingPosX = function(self) return math.clamp(-self._container.x, 0, self._overlapSize.x) end


---@param self FairyGUI.ScrollPane
__get.scrollingPosY = function(self) return math.clamp(-self._container.y, 0, self._overlapSize.y) end


---@param self FairyGUI.ScrollPane
__get.contentWidth = function(self) return self._contentSize.x end


---@param self FairyGUI.ScrollPane
__get.contentHeight = function(self) return self._contentSize.y end

---@param self FairyGUI.ScrollPane
__get.viewWidth = function(self)  return self._viewSize.x  end

---@param self FairyGUI.ScrollPane
---@param val number
__set.viewWidth = function(self, val)
   val = val + self._owner.margin.left + self._owner.margin.right
   if (self._vtScrollBar ~= nil) then
       val = val + self._vtScrollBar.width
   end
   self._owner.width = val
end

---@param self FairyGUI.ScrollPane
__get.viewHeight = function(self)  return self._viewSize.y  end

---@param self FairyGUI.ScrollPane
---@param val number
__set.viewHeight = function(self, val)
   val = val + self._owner.margin.top + self._owner.margin.bottom
   if (self._hzScrollBar ~= nil) then
       val = val + self._hzScrollBar.height
   end
   self._owner.height = val
end


FairyGUI.ScrollPane = ScrollPane
return ScrollPane