--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:58
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2
local Color = Love2DEngine.Color

local GComponent = FairyGUI.GComponent
local GRoot = FairyGUI.GRoot
local UIConfig = FairyGUI.UIConfig
local EventCallback0 = FairyGUI.EventCallback0
local EventCallback1 = FairyGUI.EventCallback1
local UIPackage = FairyGUI.UIPackage
local RelationType = FairyGUI.RelationType
local GGraph = FairyGUI.GGraph

---@class FairyGUI.Window:FairyGUI.GComponent
---Window class.
---窗口使用前首先要设置窗口中需要显示的内容，这通常是在编辑器里制作好的，可以直接使用Window.contentPane进行设置。
---建议把设置contentPane等初始化操作放置到Window.onInit方法中。
---另外，FairyGUI还提供了一套机制用于窗口动态创建。动态创建是指初始时仅指定窗口需要使用的资源，等窗口需要显示时才实际开始构建窗口的内容。
---首先需要在窗口的构造函数中调用Window.addUISource。这个方法需要一个IUISource类型的参数，而IUISource是一个接口，
---用户需要自行实现载入相关UI包的逻辑。当窗口第一次显示之前，IUISource的加载方法将会被调用，并等待载入完成后才返回执行Window.OnInit，然后窗口才会显示。
---如果你需要窗口显示时播放动画效果，那么覆盖doShowAnimation编写你的动画代码，并且在动画结束后调用onShown。覆盖onShown编写其他需要在窗口显示时处理的业务逻辑。
---如果你需要窗口隐藏时播放动画效果，那么覆盖doHideAnimation编写你的动画代码，并且在动画结束时调用Window.hideImmediately（注意不是直接调用onHide！）。覆盖onHide编写其他需要在窗口隐藏时处理的业务逻辑。
---@field public bringToFontOnClick boolean
---@field public modalWaiting boolean
---@field public modal boolean
---@field public isTop boolean
---@field public isShowing boolean
---@field public contentPane FairyGUI.GComponent
---@field public frame FairyGUI.GComponent
---@field public closeButton FairyGUI.GObject
---@field public dragArea FairyGUI.GObject
---@field public contentArea FairyGUI.GObject
---@field public modalWaitingPane FairyGUI.GObject
---@field protected _requestingCmd number
---@field private _frame FairyGUI.GComponent
---@field private _contentPane FairyGUI.GComponent
---@field private _modalWaitPane FairyGUI.GObject
---@field private _closeButton FairyGUI.GObject
---@field private _dragArea FairyGUI.GObject
---@field private _contentArea FairyGUI.GObject
---@field private _modal boolean
---@field private _uiSources FairyGUI.IUISource[]
---@field private _inited boolean
---@field private _loading boolean
local Window = Class.inheritsFrom('Window', nil, GComponent)

function Window:__ctor()
    GComponent.__ctor(self)

    self._uiSources = {}
    self.focusable = true
    self.bringToFontOnClick = UIConfig.bringWindowToFrontOnClick

    self.__onShownDelegate = EventCallback0.new(self.__onShown, self)
    self.__onHideDelegate = EventCallback0.new(self.__onHide, self)
    self.__touchBeginDelegate = EventCallback0.new(self.__touchBegin, self)

    self.displayObject.onAddedToStage:Add(self.__onShownDelegate)
    self.displayObject.onRemovedFromStage:Add(self.__onHideDelegate)
    self.displayObject.onTouchBegin:AddCapture(self.__touchBeginDelegate)

    self.gameObjectName = "Window"
    self:SetHome(GRoot.inst)

    self.closeEventHandlerDelegate = EventCallback0.new(self.closeEventHandler, self)
    self.__touchBeginDelegate = EventCallback1.new(self.__touchBegin, self)
    self.__dragStartDelegate = EventCallback1.new(self.__dragStart, self)
end

---Set a UISource to this window. It must call before the window is shown. When the window is first time to show,
---UISource.Load is called. Only after all UISource is loaded, the window will continue to init.
---为窗口添加一个源。这个方法建议在构造函数调用。当窗口第一次显示前，UISource的Load方法将被调用，然后只有所有的UISource
---都ready后，窗口才会继续初始化和显示。
---@param source FairyGUI.IUISource
function Window:AddUISource(source)
    table.insert(self._uiSources, source)
end

function Window:Show()
    GRoot.inst:ShowWindow(self)
end

---@param r FairyGUI.GRoot
function Window:ShowOn(r)
    r:ShowWindow(self)
end

function Window:Hide()
    if self.isShowing then
        self:DoHideAnimation()
    end
end

function Window:HideImmediately()
    self.root:HideWindowImmediately(self)
end

---@param r FairyGUI.GRoot
---@param restraint boolean
function Window:CenterOn(r, restraint)
    self:SetXY((r.width - self.width) / 2, (r.height - self.height) / 2)
    if restraint then
        self:AddRelation(r, RelationType.Center_Center)
        self:AddRelation(r, RelationType.Middle_Middle)
    end
end

function Window:ToggleStatus()
    if self.isTop then
        self:Hide()
    else
        self:Show()
    end
end

function Window:BringToFront()
    self.root:BringToFront(self)
end

---Display a modal waiting sign in the front.
---显示一个等待标志在最前面。等待标志的资源可以通过UIConfig.windowModalWaiting。等待标志组件会设置为屏幕大小，请内部做好关联。
---还可以设定一个requestingCmd作为等待的命令字，在CloseModalWait里传入相同的命令字ModalWait将结束，否则CloseModalWait无效。
---@overload fun()
---@param requestingCmd number
function Window:ShowModalWait(requestingCmd)
    requestingCmd = requestingCmd or 0

    if (requestingCmd ~= 0) then
        self._requestingCmd = requestingCmd
    end

    if (UIConfig.windowModalWaiting ~= nil) then
        if (self._modalWaitPane == nil) then
            self._modalWaitPane = UIPackage.CreateObjectFromURL(UIConfig.windowModalWaiting)
            self._modalWaitPane:SetHome(self)
        end

        self:LayoutModalWaitPane()

        self:AddChild(self._modalWaitPane)
    end
end

function Window:LayoutModalWaitPane()
    if (self._contentArea ~= nil) then
        local pt = self._frame:LocalToGlobal(Vector2.zero)
        pt = self:GlobalToLocal(pt)
        self._modalWaitPane:SetXY(pt.x + self._contentArea.x, pt.y + self._contentArea.y)
        self._modalWaitPane:SetSize(self._contentArea.width, self._contentArea.height)
    else
        self._modalWaitPane:SetSize(self.width, self.height)
    end
end

---Close modal waiting. If rquestingCmd is equal to the value you transfer in ShowModalWait, mowal wait will be closed.
---Otherwise, this function has no effect.
---关闭模式等待。如果requestingCmd和ShowModalWait传入的不相同，则这个函数没有任何动作，立即返回。
---@overload fun()
---@param requestingCmd number
---@return boolean
function Window:CloseModalWait(requestingCmd)
    requestingCmd = requestingCmd or 0
    if (requestingCmd ~= 0) then
        if (self._requestingCmd ~= requestingCmd) then
            return false
        end
    end

    self._requestingCmd = 0

    if (self._modalWaitPane ~= nil and self._modalWaitPane.parent ~= nil) then
        self:RemoveChild(self._modalWaitPane)
    end

    return true
end

function Window:Init()
    if (self._inited or self._loading) then
        return
    end

    if (#self._uiSources > 0) then
        self._loading = false
        for _, lib in ipairs(self._uiSources) do
            if (not lib.loaded) then
                lib:Load(self.__uiLoadComplete)
                self._loading = true
            end
        end

        if (not self._loading) then
            self:_init()
        end
    else
        self:_init()
    end
end

function Window:OnInit() end
function Window:OnShown() end
function Window:OnHide() end

function Window:DoShowAnimation()
    self:OnShown()
end

function Window:DoHideAnimation()
    self:HideImmediately()
end

function Window:__uiLoadComplete()
    for i, lib in ipairs(self._uiSources) do
        if not lib.loaded then
            return
        end
    end
    self._loading = false
    self:_init()
end

function Window:_init()
    self._inited = true
    self:OnInit()

    if (self.isShowing) then
        self:DoShowAnimation()
    end
end

function Window:Dispose()
    if (self._modalWaitPane ~= nil and self._modalWaitPane.parent == nil) then
        self._modalWaitPane:Dispose()
    end

    GComponent:Dispose()
end

function Window:closeEventHandler()
    self:Hide()
end

function Window:__onShown()
    if not self._inited then
        self:Init()
    else
        self:DoShowAnimation()
    end
end

function Window:__onHide()
    self:CloseModalWait()
    self:OnHide()
end

---@param context FairyGUI.EventContext
function Window:__touchBegin(context)
    if self.isShowing and self.bringToFontOnClick then
        self:BringToFront()
    end
end

---@param context FairyGUI.EventContext
function Window:__dragStart(context)
    context:PreventDefault()

    self:StartDrag(context.data)
end

local __get = Class.init_get(Window)
local __set = Class.init_set(Window)

---@param self FairyGUI.Window
__get.isShowing = function(self) return self.parent ~= nil end

---@param self FairyGUI.Window
__get.isTop = function(self) return self.parent ~= nil and self.parent:GetChildIndex(self) == self.parent.numChildren end

---@param self FairyGUI.Window
__get.modal = function(self) return self._modal end

---@param self FairyGUI.Window
__set.modal = function(self, val) self._modal = val end

---@param self FairyGUI.Window
__get.modalWaiting = function(self) return self._modalWaitPane ~= nil and self._modalWaitPane.inContainer end

---@param self FairyGUI.Window
__get.contentPane = function(self) return self._contentPane end

---@param self FairyGUI.Window
---@param val FairyGUI.GComponent
__set.contentPane = function(self, val)
    if (self._contentPane ~= val) then
        if (self._contentPane ~= nil) then
            self:RemoveChild(self._contentPane)
        end
        self._contentPane = val
        if (self._contentPane ~= nil) then
            self.gameObjectName = "Window - " .. self._contentPane.gameObjectName
            self._contentPane.gameObjectName = "ContentPane"

            self:AddChild(self._contentPane)
            self:SetSize(self._contentPane.width, self._contentPane.height)
            self._contentPane:AddRelation(self, RelationType.Size)
            self._contentPane.fairyBatching = true
            self._frame = self._contentPane:GetChild("frame")
            if (self._frame ~= nil) then
                self.closeButton = self._frame:GetChild("closeButton")
                self.dragArea = self._frame:GetChild("dragArea")
                self.contentArea = self._frame:GetChild("contentArea")
            end
        else
            self._frame = nil
            self.gameObjectName = "Window"
        end
    end
end

---@param self FairyGUI.Window
__get.frame = function(self) return self._frame end

---@param self FairyGUI.Window
__get.closeButton = function(self) return self._closeButton end

---@param self FairyGUI.Window
---@param val FairyGUI.GObject
__set.closeButton = function(self, val)
    if (self._closeButton ~= nil) then
        self._closeButton.onClick:Remove(self.closeEventHandlerDelegate)
    end
    self._closeButton = value
    if (self._closeButton ~= nil) then
        self._closeButton.onClick:Add(self.closeEventHandlerDelegate)
    end
end

---@param self FairyGUI.Window
__get.dragArea = function(self) return self._dragArea end

---@param self FairyGUI.Window
---@param val FairyGUI.GObject
__set.dragArea = function(self, val)
    if (self._dragArea ~= val) then
        if (self._dragArea ~= nil) then
            self._dragArea.draggable = false
            self._dragArea.onDragStart:Remove(self.__dragStartDelegate)
        end

        self._dragArea = val
        if (self._dragArea ~= nil) then
            if (self._dragArea:isa(GGraph) and self._dragArea.displayObject == nil) then
                self._dragArea:DrawRect(self._dragArea.width, self._dragArea.height, 0, Color.clear, Color.clear)
            end
            self._dragArea.draggable = true
            self._dragArea.onDragStart:Add(self.__dragStartDelegate)
        end
    end
end

---@param self FairyGUI.Window
__get.contentArea = function(self) return self._contentArea end

---@param self FairyGUI.Window
---@param val FairyGUI.GObject
__set.contentArea = function(self, val) self._contentArea = val end

---@param self FairyGUI.Window
__get.modalWaitingPane = function(self) return self._modalWaitPane end


FairyGUI.Window = Window
return Window