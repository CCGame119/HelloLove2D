--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 10:35
--
local Class = require('libs.Class')

local Rect = Love2DEngine.Rect
local Vector2 = Love2DEngine.Vector2
local Vector4 = Love2DEngine.Vector4

local ChildrenRenderOrder = FairyGUI.ChildrenRenderOrder
local Margin = FairyGUI.Margin
local EventCallback0 = FairyGUI.EventCallback0
local EventListener = FairyGUI.EventListener
local Container = FairyGUI.Container
local GObject = FairyGUI.GObject
local UpdateContext = FairyGUI.UpdateContext
local ScrollPane = FairyGUI.ScrollPane
local OverflowType = FairyGUI.OverflowType
local PixelHitTest = FairyGUI.PixelHitTest
local TranslationHelper = FairyGUI.TranslationHelper
local UIPackage = FairyGUI.UIPackage
local UIObjectFactory = FairyGUI.UIObjectFactory
local ToolSet = FairyGUI.ToolSet
local ObjectType = FairyGUI.ObjectType
local Controller = FairyGUI.Controller

---@class FairyGUI.GComponent:FairyGUI.GObject
---@field public rootContainer FairyGUI.Container @Root container.
---@field public container FairyGUI.Container @Content container. If the component is not clipped, then container==rootContainer.
---@field public scrollPane FairyGUI.ScrollPane @ScrollPane of the component. If the component is not scrollable, the value is null.
---@field public onDrop FairyGUI.EventListener @Dispatched when an object was dragged and dropped to this component.
---@field public _children FairyGUI.GObject[]
---@field public _controllers FairyGUI.Controller[]
---@field public _transitions FairyGUI.Transition[]
---@field public _buildingDisplayList boolean
---@field public _alignOffset Love2DEngine.Vector2
---@field public fairyBatching boolean
---@field public opaque boolean @If true, mouse/touch events cannot pass through the empty area of the component. Default is true.
---@field public margin FairyGUI.Margin
---@field public childrenRenderOrder FairyGUI.ChildrenRenderOrder
---@field public apexIndex number
---@field public numChildren number
---@field public Controllers FairyGUI.Controller[]
---@field public clipSoftness Love2DEngine.Vector2
---@field public mask FairyGUI.DisplayObject
---@field public reverseMask boolean
---@field public baseUserData string
---@field public viewWidth number
---@field public viewHeight number
---@field protected _margin FairyGUI.Margin
---@field protected _trackBounds boolean
---@field protected _boundsChanged boolean
---@field protected _childrenRenderOrder FairyGUI.ChildrenRenderOrder
---@field protected _apexIndex number
---@field private _clipSoftness Love2DEngine.Vector2
---@field private _sortingChildCount number
---@field private _buildDelegate FairyGUI.EventCallback0
---@field private _applyingController FairyGUI.Controller
local GComponent = Class.inheritsFrom('GComponent', nil, GObject)

function GComponent:__ctor()
    GObject.__ctor(self)

    self._children = {}
    self._controllers = {}
    self._transitions = {}
    self._margin = Margin.new()
    self._buildDelegate = EventCallback0.new(self.BuildNativeDisplayList, self)

    self.onDrop = EventListener.new(self, "onDrop")

    self._sortingChildCount = 0

    self.__addedToStageDelegate = EventCallback0.new(self.__addedToStage, self)
    self.__removedFromStageDelegate = EventCallback0.new(self.__removedFromStage, self)
end

function GComponent:CreateDisplayObject()
    self.rootContainer = Container.new("GComponent")
    self.rootContainer.gOwner = self
    self.rootContainer.onUpdate = EventCallback0.new(self.OnUpdate, self)
    self.container = self.rootContainer

    self.displayObject = self.rootContainer
end

function GComponent:Dispose()
    local cnt = #self._transitions
    for i = 1, cnt do
        local trans = self._transitions[i]
        trans:Dispose()
    end

    cnt = #self._controllers
    for i = 1, cnt do
        local c = self._controllers[i]
        c:Dispose()
    end

    if (self.scrollPane ~= nil) then
        self.scrollPane:Dispose()
    end

    GObject.Dispose(self) --Dispose native tree first, avoid DisplayObject.RemoveFromParent call

    cnt = #self._children
    for i = cnt, 1, -1 do
        local obj = self._children[i]
        obj:InternalSetParent(nil) --Avoid GObject.RemoveParent call
        obj:Dispose()
    end
end

---@param childChanged boolean
function GComponent:InvalidateBatchingState(childChanged)
    if childChanged then
        self.container:InvalidateBatchingState(childChanged)
    else
        self.rootContainer:InvalidateBatchingState()
    end
end

---Add a child to the component. It will be at the frontmost position.
---@param child FairyGUI.GObject
---@return FairyGUI.GObject
function GComponent:AddChild(child)
    self:AddChildAt(child, #self._children + 1)
    return child
end

---Adds a child to the component at a certain index.
---@param child FairyGUI.GObject
---@param index number
---@return FairyGUI.GObject
function GComponent:AddChildAt(child, index)
    local numChildren = #self._children

    if (index >= 1 and index <= numChildren + 1) then
        if (child.parent == self) then
            self:SetChildIndex(child, index)
        else
            child:RemoveFromParent()
            child:InternalSetParent(self)

            local cnt = #self._children
            if (child.sortingOrder ~= 0) then
                self._sortingChildCount = self._sortingChildCount + 1
                index = self:GetInsertPosForSortingChild(child)
            elseif (self._sortingChildCount > 0) then
                if (index > (cnt - self._sortingChildCount)) then
                    index = cnt - self._sortingChildCount
                end
            end

            table.insert(self._children, index, child)
            self:ChildStateChanged(child)
            self:SetBoundsChangedFlag()
            if (child.group ~= nil) then
                child.group:SetBoundsChangedFlag(true)
            end
        end
        return child
    else
        error("Invalid child index: " .. index .. ">" .. numChildren)
    end
end

---@param target FairyGUI.GObject
---@return number
function GComponent:GetInsertPosForSortingChild(target)
    local index
    for i, child in ipairs(self._children) do
        index = i
        if child ~= target then
            if target.sortingOrder < child.sortingOrder then
                break
            end
        end
    end
    return index
end

---@param child FairyGUI.GObject
---@param dispose boolean @default: false
---@return FairyGUI.GObject
function GComponent:RemoveChild(child, dispose)
    local childIndex = self._children:indexOf(child)
    if childIndex ~= -1 then
        self:RemoveChildAt(childIndex, dispose)
    end
    return child
end

---Removes a child at a certain index. Children above the child will move down.
---@param index number
---@param dispose boolean @If true, the child will be disposed right away. default: false
---@return FairyGUI.GObject
function GComponent:RemoveChildAt(index, dispose)
    if (index >= 1 and index <= self.numChildren) then
        local child = self._children[index]

        child:InternalSetParent(nil)

        if (child.sortingOrder ~= 0) then
            self._sortingChildCount = self._sortingChildCount - 1
        end

        table.remove(self._children, index)
        child.group = nil
        if (child.inContainer) then
            self.container:RemoveChild(child.displayObject)
            if (self._childrenRenderOrder == ChildrenRenderOrder.Arch) then
                UpdateContext.OnBegin:Remove(self._buildDelegate, self)
                UpdateContext.OnBegin:Add(self._buildDelegate, self)
            end
        end

        if dispose then
            child:Dispose()
        end

        self:SetBoundsChangedFlag()
        return child
    end
    error("Invalid child index: " .. index .. ">" .. self.numChildren)
end

---Removes a range of children from the container (endIndex included).
---@param beginIndex number @Begin index.
---@param endIndex number @End index.(Included). default: -1
---@param dispose boolean @If true, the child will be disposed right away. default: false
function GComponent:RemoveChildren(beginIndex, endIndex, dispose)
    if (endIndex < 1 or endIndex > self.numChildren) then
        endIndex = self.numChildren
    end

    for i = beginIndex, endIndex do
        self:RemoveChildAt(beginIndex, dispose)
    end
end

---Returns a child object at a certain index. If index out of bounds, exception raised.
---@param index number
---@return FairyGUI.GObject
function GComponent:GetChildAt(index)
    if index >= 1 and index <= self.numChildren then
        return self._children[index]
    end
    error("Invalid child index: " .. index .. ">" .. self.numChildren)
end

---Returns a child object with a certain name.
---@param name string
---@return FairyGUI.GObject @A child object. nil if not found.
function GComponent:GetChild(name)
    for i, child in ipairs(self._children) do
        if child.name == name then
            return child
        end
    end
    return nil
end

---Returns a visible child object with a certain name.
---@param name string
---@param FairyGUI.GObject @A child object. Null if not found.
function GComponent:GetVisibleChild(name)
    for i, child in ipairs(self._children) do
        if child.internalVisible and child.internalVisible2 and  child.name == name then
            return child
        end
    end
    return nil
end

---Returns a child object belong to a group with a certain name.
---@param group FairyGUI.GGroup
---@param name string
---@return FairyGUI.GObject @A child object. Null if not found.
function GComponent:GetChildInGroup(group, name)
    for i, child in ipairs(self._children) do
        if child.group == group and child.name == name then
            return child
        end
    end
    return nil
end

---@param id string
---@return FairyGUI.GObject @A child object. Null if not found.
function GComponent:GetChildById(id)
    for i, child in ipairs(self._children) do
        if child.id == id then
            return child
        end
    end
    return nil
end

---@return FairyGUI.GObject[]
function GComponent:GetChildren()
    return self._children
end

---Returns the index of a child within the container, or "-1" if it is not found.
---@param child FairyGUI.GObject
---@return FairyGUI.GObject @Index of the child. -1 If not found.
function GComponent:GetChildIndex(child)
    return self._children:indexOf(child)
end

---Moves a child to a certain index. Children at and after the replaced position move up.
---@param child FairyGUI.GObject
---@param index number
function GComponent:SetChildIndex(child, index)
    local oldIndex = self._children:indexOf(child)
    if (oldIndex == -1) then
        error("Not a child of this container")
    end

    if (child.sortingOrder ~= 0) then --no effect
        return
    end

    local cnt = #self._children
    if (self._sortingChildCount > 0) then
        if (index > (cnt - self._sortingChildCount)) then
            index = cnt - self._sortingChildCount
        end
    end

    self:_SetChildIndex(child, oldIndex, index)
end

---Moves a child to a certain position which is in front of the child previously at
---与SetChildIndex不同的是，如果child原来在index的前面，那么child插入的位置是index-1，即保证排在原来占据index的对象的前面。
---@param child FairyGUI.GObject
---@param index number
---@return number
function GComponent:SetChildIndexBefore(child, index)
    local oldIndex = self._children:indexOf(child)
    if (oldIndex == -1) then
        error("Not a child of this container")
    end

    if (child.sortingOrder ~= 0) then --no effect
        return oldIndex
    end

    local cnt = #self._children
    if (self._sortingChildCount > 0) then
        if (index > (cnt - self._sortingChildCount)) then
            index = cnt - self._sortingChildCount
        end
    end

    if (oldIndex < index) then
        return self:_SetChildIndex(child, oldIndex, index - 1)
    else
        return self:_SetChildIndex(child, oldIndex, index)
    end
end

---@param child FairyGUI.GObject
---@param oldIndex number
---@param index number
---@return number
function GComponent:_SetChildIndex(child, oldIndex, index)
    local cnt = #self._children
    if (index > cnt) then
        index = cnt
    end

    if (oldIndex == index) then
        return oldIndex
    end

    table.remove(self._children, oldIndex)
    if (index >= cnt) then
        table.insert(self._children, child)
    else
        table.insert(self._children, index, child)
    end

    if (child.inContainer) then
        local displayIndex = 1
        if (self._childrenRenderOrder == ChildrenRenderOrder.Ascent) then
            for i = 1, index - 1 do
                local g = self._children[i]
                if (g.inContainer) then
                    displayIndex = displayIndex + 1
                end
            end
            self.container:SetChildIndex(child.displayObject, displayIndex)
        elseif (self._childrenRenderOrder == ChildrenRenderOrder.Descent) then
            for i = cnt, index + 1 do
                local g = self._children[i]
                if (g.inContainer) then
                    displayIndex = displayIndex + 1
                end
            end
            self.container:SetChildIndex(child.displayObject, displayIndex)
        else
            UpdateContext.OnBegin:Remove(self._buildDelegate, self)
            UpdateContext.OnBegin:Add(self._buildDelegate, self)
        end

        self:SetBoundsChangedFlag()
    end

    return index
end

---Swaps the indexes of two children.
---@param child1 FairyGUI.GObject
---@param child2 FairyGUI.GObject
function GComponent:SwapChildren(child1, child2)
    local index1 = self._children:indexOf(child1)
    local index2 = self._children:indexOf(child2)
    if index1 == -1 or index2 == -1 then
        error("Not a child of this container")
    end
    self:SwapChildrenAt(index1, index2)
end

---Swaps the indexes of two children.
---@param index1 number
---@param index2 number
function GComponent:SwapChildrenAt(index1, index2)
    local child1 = self._children[index1]
    local child2 = self._children[index2]

    self:SetChildIndex(child1, index2)
    self:SetChildIndex(child2, index1)
end

---@param obj FairyGUI.GObject
---@return boolean
function GComponent:IsAncestorOf(obj)
    if nil == obj then
        return false
    end

    local p = obj.parent
    while p ~= nil do
        if p == self then
            return true
        end
        p = p.parent
    end
    return false
end

---Adds a controller to the container.
---@param controller FairyGUI.Controller
function GComponent:AddController(controller)
    table.insert(self._controllers, controller)
    controller.parent = self
    self:ApplyController(controller)
end

---Returns a controller object  at a certain index.
---@param index number
---@return FairyGUI.Controller
function GComponent:GetControllerAt(index)
    return self._controllers[index]
end

---Returns a controller object with a certain name.
---@param name string
---@return FairyGUI.Controller @Controller object. nil if not found.
function GComponent:GetController(name)
    for i, controller in ipairs(self._controllers) do
        if controller.name == name then
            return controller
        end
    end
    return nil
end

---Removes a controller from the container.
---@param c FairyGUI.Controller
function GComponent:RemoveController(c)
    local index = self._controllers:indexOf(c)
    if index == -1 then
        error("controller not exists: " .. c.name)
    end

    c.parent = nil
    table.remove(self._controllers, index)

    for i, child in ipairs(self._children) do
        child:HandleControllerChanged(c)
    end
end

---Returns a transition object  at a certain index.
---@param index number
---@return FairyGUI.Transition
function GComponent:GetTransitionAt(index)
    return self._transitions[index]
end

---Returns a transition object  at a certain name.
---@param name string
---@return FairyGUI.Transition
function GComponent:GetTransition(name)
    for i, trans in ipairs(self._transitions) do
        if trans.name == name then
            return trans
        end
    end

    return nil
end

---@param child FairyGUI.GObject
function GComponent:ChildStateChanged(child)
    if (self._buildingDisplayList) then
        return
    end

    local cnt = #self._children

    if child:isa(GGroup) then
        for i, g in ipairs(self._children) do
            if (g.group == child) then
                self:ChildStateChanged(g)
            end
        end
        return
    end

    if (child.displayObject == nil) then
        return
    end

    if (child.internalVisible) then
        if (child.displayObject.parent == nil) then
            if (self._childrenRenderOrder == ChildrenRenderOrder.Ascent) then
                local index = 0
                for i, g in ipairs(self._children) do

                    if (g == child) then
                        break
                    end

                    if (g.displayObject ~= nil and g.displayObject.parent ~= nil) then
                        index = index + 1
                    end
                end
                self.container:AddChildAt(child.displayObject, index)
            elseif (self._childrenRenderOrder == ChildrenRenderOrder.Descent) then
                local index = 0
                for i = cnt, 1, -1 do
                    local g = self._children[i]
                    if (g == child) then
                        break
                    end

                    if (g.displayObject ~= nil and g.displayObject.parent ~= nil) then
                        index = index + 1
                    end
                end
                self.container:AddChildAt(child.displayObject, index)
            else
                self.container:AddChild(child.displayObject)

                UpdateContext.OnBegin:Remove(self._buildDelegate, self)
                UpdateContext.OnBegin:Add(self._buildDelegate, self)
            end
        end
    else
        if (child.displayObject.parent ~= nil) then
            self.container:RemoveChild(child.displayObject)
            if (self._childrenRenderOrder == ChildrenRenderOrder.Arch) then
                UpdateContext.OnBegin:Remove(self._buildDelegate, self)
                UpdateContext.OnBegin:Add(self._buildDelegate, self)
            end
        end
    end
end

function GComponent:BuildNativeDisplayList()
    if (self.displayObject == nil or self.displayObject.isDisposed) then
        return
    end

    local cnt = #self._children
    if (cnt == 0) then
        return
    end

    if self._childrenRenderOrder == ChildrenRenderOrder.Ascent then
        for i, child in ipairs(self._children) do
            if (child.displayObject ~= nil and child.internalVisible) then
                self.container:AddChild(child.displayObject)
            end
        end
    elseif self._childrenRenderOrder == ChildrenRenderOrder.Descent then
        for i = cnt, 1, -1 do
            local child = self._children[i]
            if (child.displayObject ~= nil and child.internalVisible) then
                self.container:AddChild(child.displayObject)
            end
        end
    elseif self._childrenRenderOrder == ChildrenRenderOrder.Arch then
        for i = 1, self._apexIndex - 1 do
            local child = self._children[i]
            if (child.displayObject ~= nil and child.internalVisible) then
                self.container:AddChild(child.displayObject)
            end
        end
        for i = cnt, self._apexIndex, -1 do
            local child = self._children[i]
            if (child.displayObject ~= nil and child.internalVisible) then
                self.container:AddChild(child.displayObject)
            end
        end
    end
end

---@param c FairyGUI.Controller
function GComponent:ApplyController(c)
    self._applyingController = c
    for i, child in ipairs(self._children) do
        child:HandleControllerChanged(c)
    end
    self._applyingController = nil

    c:RunActions()
end

function GComponent:ApplyAllControllers()
    for i, c in ipairs(self._controllers) do
        self:ApplyController(c)
    end
end

---@param obj FairyGUI.GObject
---@param c FairyGUI.Controller
function GComponent:AdjustRadioGroupDepth(obj, c)
    local myIndex, maxIndex = -1, -1
    for i, child in ipairs(self._children) do
        if child == obj then
            myIndex = i
        elseif child:isa(FairyGUI.GButton) and child.relatedController == c then
            if i > maxIndex then
                maxIndex = i
            end
        end
    end
    if myIndex < maxIndex then
        if self._applyingController ~= nil then
            self._children[maxIndex]:HandleControllerChanged(self._applyingController)
        end
        self:SwapChildrenAt(myIndex, maxIndex)
    end
end

---@param child FairyGUI.GObject
---@return boolean
function GComponent:IsChildInView(child)
    if (self.scrollPane ~= nil) then
        return self.scrollPane:IsChildInView(child)
    elseif (self.rootContainer.clipRect ~= nil) then
        return child.x + child.width >= 0 and child.x <= self.width
                and child.y + child.height >= 0 and child.y <= self.height
    end
    return true
end

---@return number
function GComponent:GetFirstChildInView()
    for i, child in ipairs(self._children) do
        if self:IsChildInView(child) then
            return i
        end
    end
    return -1
end

---@param buffer Utils.ByteBuffer
function GComponent:SetupScroll(buffer)
    if self.rootContainer == self.container then
        self.container = Container.new()
        self.rootContainer:AddChild(self.container)
    end

    self.scrollPane = ScrollPane.new(self)
    self.scrollPane:Setup(buffer)
end

---@param overflow FairyGUI.OverflowType
function GComponent:SetupOverflow(overflow)
    if (overflow == OverflowType.Hidden) then
        if (self.rootContainer == self.container) then
            self.container = Container.new()
            self.rootContainer:AddChild(self.container)
        end

        self:UpdateClipRect()
        self.container:SetXY(self._margin.left, self._margin.top)
    elseif (self._margin.left ~= 0 or self._margin.top ~= 0) then
        if (self.rootContainer == self.container) then
            self.container = Container.new()
            self.rootContainer:AddChild(self.container)
        end

        self.container:SetXY(self._margin.left, self._margin.top)
    end
end

function GComponent:UpdateClipRect()
    if self.scrollPane == nil then
        local w = self.width - (self._margin.left + self._margin.right)
        local h = self.height - (self._margin.top + self._margin.bottom)
        self.rootContainer.clipRect = Rect(self._margin.left, self._margin.top, w, h)
    else
        self.rootContainer.clipRect = Rect(0, 0, self.width, self.height)
    end
end

function GComponent:HandleSizeChanged()
    GObject.HandleSizeChanged(self)

    if (self.scrollPane ~= nil) then
        self.scrollPane:OnOwnerSizeChanged()
    end
    if (self.rootContainer.clipRect ~= nil) then
        self:UpdateClipRect()
    end

    if self.rootContainer.hitArea:isa(PixelHitTest) then
        ---@type FairyGUI.PixelHitTest
        local test = self.rootContainer.hitArea
        if (self.sourceWidth ~= 0) then
            test.scaleX = self.width / self.sourceWidth
        end
        if (self.sourceHeight ~= 0) then
            test.scaleY = self.height / self.sourceHeight
        end
    end
end

function GComponent:HandleGrayedChanged()
    local cc = self:GetController('grayed')
    if cc ~= nil then
        cc.selectedIndex = self.grayed and 1 or 0
    else
        GObject:HandleGrayedChanged()
    end
end

---@param c FairyGUI.Controller
function GComponent:HandleControllerChanged(c)
    GObject.HandleControllerChanged(c)

    if self.scrollPane ~= nil then
        self.scrollPane:HandleControllerChanged(c)
    end
end

---Notify the component the bounds should recaculate.
function GComponent:SetBoundsChangedFlag()
    if self.scrollPane == nil and not self._trackBounds then
        return
    end
    self._boundsChanged = true
end

---Make sure the bounds of the component is correct.
---Bounds of the component is not updated on every changed. For example, you add a new child to the list, children in the list will be rearranged in next frame.
---If you want to access the correct child position immediatelly, call this function first.
function GComponent:EnsureBoundsCorrect()
    if self._boundsChanged then
        self:UpdateBounds()
    end
end

function GComponent:UpdateBounds()
    local ax, ay, aw, ah
    if (#self._children > 0) then
        ax = math.maxval
        ay = math.maxval
        local ar, ab = math.minval, math.minval
        local tmp

        for i, child in ipairs(self._children) do
            tmp = child.x
            if (tmp < ax) then
                ax = tmp
            end
            tmp = child.y
            if (tmp < ay) then
                ay = tmp
            end
            tmp = child.x + child.actualWidth
            if (tmp > ar) then
                ar = tmp
            end
            tmp = child.y + child.actualHeight
            if (tmp > ab) then
                ab = tmp
            end
        end
        aw = ar - ax
        ah = ab - ay
    else
        ax, ay, aw, ah = 0, 0, 0, 0
    end

    self:SetBounds(ax, ay, aw, ah)
end

---@param ax number
---@param ay number
---@param aw number
---@param ah number
function GComponent:SetBounds(ax, ay, aw, ah)
    self._boundsChanged = false

    if self.scrollPane ~= nil then
        self.scrollPane:SetContentSize(math.round(ax + aw), math.round(ay + ah))
    end
end

---@param xValue number @ref
---@param yValue number @ref
---@return number, number
function GComponent:GetSnappingPosition(xValue, yValue)
    local cnt = #self._children
    if (cnt == 0) then
        return xValue, yValue
    end

    self:EnsureBoundsCorrect()

    local obj = nil

    local index = 1
    if (yValue ~= 0) then
        for i = 1, cnt do
            index = i
            local obj = self._children[i]
            if (yValue < obj.y) then
                if (i == 1) then
                    yValue = 0
                    break
                end
                local prev = self._children[i - 1]
                if (yValue < prev.y + prev.height / 2) then --top half part
                    yValue = prev.y
                else --bottom half part
                    yValue = obj.y
                end
                break
            end
            index = i + 1
        end

        if (index == cnt + 1) then
            yValue = obj.y
        end
    end

    if (xValue ~= 0) then
        if (index > 0) then
            index = index - 1
        end
        for i = index, cnt do
            obj = self._children[i]
            if (xValue < obj.x) then
                if (i == 1) then
                    xValue = 0
                    break
                end

                local prev = self._children[i - 1]
                if (xValue < prev.x + prev.width / 2) then -- top half part
                    xValue = prev.x
                else --bottom half part
                    xValue = obj.x
                end
                break
            end
            index = i + 1
        end
        if (index == cnt + 1) then
            xValue = obj.x
        end
    end

    return xValue, yValue
end

---@param child FairyGUI.GObject
---@param oldValue number
---@param newValue number
function GComponent:ChildSortingOrderChanged(child, oldValue, newValue)
    if (newValue == 0) then
        self._sortingChildCount = self._sortingChildCount - 1
        self:SetChildIndex(child, #self._children)
    else
        if (oldValue == 0) then
            self._sortingChildCount = self._sortingChildCount + 1
        end

        local oldIndex = self._children:indexOf(child)
        local index = self:GetInsertPosForSortingChild(child)
        if (oldIndex < index) then
            self:_SetChildIndex(child, oldIndex, index - 1)
        else
            self:_SetChildIndex(child, oldIndex, index)
        end
    end
end

---每帧调用的一个回调。如果你要override，请记住以下两点：
---1、记得调用base.onUpdate;
---2、不要在方法里进行任何会更改显示列表的操作，例如AddChild、RemoveChild、visible等。
function GComponent:OnUpdate()
    if self._boundsChanged then
        self:UpdateBounds()
    end
end

---@param objectPool FairyGUI.GObject @default: nil
---@param poolIndex number @default 0
function GComponent:ConstructFromResource(objectPool, poolIndex)
    objectPool = objectPool or nil
    poolIndex = (poolIndex or 1) - 1

    self.gameObjectName = self.packageItem.name

    if (not self.packageItem.translated) then
        self.packageItem.translated = true
        TranslationHelper.TranslateComponent(self.packageItem)
    end

    ---@type Utils.ByteBuffer
    local buffer = self.packageItem.rawData
    buffer:Seek(0, 0)

    self.underConstruct = true

    self.sourceWidth = buffer:ReadInt()
    self.sourceHeight = buffer:ReadInt()
    self.initWidth = self.sourceWidth
    self.initHeight = self.sourceHeight

    self:SetSize(self.sourceWidth, self.sourceHeight)

    if (buffer:ReadBool()) then
        self.minWidth = buffer:ReadInt()
        self.maxWidth = buffer:ReadInt()
        self.minHeight = buffer:ReadInt()
        self.maxHeight = buffer:ReadInt()
    end

    if (buffer:ReadBool()) then
        local f1 = buffer:ReadFloat()
        local f2 = buffer:ReadFloat()
        self:SetPivot(f1, f2, buffer:ReadBool())
    end

    if (buffer:ReadBool()) then
        self._margin.top = buffer:ReadInt()
        self._margin.bottom = buffer:ReadInt()
        self._margin.left = buffer:ReadInt()
        self._margin.right = buffer:ReadInt()
    end

    ---@type FairyGUI.OverflowType
    local overflow = buffer:ReadByte()
    if (overflow == OverflowType.Scroll) then
        local savedPos = buffer.position
        buffer:Seek(0, 7)
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

    self._buildingDisplayList = true

    buffer:Seek(0, 1)

    local controllerCount = buffer:ReadShort()
    for i = 1,  controllerCount do
        local nextPos = buffer:ReadShort()
        nextPos = nextPos + buffer.position

        local controller = Controller.new()
        table.insert(self._controllers, controller)
        controller.parent = self
        controller:Setup(buffer)

        buffer.position = nextPos
    end

    buffer:Seek(0, 2)

    ---@type FairyGUI.GObject
    local child
    local childCount = buffer:ReadShort()
    for i = 1, childCount do
        local dataLen = buffer:ReadShort()
        local curPos = buffer.position

        if (objectPool ~= nil) then
            child = objectPool[poolIndex + i]
        else
            buffer:Seek(curPos, 0)

            ---@type FairyGUI.ObjectType
            local type = buffer:ReadByte()
            local src = buffer:ReadS()
            local pkgId = buffer:ReadS()
            ---@type FairyGUI.PackageItem
            local pi = nil
            if (src ~= nil) then
                ---@type FairyGUI.UIPackage
                local pkg
                if (pkgId ~= nil) then
                    pkg = UIPackage.GetById(pkgId)
                else
                    pkg = self.packageItem.owner
                end

                pi = pkg ~= nil and pkg:GetItem(src) or nil
            end

            if (pi ~= nil) then
                child = UIObjectFactory.NewObject(pi)
                child.packageItem = pi
                child:ConstructFromResource()
            else
                child = UIObjectFactory.NewObject(type)
            end
        end

        child.underConstruct = true
        child:Setup_BeforeAdd(buffer, curPos)
        child:InternalSetParent(self)
        table.insert(self._children, child)

        buffer.position = curPos + dataLen
    end

    buffer:Seek(0, 3)
    self.relations:Setup(buffer, true)

    buffer:Seek(0, 2)
    buffer:Skip(2)

    for i = 1, childCount do
        local nextPos = buffer:ReadShort()
        nextPos = nextPos + buffer.position

        buffer:Seek(buffer.position, 3)
        self._children[i].relations:Setup(buffer, false)

        buffer.position = nextPos
    end

    buffer:Seek(0, 2)
    buffer:Skip(2)

    for i = 1, childCount do
        local nextPos = buffer:ReadShort()
        nextPos = nextPos + buffer.position

        child = self._children[i]
        child:Setup_AfterAdd(buffer, buffer.position)
        child.self.underConstruct = false
        if (child.displayObject ~= nil) then
            ToolSet.SetParent(child.displayObject.cachedTransform, self.displayObject.cachedTransform)
        end

        buffer.position = nextPos
    end

    buffer:Seek(0, 4)

    buffer:Skip(2) --customData
    self.opaque = buffer:ReadBool()
    local maskId = buffer:ReadShort()
    if (maskId ~= -1) then
        self.mask = self:GetChildAt(maskId).displayObject
        if (buffer:ReadBool()) then
            self.reversedMask = true
        end
    end
    local hitTestId = buffer:ReadS()
    if (hitTestId ~= nil) then
        local pi = self.packageItem.owner.GetItem(hitTestId)
        if (pi ~= nil and pi.pixelHitTestData ~= nil) then
            local i1 = buffer:ReadInt()
            local i2 = buffer:ReadInt()
            self.rootContainer.hitArea = PixelHitTest.new(pi.pixelHitTestData, i1, i2)
        end
    end

    buffer:Seek(0, 5)

    local transitionCount = buffer:ReadShort()
    for i = 1, transitionCount do
        local nextPos = buffer:ReadShort()
        nextPos = nextPos + buffer.position

        local trans = Transition.new(self)
        trans:Setup(buffer)
        table.insert(self._transitions, trans)

        buffer.position = nextPos
    end

    if #self._transitions > 0 then
        self.onAddedToStage:Add(self.__addedToStageDelegate)
        self.onRemovedFromStage:Add(self.__removedFromStageDelegate)
    end

    self:ApplyAllControllers()

    self._buildingDisplayList = false
    self.underConstruct = false

    self:BuildNativeDisplayList()
    self:SetBoundsChangedFlag()

    if (self.packageItem.objectType ~= ObjectType.Component) then
        self:ConstructExtension(buffer)
    end

    self:ConstructFromXML(nil)
end

---@param buffer Utils.ByteBuffer
function GComponent:ConstructExtension(buffer) end

---@param xml Utils.XML
function GComponent:ConstructFromXML(xml) end

---@param buffer Utils.ByteBuffer
---@param beginPos number
function GComponent:Setup_AfterAdd(buffer, beginPos)
    GObject.Setup_AfterAdd(self, buffer, beginPos)

    buffer:Seek(beginPos, 4)

    local pageController = buffer:ReadShort()
    if (pageController ~= -1 and self.scrollPane ~= nil and self.scrollPane.pageMode) then
        self.scrollPane.pageController = self.parent:GetControllerAt(pageController)
    end

    local cnt = buffer:ReadShort()
    for i = 1, cnt do
        local cc = self:GetController(buffer:ReadS())
        local pageId = buffer:ReadS()
        if (cc ~= nil) then
            cc.selectedPageId = pageId
        end
    end
end

function GComponent:__addedToStage()
    for i, trans in ipairs(self._transitions) do
        trans:OnOwnerAddedToStage()
    end
end

function GComponent:__removedFromStage()
    for i, trans in ipairs(self._transitions) do
        trans:OnOwnerRemovedFromStage()
    end
end


local __get = Class.init_get(GComponent)
local __set = Class.init_set(GComponent)

---@param self FairyGUI.GComponent
__get.fairyBatching = function(self) return self.rootContainer.fairyBatching end

---@param self FairyGUI.GComponent
---@param val boolean
__set.fairyBatching = function(self, val) self.rootContainer.fairyBatching = val end

---@param self FairyGUI.GComponent
__get.opaque = function(self) return self.rootContainer.opaque  end

---@param self FairyGUI.GComponent
---@param val boolean
__set.opaque = function(self, val)  self.rootContainer.opaque = val  end

---@param self FairyGUI.GComponent
__get.margin = function(self) return self._margin  end

---@param self FairyGUI.GComponent
---@param val boolean
__set.margin = function(self, val)
    self._margin = val
    if (self.rootContainer.clipRect ~= nil and self.scrollPane == nil) then --如果scrollPane不为空，则HandleSizeChanged里面的处理会促使ScrollPane处理
        self.container:SetXY(self._margin.left + self._alignOffset.x, self._margin.top + self._alignOffset.y)
    end
    self:HandleSizeChanged()
end

---@param self FairyGUI.GComponent
__get.childrenRenderOrder = function(self) return self._childrenRenderOrder  end

---@param self FairyGUI.GComponent
---@param val number
__set.childrenRenderOrder = function(self, val)
    if (self._childrenRenderOrder ~= val) then
        self._childrenRenderOrder = val
        self:BuildNativeDisplayList()
    end
end

---@param self FairyGUI.GComponent
__get.apexIndex = function(self) return self._apexIndex  end

---@param self FairyGUI.GComponent
---@param val number
__set.apexIndex = function(self, val)
    if (self._apexIndex ~= val) then
        self._apexIndex = val

        if (self._childrenRenderOrder == ChildrenRenderOrder.Arch) then
            self:BuildNativeDisplayList()
        end
    end
end

---@param self FairyGUI.GComponent
__get.numChildren = function(self) return #self._children end

---@param self FairyGUI.GComponent
__get.Controllers = function(self) return self._controllers end

---@param self FairyGUI.GComponent
__get.clipSoftness = function(self) return self._clipSoftness  end

---@param self FairyGUI.GComponent
---@param val Love2DEngine.Vector2
__set.clipSoftness = function(self, val)
    self._clipSoftness = val
    if self.scrollPane ~= nil then
        self.scrollPane:UpdateClipSoft()
    elseif self._clipSoftness.x > 0 or self._clipSoftness.y > 0 then
        self.rootContainer.clipSoftness = Vector4(val.x, val.y, val.x, val.y)
    else
        self.rootContainer.clipSoftness = nil
    end
end

---@param self FairyGUI.GComponent
__get.mask = function(self) return self.container.mask  end

---@param self FairyGUI.GComponent
---@param val FairyGUI.DisplayObject
__set.mask = function(self, val)
    self.container.mask = val
end

---@param self FairyGUI.GComponent
__get.reversedMask = function(self) return self.container.reverseMask  end

---@param self FairyGUI.GComponent
---@param val boolean
__set.baseUserData = function(self, val)
    self.container.reverseMask = val
end

---@param self FairyGUI.GComponent
__get.baseUserData = function(self)
    local buffer = self.packageItem.rawData
    buffer:Seek(0, 4)
    return buffer:ReadS()
end

---@param self FairyGUI.GComponent
__get.viewWidth = function(self)
    if self.scrollPane ~= nil then
        return self.scrollPane.viewWidth
    end
    return self.width - self._margin.left - self._margin.right
end

---@param self FairyGUI.GComponent
---@param val boolean
__set.viewWidth = function(self, val)
    if self.scrollPane ~= nil then
        self.scrollPane.viewWidth = val
    else
       self.width = val + self._margin.left + self._margin.right
    end
end

---@param self FairyGUI.GComponent
__get.viewHeight = function(self)
    if self.scrollPane ~= nil then
        return self.scrollPane.viewHeight
    end
    return self.height - self._margin.top - self._margin.bottom
end

---@param self FairyGUI.GComponent
---@param val boolean
__set.viewHeight = function(self, val)
    if self.scrollPane ~= nil then
        self.scrollPane.viewHeight = val
    else
        self.height = val + self._margin.top + self._margin.bottom
    end
end

FairyGUI.GComponent = GComponent
return GComponent