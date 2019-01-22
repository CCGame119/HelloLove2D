--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2019/1/25 11:08
--

local Class = require('libs.Class')

local Screen = Love2DEngine.Screen
local Color = Love2DEngine.Color
local Vector2 = Love2DEngine.Vector2
local Debug = Love2DEngine.Debug

local GComponent = FairyGUI.GComponent
local Timers = FairyGUI.Timers
local TimerCallback = FairyGUI.TimerCallback
local UIContentScaler = FairyGUI.UIContentScaler
local Stage = FairyGUI.Stage
local EventCallback1 = FairyGUI.EventCallback1
local Window = FairyGUI.Window
local UIConfig = FairyGUI.UIConfig
local UIPackage = FairyGUI.UIPackage
local GGraph = FairyGUI.GGraph
local RelationType = FairyGUI.RelationType

---@class FairyGUI.GRoot:FairyGUI.GComponent
---GRoot is a topmost component of UI display list.You dont need to create GRoot. It is created automatically.
---@field public contentScaleFactor number
---@field public inst FairyGUI.GRoot
---@field public modalLayer FairyGUI.GGraph
---@field public hasModalWindow boolean
---@field public modalWaiting boolean
---@field public touchTarget FairyGUI.GObject
---@field public hasAnyPopup boolean
---@field public focus FairyGUI.GObject
---@field public soundVolume number
---@field private _modalLayer FairyGUI.GGraph
---@field private _modalWaitPane FairyGUI.GObject
---@field private _popupStack FairyGUI.GObject[]
---@field private _justClosedPopups FairyGUI.GObject[]
---@field private _tooltipWin FairyGUI.GObject
---@field private _defaultTooltipWin FairyGUI.GObject
local GRoot = FairyGUI.GRoot

---@type FairyGUI.GRoot
GRoot._inst = nil

function GRoot:__ctor()
    GComponent.__ctor(self)

    self.name = "GRoot"
    self.rootContainer.name = "GRoot"
    self.rootContainer.gameObject.name = "GRoot"
    self.opaque = false

    self._popupStack = {}
    self._justClosedPopups = {}

    self.__stageTouchBeginDelegate = EventCallback1.new(self.__stageTouchBegin, self)
    Stage.inst.onTouchBegin:AddCapture(self.__stageTouchBeginDelegate)

    self.__showTooltipsWinDelegate = TimerCallback.new(self.__showTooltipsWin, self)
end

---Set content scale factor.
---@overload fun(designResolutionX:number, designResolutionY:number)
---@param designResolutionX number @Design resolution of x axis.
---@param designResolutionY number @Design resolution of y axis.
---@param screenMatchMode FairyGUI.UIContentScaler.ScreenMatchMode @Match mode.
function GRoot:SetContentScaleFactor(designResolutionX, designResolutionY, screenMatchMode)
    screenMatchMode = screenMatchMode or UIContentScaler.ScreenMatchMode.MatchWidthOrHeight
    local scaler = Stage.inst.gameObject:GetComponent(UIContentScaler)
    scaler.designResolutionX = designResolutionX
    scaler.designResolutionY = designResolutionY
    scaler.scaleMode = UIContentScaler.ScaleMode.ScaleWithScreenSize
    scaler.screenMatchMode = screenMatchMode
    scaler:ApplyChange()
    self:ApplyContentScaleFactor()
end

---This is called after screen size changed.
function GRoot:ApplyContentScaleFactor()
    self:SetSize(math.ceil(Screen.width / UIContentScaler.scaleFactor), math.ceil(Screen.height / UIContentScaler.scaleFactor))
    self:SetScale(UIContentScaler.scaleFactor, UIContentScaler.scaleFactor)
end

---Display a window.
---@param win FairyGUI.Window
function GRoot:ShowWindow(win)
    self:AddChild(win)
    self:AdjustModalLayer()
end

---Call window.Hide
---关闭一个窗口。将调用Window.Hide方法。
---@param win FairyGUI.Window
function GRoot:HideWindow(win)
    win:Hide()
end

--- Remove a window from stage immediatelly. window.Hide/window.OnHide will never be called.
--- 立刻关闭一个窗口。不会调用Window.Hide方法，Window.OnHide也不会被调用。
---@overload fun(win:FairyGUI.Window)
---@param win FairyGUI.Window
---@param dispose boolean @True to dispose the window.
function GRoot:HideWindowImmediately(win, dispose)
    dispose = dispose or false

    if (win.parent == self) then
        self:RemoveChild(win, dispose)
    elseif (dispose) then
        win:Dispose()
    end

    self:AdjustModalLayer()
end

---将一个窗口提到所有窗口的最前面
---@param win FairyGUI.Window
function GRoot:BringToFront(win)
    local cnt = self.numChildren
    local i
    if (self._modalLayer.parent ~= nil and not win.modal) then
        i = self:GetChildIndex(self._modalLayer) - 1
    else
        i = cnt
    end

    while i >= 1 do
        local g = self:GetChildAt(i)
        if (g == win) then return end
        if g:isa(Window) then
            break
        end
        i = i - 1
    end

    if (i >= 1) then
        self:SetChildIndex(win, i)
    end
end

--- Display a modal layer and a waiting sign in the front.
--- 显示一个半透明层和一个等待标志在最前面。半透明层的颜色可以通过UIConfig.modalLayerColor设定。
--- 等待标志的资源可以通过UIConfig.globalModalWaiting。等待标志组件会设置为屏幕大小，请内部做好关联。
function GRoot:ShowModalWait()
    if (UIConfig.globalModalWaiting ~= nil) then
        if (self._modalWaitPane == nil) then
            self._modalWaitPane = UIPackage.CreateObjectFromURL(UIConfig.globalModalWaiting)
            self._modalWaitPane:SetHome(self)
        end
        self._modalWaitPane:SetSize(self.width, self.height)
        self._modalWaitPane:AddRelation(self, RelationType.Size)

        self:AddChild(self._modalWaitPane)
    end
end

--- Hide modal layer and waiting sign.
function GRoot:CloseModalWait()
    if (self._modalWaitPane ~= nil and self._modalWaitPane.parent ~= nil) then
        self:RemoveChild(self._modalWaitPane)
    end
end

--- Close all windows except modal windows.
function GRoot:CloseAllExceptModals()
    for i, g in ipairs(self._children) do
        if g:isa(Window) and not g.modal then
            self:HideWindowImmediately(g)
        end
    end
end

--- Close all windows.
function GRoot:CloseAllWindows()
    for i, g in ipairs(self._children) do
        if g:isa(Window) then
            self:HideWindowImmediately(g)
        end
    end
end

--- Get window on top.
---@return FairyGUI.Window
function GRoot:GetTopWindow()
    for i = self.numChildren, 1, -1 do
        local g = self:GetChildAt(i)
        if g:isa(Window) then
            return g
        end
    end
    return nil
end

function GRoot:CreateModalLayer()
    self._modalLayer = GGraph.new()
    self._modalLayer:DrawRect(self.width, self.height, 0, Color.white, UIConfig.modalLayerColor)
    self._modalLayer:AddRelation(self, RelationType.Size)
    self._modalLayer.name = "ModalLayer"
    self._modalLayer.gameObjectName =
    self._modalLayer:SetHome(self)
end

---@param obj FairyGUI.DisplayObject
---@return FairyGUI.GObject
function GRoot:DisplayObjectToGObject(obj)
    while (obj ~= nil) do
        if (obj.gOwner ~= nil) then
            return obj.gOwner
        end

        obj = obj.parent
    end
    return nil
end

function GRoot:AdjustModalLayer()
    if (self._modalLayer == nil) then
        self:CreateModalLayer()
    end

    local cnt = self.numChildren

    if (self._modalWaitPane ~= nil and self._modalWaitPane.parent ~= nil) then
        self:SetChildIndex(self._modalWaitPane, cnt)
    end

    for i = cnt, 1, -1 do
        local g = self:GetChildAt(i)
        if g:isa(Window) and g.modal then
            if (self._modalLayer.parent == nil) then
                self:AddChildAt(self._modalLayer, i)
            else
                self:SetChildIndexBefore(self._modalLayer, i)
            end
            return
        end
    end

    if (self._modalLayer.parent ~= nil) then
        self:RemoveChild(self._modalLayer)
    end
end

---Show a  popup object.
---显示一个popup。
---popup的特点是点击popup对象外的区域，popup对象将自动消失。
---@overload fun(popup:FairyGUI.GObject)
---@overload fun(popup:FairyGUI.GObject, target:FairyGUI.GObject)
---@param popup FairyGUI.GObject
---@param target FairyGUI.GObject
---@param downward any @True to display downwards, false to display upwards, null to display automatically.
function GRoot:ShowPopup(popup, target, downward)
    if (#self._popupStack > 0) then
        local k = self._popupStack:indexOf(popup)
        if (k ~= -1) then
            for i = #self._popupStack, k, -1 do
                local last = #self._popupStack
                self:ClosePopup(self._popupStack[last])
                table.remove(self._popupStack, last)
            end
        end
    end
    self._popupStack:Add(popup)

    if (target ~= nil) then
        local p = target
        while (p ~= nil) do
            if (p.parent == self) then
                if (popup.sortingOrder < p.sortingOrder) then
                    popup.sortingOrder = p.sortingOrder
                end
                break
            end
            p = p.parent
        end
    end

    self:AddChild(popup)
    self:AdjustModalLayer()

    if popup:isa(Window) and target == nil and downward == nil then
        return
    end

    local pos = self:GetPoupPosition(popup, target, downward)
    popup.xy = pos
end

---@param popup FairyGUI.GObject
---@param target FairyGUI.GObject
---@param downward any
---@return Love2DEngine.Vector2
function GRoot:GetPoupPosition(popup, target, downward)
    local pos
    local size = Vector2.zero
    if (target ~= nil) then
        pos = target:LocalToRoot(Vector2.zero, self)
        size = target:LocalToRoot(target.size, self) - pos
    else
        pos = self:GlobalToLocal(Stage.inst.touchPosition)
    end
    local xx, yy
    xx = pos.x
    if (xx + popup.width > self.width) then
        xx = xx + size.x - popup.width
    end
    yy = pos.y + size.y
    if ((downward == nil and yy + popup.height > self.height)
            or downward ~= nil and downward == false) then
        yy = pos.y - popup.height - 1
        if (yy < 0) then
            yy = 0
            xx = xx + size.x / 2
        end
    end

    return Vector2(math.round(xx), math.round(yy))
end

---If a popup is showing, then close it; otherwise, open it.
---@overload fun(popup:FairyGUI.GObject)
---@overload fun(popup:FairyGUI.GObject, target:FairyGUI.GObject)
---@param popup FairyGUI.GObject
---@param target FairyGUI.GObject
---@param downward any
function GRoot:TogglePopup(popup, target, downward)
    if (self._justClosedPopups:indexOf(popup) ~= -1) then
        return
    end

    self:ShowPopup(popup, target, downward)
end

---@overload fun()
---@param popup FairyGUI.GObject
function GRoot:HidePopup(popup)
    if (popup ~= nil) then
        local k = self._popupStack:indexOf(popup)
        if (k ~= -1) then
            for i = #self._popupStack, k, -1 do
                local last = #self._popupStack
                self:ClosePopup(self._popupStack[last])
                self._popupStack:RemoveAt(last)
            end
        end
    else
        for i, obj in ipairs(self._popupStack) do
            self:ClosePopup(obj)
        end
        self._popupStack = {}
    end
end

---@param target FairyGUI.GObject
function GRoot:ClosePopup(target)
    if (target.parent ~= nil) then
        if target:isa(Window) then
            target:Hide()
        else
            self:RemoveChild(target)
        end
    end
end

---@param msg string
function GRoot:ShowTooltips(msg)
    if (self._defaultTooltipWin == nil) then
        local resourceURL = UIConfig.tooltipsWin
        if (string.isNullOrEmpty(resourceURL)) then
            Debug.LogWarn("FairyGUI: UIConfig.tooltipsWin not defined")
            return
        end

        self._defaultTooltipWin = UIPackage.CreateObjectFromURL(resourceURL)
        self._defaultTooltipWin:SetHome(self)
        self._defaultTooltipWin.touchable = false
    end

    self._defaultTooltipWin.text = msg
    self:ShowTooltipsWin(self._defaultTooltipWin)
end

---@param tooltipWin FairyGUI.GObject
function GRoot:ShowTooltipsWin(tooltipWin)
    self:HideTooltips()

    self._tooltipWin = tooltipWin
    Timers.inst:Add(0.1, 1, self.__showTooltipsWinDelegate)
end

---@param param any
function GRoot:__showTooltipsWin(param)
    if (self._tooltipWin == nil) then
        return
    end

    local xx = Stage.inst.touchPosition.x + 10
    local yy = Stage.inst.touchPosition.y + 20

    local pt = self:GlobalToLocal(Vector2(xx, yy))
    xx = pt.x
    yy = pt.y

    if (xx + self._tooltipWin.width > self.width) then
        xx = xx - self._tooltipWin.width
    end
    if (yy + self._tooltipWin.height > self.height) then
        yy = yy - self._tooltipWin.height - 1
        if (yy < 0) then
            yy = 0
        end
    end

    self._tooltipWin.x = math.round(xx)
    self._tooltipWin.y = math.round(yy)
    self:AddChild(self._tooltipWin)
end

function GRoot:HideTooltips()
    if (self._tooltipWin ~= nil) then
        if (self._tooltipWin.parent ~= nil) then
            self:RemoveChild(self._tooltipWin)
        end
        self._tooltipWin = nil
    end
end

---@param context FairyGUI.EventContext
function GRoot:__stageTouchBegin(context)
    if (self._tooltipWin ~= nil) then
        self:HideTooltips()
    end

    self:CheckPopups()
end

function GRoot:CheckPopups()
    self._justClosedPopups = {}
    if (#self._popupStack > 0) then
        ---@type FairyGUI.DisplayObject
        local mc = Stage.inst.touchTarget
        local handled = false
        while (mc ~= Stage.inst and mc ~= nil) do
            if (mc.gOwner ~= nil) then
                local k = self._popupStack:indexOf(mc.gOwner)
                if (k ~= -1) then
                    for i = #self._popupStack, k + 1, -1 do
                        local last = #self._popupStack
                        local popup = self._popupStack[last]
                        self:ClosePopup(popup)
                        table.insert(self._justClosedPopups, popup)
                        table.remove(self._popupStack, last)
                    end
                    handled = true
                    break
                end
            end
            mc = mc.parent
        end

        if (not handled) then
            for i = #self._popupStack, 1, -1 do
                local popup = self._popupStack[i]
                self:ClosePopup(popup)
                table.insert(self._justClosedPopups, popup)
            end
            self._popupStack = {}
        end
    end
end

function GRoot:EnableSound()
    Stage.inst:EnableSound()
end

function GRoot:DisableSound()
    Stage.inst:DisableSound()
end

---@overload fun(clip:Love2DEngine.AudioClip)
---@param clip Love2DEngine.AudioClip
---@param volumeScale number
function GRoot:PlayOneShotSound(clip, volumeScale)
    Stage.inst:PlayOneShotSound(clip, volumeScale)
end


local __get = Class.init_get(GRoot, false)
local __set = Class.init_set(GRoot, false)

---@param self FairyGUI.GRoot
__get.contentScaleFactor = function(self)
    return UIContentScaler.scaleFactor
end

---@param self FairyGUI.GRoot
__get.inst = function(self)
    if GRoot._inst == nil then
        Stage.Instantiate()
    end
    return GRoot._inst
end

---@param self FairyGUI.GRoot
__get.modalLayer = function(self)
    if self._modalLayer == nil then
        self:CreateModalLayer()
    end
    return self._modalLayer
end

---@param self FairyGUI.GRoot
__get.hasModalWindow = function(self) return self._modalLayer ~= nil and self._modalLayer.parent ~= nil end

---@param self FairyGUI.GRoot
__get.modalWaiting = function(self) return self._modalWaitPane ~= nil and self._modalWaitPane.onStage end

---@param self FairyGUI.GRoot
__get.touchTarget = function(self) return self:DisplayObjectToGObject(Stage.inst.touchTarget) end

---@param self FairyGUI.GRoot
__get.hasAnyPopup = function(self) return #self._popupStack > 0 end

---@param self FairyGUI.GRoot
__get.focus = function(self)
    local result = nil
    local mc = Stage.inst.focus
    while (mc ~= Stage.inst and mc ~= nil) do
        local gg = mc.gOwner
        if (gg ~= nil and gg.touchable and gg.focusable) then
            result = gg
            break
        end
        mc = mc.parent
    end
    return result
end

---@param self FairyGUI.GRoot
---@param val FairyGUI.GObject
__set.focus = function(self, val)
    if (val ~= nil and (not val.focusable or not val.onStage)) then
        Debug.LogError("invalid focus target")
        return
    end

    if (val == nil) then
        Stage.inst.focus = nil
    else
        Stage.inst.focus = val.displayObject
    end
end

---@param self FairyGUI.GRoot
__get.focus = function(self)
    return Stage.inst.soundVolume
end

---@param self FairyGUI.GRoot
---@param val number
__set.focus = function(self, val)
    Stage.inst.soundVolume = val
end