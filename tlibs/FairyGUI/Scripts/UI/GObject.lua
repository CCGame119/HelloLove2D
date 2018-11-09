--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 10:13
--
local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2
local Vector3 = Love2DEngine.Vector3
local Rect = Love2DEngine.Rect
local Screen = Love2DEngine.Screen

local EventDispatcher = FairyGUI.EventDispatcher
local EventListener = FairyGUI.EventListener
local GComponent = FairyGUI.GComponent
local GearBase = FairyGUI.GearBase
local Relations = FairyGUI.Relations
local GList = FairyGUI.GList
local GGroup = FairyGUI.GGroup
local GRoot = FairyGUI.GRoot
local RelationType = FairyGUI.RelationType
local EventCallback0 = FairyGUI.EventCallback0
local EventCallback1 = FairyGUI.EventCallback1
local BlendMode = FairyGUI.BlendMode
local UIPackage = FairyGUI.UIPackage
local GearDisplay = FairyGUI.GearDisplay
local GearXY = FairyGUI.GearXY
local GearSize = FairyGUI.GearSize
local GearLook = FairyGUI.GearLook
local GearColor = FairyGUI.GearColor
local GearAnimation = FairyGUI.GearAnimation
local GearText = FairyGUI.GearText
local GearIcon = FairyGUI.GearIcon
local GTween = FairyGUI.GTween
local TweenPropType = FairyGUI.TweenPropType
local HitTestContext = FairyGUI.HitTestContext
local Stage = FairyGUI.Stage
local UIConfig = FairyGUI.UIConfig
local ColorFilter = FairyGUI.ColorFilter


--region FairyGUI.GObject Declaration
---@class FairyGUI.GObject:FairyGUI.EventDispatcher
---@field public id string @GObject的id，仅作为内部使用。与name不同，id值是不会相同的。id is for internal use only.
---@field public name string @Name of the object.
---@field public data any @User defined data.
---@field public sourceWidth number @The source width of the object.
---@field public sourceHeight number @The source height of the object.
---@field public initWidth number @The initial width of the object.
---@field public initHeight number @The initial height of the object.
---@field public minWidth number @
---@field public maxWidth number @
---@field public minHeight number @
---@field public maxHeight number @
---@field public relations FairyGUI.Relations @Relations Object.
---@field public dragBounds Love2DEngine.Rect @Restricted range of dragging.
---@field public parent FairyGUI.GComponent @Parent object.
---@field public displayObject DisplayObject @Lowlevel display object.
---@field public onClick FairyGUI.EventListener @Dispatched when the object or its child was clicked.
---@field public onRightClick FairyGUI.EventListener @Dispatched when the object or its child was clicked by right mouse button. Web only.
---@field public onTouchBegin FairyGUI.EventListener @Dispatched when the finger touched the object or its child just now.
---@field public onTouchMove FairyGUI.EventListener @
---@field public onTouchEnd FairyGUI.EventListener @Dispatched when the finger was lifted from the screen or from the mouse button.
---@field public onRollOver FairyGUI.EventListener @The cursor or finger hovers over an object.
---@field public onRollOut FairyGUI.EventListener @The cursor or finger leave an object.
---@field public onAddedToStage FairyGUI.EventListener @Dispatched when the object was added to the stage.
---@field public onRemovedFromStage FairyGUI.EventListener @Dispatched when the object was removed from the stage.
---@field public onKeyDown FairyGUI.EventListener @Dispatched on key pressed when the object is in focus.
---@field public onClickLink FairyGUI.EventListener @Dispatched when links in the object or its child was clicked.
---@field public onPositionChanged FairyGUI.EventListener @Dispatched when the object was moved.
---@field public onSizeChanged FairyGUI.EventListener @Dispatched when the object was resized.
---@field public onDragStart FairyGUI.EventListener @Dispatched when drag start.
---@field public onDragMove FairyGUI.EventListener @Dispatched when dragging.
---@field public onDragEnd FairyGUI.EventListener @Dispatched when drag end.
---@field public OnGearStop FairyGUI.EventListener @
---@field public packageItem FairyGUI.PackageItem
---@field public x number The x coordinate of the object relative to the local coordinates of the parent.
---@field public y number The y coordinate of the object relative to the local coordinates of the parent.
---@field public z number The z coordinate of the object relative to the local coordinates of the parent.
---@field public xy Love2DEngine.Vector2 The x and y coordinates of the object relative to the local coordinates of the parent.
---@field public position Love2DEngine.Vector3 The x,y,z coordinates of the object relative to the local coordinates of the parent.
---@field public pixelSnapping boolean
---@field public width number The width of the object in pixels.
---@field public height number The height of the object in pixels.
---@field public size Love2DEngine.Vector2 The size of the object in pixels.
---@field public actualWidth number
---@field public actualHeight number
---@field public xMin number
---@field public yMin number
---@field public scaleX number The horizontal scale factor. '1' means no scale, cannt be negative.
---@field public scaleY number The vertical scale factor. '1' means no scale, cannt be negative.
---@field public scale Love2DEngine.Vector2 The scale factor.
---@field public skew Love2DEngine.Vector2
---@field public pivotX number @The x coordinate of the object's origin in its own coordinate space.
---@field public pivotY number @The y coordinate of the object's origin in its own coordinate space.
---@field public pivot Love2DEngine.Vector2 @The x and y coordinates of the object's origin in its own coordinate space.
---@field public pivotAsAnchor boolean
---@field public touchable boolean @If the object can touch or click. GImage/GTextField is not touchable even it is true.
---@field public grayed boolean @If true, apply a grayed effect on this object.
---@field public enabled boolean @Enabled is shortcut for grayed and !touchable combination.
---@field public rotation number @The rotation around the z axis of the object in degrees.
---@field public rotationX number @The rotation around the x axis of the object in degrees.
---@field public rotationY number @The rotation around the y axis of the object in degrees.
---@field public alpha number @The opacity of the object. 0 = transparent, 1 = opaque.
---@field public visible boolean @The visibility of the object. An invisible object will be untouchable.
---@field public internalVisible boolean
---@field public internalVisible2 boolean
---@field public sortingOrder number @By default(when sortingOrder==0), object added to component is arrange by the added roder. The bigger is the sorting order, the object is more in front.
---@field public focusable boolean @If the object can be focused?
---@field public focused boolean @If the object is focused. Focused object can receive key events.
---@field public tooltips string @Tooltips of this object. UIConfig.tooltipsWin must be set first.
---@field public filter FairyGUI.IFilter
---@field public blendMode FairyGUI.BlendMode
---@field public gameObjectName string @设定GameObject的名称
---@field public inContainer boolean @If the object has lowlevel displayobject and the displayobject has a container parent?
---@field public onStage boolean @If the object is on stage.
---@field public resourceURL string @Resource url of this object.
---@field public gearXY FairyGUI.GearXY @Gear to xy controller.
---@field public gearSize FairyGUI.GearSize @Gear to size controller.
---@field public gearLook FairyGUI.GearLook @Gear to look controller.
---@field public group FairyGUI.GGroup @Group belonging to.
---@field public root FairyGUI.GRoot
---@field public text string
---@field public icon string
---@field public draggable boolean
---@field public asImage FairyGUI.GImage
---@field public asCom FairyGUI.GComponent
---@field public asButton FairyGUI.GButton
---@field public asLabel FairyGUI.GLabel
---@field public asProgress FairyGUI.GProgressBar
---@field public asSlider FairyGUI.GSlider
---@field public asComboBox FairyGUI.GComboBox
---@field public asTextField FairyGUI.GTextField
---@field public asRichTextField FairyGUI.GRichTextField
---@field public asTextInput FairyGUI.GTextInput
---@field public asLoader FairyGUI.GLoader
---@field public asList FairyGUI.GList
---@field public asGraph FairyGUI.GGraph
---@field public asGroup FairyGUI.GGroup
---@field public asMovieClip FairyGUI.GMovieClip
---@field private _x number
---@field private _y number
---@field private _z number
---@field private _pivotX number
---@field private _pivotY number
---@field private _pivotAsAnchor boolean
---@field private _alpha number
---@field private _rotation number
---@field private _rotationX number
---@field private _rotationY number
---@field private _visible boolean
---@field private _numberernalVisible boolean
---@field private _handlingController boolean
---@field private _touchable boolean
---@field private _grayed boolean
---@field private _draggable boolean
---@field private _scaleX number
---@field private _scaleY number
---@field private _sortingOrder number
---@field private _focusable boolean
---@field private _tooltips string
---@field private _pixelSnapping boolean
---@field private _group FairyGUI.GGroup
---@field private _gears FairyGUI.GearBase[]
---@field private _dragTouchStartPos Love2DEngine.Vector2
---@field protected _sizeImplType number
---@field protected underConstruct boolean
---@field protected _width number
---@field protected _height number
---@field protected _rawWidth number
---@field protected _rawHeight number
---@field protected _gearLocked boolean
---@field protected _sizePercentInGroup number
---@field protected _disposed boolean
local GObject = Class.inheritsFrom('GObject', nil, EventDispatcher)
GObject._gInstanceCounter = 0
---@type FairyGUI.GObject
---当前全局正在被拖动的对象
GObject.draggingObject = nil

GObject.sGlobalDragStart = Vector2()
GObject.sGlobalRect = Rect()
GObject.sUpdateInDragging = false
--endregion

--region FairyGUI.GObject Definition

function GObject:__ctor()
    self._width = 0
    self._height = 0
    self._alpha = 1
    self._visible = true
    self._touchable = true
    self._scaleX = 1
    self._scaleY = 1
    self._internalVisible = true
    self.id = "self._n" .. self._gInstanceCounter
    self._gInstanceCounter = self._gInstanceCounter + 1
    self.name = ''

    self:CreateDisplayObject()

    self.relations = Relations.new(self)
    self._gears = {}

    self.onClick = EventListener.new(self, "onClick")
    self.onRightClick = EventListener.new(self, "onRightClick")
    self.onTouchBegin = EventListener.new(self, "onTouchBegin")
    self.onTouchMove = EventListener.new(self, "onTouchMove")
    self.onTouchEnd = EventListener.new(self, "onTouchEnd")
    self.onRollOver = EventListener.new(self, "onRollOver")
    self.onRollOut = EventListener.new(self, "onRollOut")
    self.onAddedToStage = EventListener.new(self, "onAddedToStage")
    self.onRemovedFromStage = EventListener.new(self, "onRemovedFromStage")
    self.onKeyDown = EventListener.new(self, "onKeyDown")
    self.onClickLink = EventListener.new(self, "onClickLink")

    self.onPositionChanged = EventListener.new(self, "onPositionChanged")
    self.onSizeChanged = EventListener.new(self, "onSizeChanged")
    self.onDragStart = EventListener.new(self, "onDragStart")
    self.onDragMove = EventListener.new(self, "onDragMove")
    self.onDragEnd = EventListener.new(self, "onDragEnd")

    self.OnGearStop = EventListener.new(self, "OnGearStop")

    self.__rollOverDelegate = EventCallback0.new(self.__rollOver, self)
    self.__rollOutDelegate = EventCallback0.new(self.__rollOut, self)

    self.__touchBeginDelegate = EventCallback1.new(self.__touchBegin, self)
    self.__touchMoveDelegate = EventCallback1.new(self.__touchMove, self)
    self.__touchEndDelegate = EventCallback1.new(self.__touchEnd, self)
end

---change the x and y coordinates of the object relative to the local coordinates of the parent.
---@param xv number
---@param yv number
---@param topLeftValue @default nil
function GObject:SetXY(xv, yv, topLeftValue)
    if nil == topLeftValue or not self._pivotAsAnchor then
        self:SetPosition(xv, yv, self._z)
    end

    self:SetPosition(xv + self._pivotX * self._width, yv + self._pivotY * self._height, self._z)
end

---change the x,y,z coordinates of the object relative to the local coordinates of the parent.
---@param xv number
---@param yv number
---@param zv number
function GObject:SetPosition(xv, yv, zv)
    if (self._x ~= xv or self._y ~= yv or self._z ~= zv) then
        local dx = xv - self._x
        local dy = yv - self._y
        self._x = xv
        self._y = yv
        self._z = zv

        self:HandlePositionChanged()

        if self:isa(GGroup) then
            self:MoveChildren(dx, dy)
        end

        self:UpdateGear(1)

        if self.parent ~= nil and not self.parent:isa(GList) then
            self.parent:SetBoundsChangedFlag()
            if (self._group ~= nil) then
                self._group:SetBoundsChangedFlag()
            end
            self.onPositionChanged:Call()
        end

        if (self.draggingObject == self and not GObject.sUpdateInDragging) then
            GObject.sGlobalRect = self:LocalToGlobal(Rect(0, 0, self.width, self.height))
        end
    end
end

---Set the object in middle of the parent or GRoot if the parent is not set.
---@param restraint boolean @default false
function GObject:Center(restraint)
    ---@type GComponent
    local r
    if (self.parent ~= nil) then
        r = self.parent
    else
        r = self.root
    end

    self:SetXY((r.width - self.width) / 2, (r.height - self.height) / 2, true)
    if restraint then
        self:AddRelation(r, RelationType.Center_Center)
        self:AddRelation(r, RelationType.Middle_Middle)
    end
end

---设置对象为全屏大小（逻辑屏幕）。
function GObject:MakeFullScreen()
    self:SetSize(GRoot.inst.width, GRoot.inst.height)
end

---Change size.
---@param wv number
---@param hv number
---@param ignorePivot boolean @default false
function GObject:SetSize(wv, hv, ignorePivot)
    ignorePivot = ignorePivot or false

    if (self._rawWidth ~= wv or self._rawHeight ~= hv) then
        self._rawWidth = wv
        self._rawHeight = hv
        if (wv < self.minWidth) then
            wv = self.minWidth
        elseif (self.maxWidth > 0 and wv > self.maxWidth) then
            wv = self.maxWidth
        end
        if (hv < self.minHeight) then
            hv = self.minHeight
        elseif (self.maxHeight > 0 and hv > self.maxHeight) then
            hv = self.maxHeight
        end
        local dWidth = wv - self._width
        local dHeight = hv - self._height
        self._width = wv
        self._height = hv

        self:HandleSizeChanged()

        if (self._pivotX ~= 0 or self._pivotY ~= 0) then
            if (not self._pivotAsAnchor) then
                if (not ignorePivot) then
                    self:SetXY(self._x - self._pivotX * dWidth, self._y - self._pivotY * dHeight)
                else
                    self:HandlePositionChanged()
                end
            else
                self:HandlePositionChanged()
            end
        end

        if self:isa(GGroup) then
            self:ResizeChildren(dWidth, dHeight)
        end

        self:UpdateGear(2)

        if self.parent ~= nil then
            self.relations:OnOwnerSizeChanged(dWidth, dHeight, self._pivotAsAnchor or not ignorePivot)
            self.parent:SetBoundsChangedFlag()
            if (self._group ~= nil) then
                self._group:SetBoundsChangedFlag(true)
            end
        end

        self.onSizeChanged:Call()
    end
end

---@param wv number
---@param hv number
function GObject:SetSizeDirectly(wv, hv)
    self._rawWidth = wv
    self._rawHeight = hv
    if (wv < 0) then
        wv = 0
    end
    if (hv < 0) then
        hv = 0
    end
    self._width = wv
    self._height = hv
end

---Change the scale factor.
---@param wv number
---@param hv number
function GObject:SetScale(wv, hv)
    if (self._scaleX ~= wv or self._scaleY ~= hv) then
        self._scaleX = wv
        self._scaleY = hv
        self:HandleScaleChanged()

        self:UpdateGear(2)
    end
end

---Change the x and y coordinates of the object's origin in its own coordinate space.
---@param xv number
---@param yv number
---@param asAnchor boolean @default: false
function GObject:SetPivot(xv, yv, asAnchor)
    asAnchor = asAnchor or false
    if (self._pivotX ~= xv or self._pivotY ~= yv or self._pivotAsAnchor ~= asAnchor) then
        self._pivotX = xv
        self._pivotY = yv
        self._pivotAsAnchor = asAnchor
        if (self.displayObject ~= nil) then
            self.displayObject.pivot = Vector2(self._pivotX, self._pivotY)
        end
        if (self._sizeImplType == 1 or self._pivotAsAnchor) then --self.displayObject的轴心参考宽高与GObject的参看宽高不一样的情况下，需要调整self.displayObject的位置
            self:HandlePositionChanged()
        end
    end
end

---Request focus on this object.
function GObject:RequestFocus()
    local p = self
    while p ~= nil and not p._focusable do
        p = p.parent
    end

    if p ~= nil then
        self.root.focus = p
    end
end

function GObject:__rollOver()
    self.root:ShowTooltips(self._tooltips)
end

function GObject:__rollOut()
    self.root:HideTooltips()
end

---@param obj FairyGUI.GObject
function GObject:SetHome(obj)
    if self.displayObject ~= nil and obj.displayObject ~= nil then
        self.displayObject.home = obj.displayObject.cachedTransform
    end
end

---@param index number
---@return FairyGUI.GearBase
function GObject:GetGear(index)
    local gear = self._gears[index]
    if (gear == nil) then
        if 0 == index then
            gear = GearDisplay.new(self)
        elseif 1 == index then
            gear = GearXY.new(self)
        elseif 2 == index then
            gear = GearSize.new(self)
        elseif 3 == index then
            gear = GearLook.new(self)
        elseif 4 == index then
            gear = GearColor.new(self)
        elseif 5 == index then
            gear = GearAnimation.new(self)
        elseif 6 == index then
            gear = GearText.new(self)
        elseif 7 == index then
            gear = GearIcon.new(self)
        else
            error("FairyGUI: invalid gear index!")
        end
        self._gears[index] = gear
    end
    return gear
end

---@param index number
function GObject:UpdateGear(index)
    if (self.underConstruct or self._gearLocked) then
        return
    end
    local gear = self._gears[index]
    if (gear ~= nil and gear.controller ~= nil) then
        gear:UpdateState()
    end
end

---@param index number
---@param c FairyGUI.Controller
---@return boolean
function GObject:CheckGearController(index, c)
    return self._gears[index] ~= nil and self._gears[index].controller == c
end

---@param index number
---@param dx number
---@param dy number
function GObject:UpdateGearFromRelations(index, dx, dy)
    if self._gears[index] ~= nil then
        self._gears[index]:UpdateFromRelations(dx, dy)
    end
end

---@return number
function GObject:AddDisplayLock()
    ---@type FairyGUI.GearDisplay
    local gearDisplay = self._gears[0]
    if (gearDisplay ~= nil and gearDisplay.controller ~= nil) then
        local ret = gearDisplay:AddLock()
        self:CheckGearDisplay()

        return ret
    else
        return 0
    end
end

---@param token number
function GObject:ReleaseDisplayLock(token)
    ---@type FairyGUI.GearDisplay
    local gearDisplay = self._gears[0]
    if (gearDisplay ~= nil and gearDisplay.controller ~= nil) then
        gearDisplay:ReleaseLock(token)
        self:CheckGearDisplay()
    end
end

function GObject:CheckGearDisplay()
    if self._handlingController then
        return
    end
    local connected = self._gears[0] == nil or self._gears[0].connected
    if connected ~= self._internalVisible then
        self._internalVisible = connected
        if (self.parent ~= nil) then
            self.parent:ChildStateChanged(self)
        end
    end
end


function GObject:InvalidateBatchingState(index)
    if (self.displayObject ~= nil) then
        self.displayObject:InvalidateBatchingState()
    elseif self:isa(GGroup) and self.parent ~= nil then
        self.parent.container:InvalidateBatchingState(true)
    end
end

---@param c FairyGUI.Controller
function GObject:HandleControllerChanged(c)
    self._handlingController = true
    for i, gear in pairs(self._gears) do
        if (gear ~= nil and gear.controller == c) then
            gear.Apply()
        end
    end
    self._handlingController = false

    self:CheckGearDisplay()
end

---@param target number
---@param relationType FairyGUI.RelationType
---@param usePercent boolean
function GObject:AddRelation(target, relationType, usePercent)
    usePercent = usePercent or false
    self.relations:Add(target, relationType, usePercent)
end

---@param target number
---@param relationType FairyGUI.RelationType
function GObject:RemoveRelation(target, relationType)
    self.relations:Remove(target, relationType)
end

function GObject:RemoveFromParent()
    if self.parent ~= nil then
        self.parent:RemoveChild(self)
    end
end

---@param touchId number @default: -1
function GObject:StartDrag(touchId)
    if self.displayObject.stage == nil then
        return
    end
    self:DragBegin(touchId)
end

function GObject:StopDrag()
    self:DragEnd()
end

---@param pt_or_rect Love2DEngine.Vector2|Love2DEngine.Rect
---@return Love2DEngine.Vector2|Love2DEngine.Rect
function GObject:LocalToGlobal(pt_or_rect)
    if pt_or_rect:isa(Vector2) then
        local pt = pt_or_rect
        if self._pivotAsAnchor then
            pt.x = pt.x + self._width * self._pivotX
            pt.y = pt.y + self._height * self._pivotY
        end
        return self.displayObject:LocalToGlobal(pt)
    end
    local rect = pt_or_rect
    local ret = Rect()
    local v = self:LocalToGlobal(Vector2(rect.xMin, rect.yMin))
    ret.xMin = v.x
    ret.yMin = v.y
    v = self:LocalToGlobal(Vector2(rect.xMax, rect.yMax))
    ret.xMax = v.x
    ret.yMax = v.y
    return ret
end

---@param pt_or_rect Love2DEngine.Vector2|Love2DEngine.Rect
---@return Love2DEngine.Vector2|Love2DEngine.Rect
function GObject:GlobalToLocal(pt_or_rect)
    if pt_or_rect:isa(Vector2) then
        local pt = pt_or_rect
        pt = self.displayObject:GlobalToLocal(pt)
        if self._pivotAsAnchor then
            pt.x = pt.x - self._width * self._pivotX
            pt.y = pt.y - self._height * self._pivotY
        end
        return pt
    end

    local rect = pt_or_rect
    local ret = Rect()
    local v = self:LocalToGlobal(Vector2(rect.xMin, rect.yMin))
    ret.xMin = v.x
    ret.yMin = v.y
    v = self:LocalToGlobal(Vector2(rect.xMax, rect.yMax))
    ret.xMax = v.x
    ret.yMax = v.y
    return ret
end

---@param pt Love2DEngine.Vector2
---@param r FairyGUI.GRoot
---@return Love2DEngine.Vector2
function GObject:LocalToRoot(pt, r)
    pt = self:LocalToGlobal(pt)
    if (r == nil or r == GRoot.inst) then
        --fast
        pt.x = pt.x / GRoot.contentScaleFactor
        pt.y = pt.y / GRoot.contentScaleFactor
        return pt
    end
    return r:GlobalToLocal(pt)
end

---@param pt Love2DEngine.Vector2
---@param r FairyGUI.GRoot
---@return Love2DEngine.Vector2
function GObject:RootToLocal(pt, r)
    if (r == nil or r == GRoot.inst) then
        --fast
        pt.x = pt.x * GRoot.contentScaleFactor
        pt.y = pt.y * GRoot.contentScaleFactor
    else
        pt = r:LocalToGlobal(pt)
    end
    return self:GlobalToLocal(pt)
end

---@param pt Love2DEngine.Vector2
---@param camera Love2DEngine.Camera @default: HitTestContext.cachedMainCamera
---@return Love2DEngine.Vector2
function GObject:WorldToLocal(pt, camera)
    camera = camera or HitTestContext.cachedMainCamera
    local v = camera:WorldToScreenPoint(pt)
    v.y = Screen.height - v.y
    v.z = 0
    return self:GlobalToLocal(v)
end

---@param pt Love2DEngine.Vector2
---@param targetSpace FairyGUI.GObject
---@return Love2DEngine.Vector2
function GObject:TransformPoint(pt, targetSpace)
    if self._pivotAsAnchor then
        pt.x = pt.x + self._width * self._pivotX
        pt.y = pt.y + self._height * self._pivotY
    end
    return self.displayObject:TransformPoint(pt, targetSpace.displayObject)
end

---@param rect Love2DEngine.Rect
---@param targetSpace FairyGUI.GObject
---@return Love2DEngine.Rect
function GObject:TransformRect(rect, targetSpace)
    if self._pivotAsAnchor then
        rect.x = rect.x + self._width * self._pivotX
        rect.y = rect.y + self._height * self._pivotY
    end
    return self.displayObject:TransformRect(rect, targetSpace.displayObject)
end

function GObject:Dispose()
    self._disposed = true

    self:RemoveFromParent()
    self:RemoveEventListeners()
    self.relations:Dispose()
    if (self.displayObject ~= nil) then
        self.displayObject.gOwner = nil
        self.displayObject:Dispose()
    end
    self.data = nil
end

function GObject:CreateDisplayObject() end

---@param value FairyGUI.GComponent
function GObject:InternalSetParent(value)
    self.parent = value
end

function GObject:HandlePositionChanged()
    if (self.displayObject ~= nil) then
        local xv = self._x
        local yv = self._y
        if not self._pivotAsAnchor then
            xv = xv + self._width * self._pivotX
            yv = yv + self._height * self._pivotY
        end
        if self._pixelSnapping then
            xv = math.floor(xv)
            yv = math.floor(yv)
        end
        self.displayObject.location = Vector3(xv, yv, self._z)
    end
end

function GObject:HandleSizeChanged()
    if (self.displayObject ~= nil) then
        if (self._sizeImplType == 0 or self.sourceWidth == 0 or self.sourceHeight == 0) then
            self.displayObject:SetSize(self._width, self._height)
        else
            self.displayObject:SetScale(self._scaleX * self._width / self.sourceWidth, self._scaleY * self._height / self.sourceHeight)
        end
    end
end

function GObject:HandleScaleChanged()
    if (self.displayObject ~= nil) then
        if (self.self._sizeImplType == 0 or self.sourceWidth == 0 or self.sourceHeight == 0) then
            self.displayObject:SetScale(self._scaleX, self._scaleY)
        else
            self.displayObject:SetScale(self._scaleX * self._width / self.sourceWidth, self._scaleY * self._height / self.sourceHeight)
        end
    end
end

function GObject:HandleGrayedChanged()
    if (self.displayObject ~= nil) then
        self.displayObject.grayed = self._grayed
    end
end

function GObject:HandleAlphaChanged()
    if (self.displayObject ~= nil) then
        self.displayObject.alpha = self._alpha
    end
end

function GObject:HandleVisibleChanged()
    if (self.displayObject ~= nil) then
        self.displayObject.visible = self.internalVisible2
    end
end

function GObject:ConstructFromResource()

end

---@param buffer Utils.ByteBuffer
---@param beginPos number
function GObject:Setup_BeforeAdd(buffer, beginPos)
    buffer:Seek(beginPos, 0)
    buffer:Skip(5)

    self.id = buffer:ReadS()
    self.name = buffer:ReadS()
    local f1 = buffer:ReadInt()
    local f2 = buffer:ReadInt()
    self:SetXY(f1, f2)

    if (buffer:ReadBool()) then
        self.initWidth = buffer:ReadInt()
        self.initHeight = buffer:ReadInt()
        self:SetSize(self.initWidth, self.initHeight, true)
    end

    if (buffer:ReadBool()) then
        self.minWidth = buffer:ReadInt()
        self.maxWidth = buffer:ReadInt()
        self.minHeight = buffer:ReadInt()
        self.maxHeight = buffer:ReadInt()
    end

    if (buffer:ReadBool()) then
        f1 = buffer:ReadFloat()
        f2 = buffer:ReadFloat()
        self:SetScale(f1, f2)
    end

    if (buffer:ReadBool()) then
        f1 = buffer:ReadFloat()
        f2 = buffer:ReadFloat()
        self.skew = Vector2(f1, f2)
    end

    if (buffer:ReadBool()) then
        f1 = buffer:ReadFloat()
        f2 = buffer:ReadFloat()
        self:SetPivot(f1, f2, buffer:ReadBool())
    end

    f1 = buffer:ReadFloat()
    if (f1 ~= 1) then
        self.alpha = f1
    end

    f1 = buffer:ReadFloat()
    if (f1 ~= 0) then
        self.rotation = f1
    end
    if (not buffer:ReadBool()) then
        self.visible = false
    end
    if (not buffer:ReadBool()) then
        self.touchable = false
    end
    if (buffer:ReadBool()) then
        self.grayed = true
    end
    self.blendMode = buffer:ReadByte()

    local filter = buffer:ReadByte()
    if (filter == 1) then
        local cf = ColorFilter.new()
        self.filter = cf

        cf:AdjustBrightness(buffer:ReadFloat())
        cf:AdjustContrast(buffer:ReadFloat())
        cf:AdjustSaturation(buffer:ReadFloat())
        cf:AdjustHue(buffer:ReadFloat())
    end

    local str = buffer:ReadS()
    if (str ~= nil) then
        self.data = str
    end
end

---@param buffer Utils.ByteBuffer
---@param beginPos number
function GObject:Setup_AfterAdd(buffer, beginPos)
    buffer:Seek(beginPos, 1)

    local str = buffer:ReadS()
    if (str ~= nil) then
        self.tooltips = str
    end

    local groupId = buffer:ReadShort()
    if (groupId >= 0) then
        self.group = self.parent:GetChildAt(groupId)
    end

    buffer:Seek(beginPos, 2)

    local cnt = buffer:ReadShort()
    for i = 0, cnt - 1 do
        local nextPos = buffer:ReadShort()
        nextPos = nextPos + buffer.position

        local gear = self:GetGear(buffer:ReadByte())
        gear:Setup(buffer)

        buffer.position = nextPos
    end
end

--region Drag support

---@param touchId number
function GObject:InitDrag(touchId)
    if self._draggable then
        self.onTouchBegin:Add(self.__touchBeginDelegate)
        self.onTouchMove:Add(self.__touchMoveDelegate)
        self.onTouchEnd:Add(self.__touchEndDelegate)
    else
        self.onTouchBegin:Remove(self.__touchBeginDelegate)
        self.onTouchMove:Remove(self.__touchMoveDelegate)
        self.onTouchEnd:Remove(self.__touchEndDelegate)
    end
end

---@param touchId number
function GObject:DragBegin(touchId)
    if (self.draggingObject ~= nil) then
        local tmp = self.draggingObject
        self.draggingObject:StopDrag()
        self.draggingObject = nil
        tmp.onDragEnd:Call()
    end

    self.onTouchMove.Add(self.__touchMoveDelegate)
    self.onTouchEnd.Add(self.__touchEndDelegate)

    GObject.sGlobalDragStart = Stage.inst:GetTouchPosition(touchId)
    GObject.sGlobalRect = self:LocalToGlobal(Rect(0, 0, self.width, self.height))
    self._dragTesting = false

    self.draggingObject = self
    Stage.inst:AddTouchMonitor(touchId, self)
end

function GObject:DragEnd()
    if (self.draggingObject == self) then
        self._dragTesting = false
        self.draggingObject = nil
    end
end

---@param context FairyGUI.EventContext
function GObject:__touchBegin(context)
    local evt = context.inputEvent
    self._dragTouchStartPos = evt.position
    self._dragTesting = true
    context:CaptureTouch()
end

---@param context FairyGUI.EventContext
function GObject:__touchMove(context)
    local evt = context.inputEvent

    if (self._dragTesting and self.draggingObject ~= self) then
        local sensitivity
        if Stage.touchScreen then
            sensitivity = UIConfig.touchDragSensitivity
        else
            sensitivity = UIConfig.clickDragSensitivity
        end
        if (math.abs(self._dragTouchStartPos.x - evt.x) < sensitivity
                and math.abs(self._dragTouchStartPos.y - evt.y) < sensitivity) then
            return
        end

        self._dragTesting = false
        if not self.onDragStart:Call(evt.touchId) then
            self:DragBegin(evt.touchId)
        end
    end

    if self.draggingObject == self then
        local xx = evt.x - GObject.sGlobalDragStart.x + GObject.sGlobalRect.x
        local yy = evt.y - GObject.sGlobalDragStart.y + GObject.sGlobalRect.y

        if self.dragBounds ~= nil then
            local rect = GRoot.inst:LocalToGlobal(self.dragBounds)
            if (xx < rect.x) then
                xx = rect.x
            elseif (xx + GObject.sGlobalRect.width > rect.xMax) then
                xx = rect.xMax - GObject.sGlobalRect.width
                if (xx < rect.x) then
                    xx = rect.x
                end
            end

            if (yy < rect.y) then
                yy = rect.y
            elseif (yy + GObject.sGlobalRect.height > rect.yMax) then
                yy = rect.yMax - GObject.sGlobalRect.height
                if (yy < rect.y) then
                    yy = rect.y
                end
            end
        end

        local pt = self.parent:GlobalToLocal(Vector2(xx, yy))
        if math.nan(pt.x) then
            return
        end

        GObject.sUpdateInDragging = true
        self:SetXY(math.round(pt.x), math.round(pt.y))
        GObject.sUpdateInDragging = false

        self.onDragMove:Call()
    end
end

---@param context FairyGUI.EventContext
function GObject:__touchEnd(context)
    if (self.draggingObject == self) then
        self.draggingObject = nil
        self.onDragEnd:Call()
    end
end
--endregion

--region Tween Helpers
---@param endValue Vector2
---@param duration number
---@return GTweener
function GObject:TweenMove(endValue, duration)
    return GTween.To(self.xy, endValue, duration):SetTarget(self, TweenPropType.XY)
end

---@param endValue number
---@param duration number
---@return GTweener
function GObject:TweenMoveX(endValue, duration)
    return GTween.To(self._x, endValue, duration):SetTarget(self, TweenPropType.X)
end

---@param endValue number
---@param duration number
---@return GTweener
function GObject:TweenMoveY(endValue, duration)
    return GTween.To(self._y, endValue, duration):SetTarget(self, TweenPropType.Y)
end

---@param endValue Vector2
---@param duration number
---@return GTweener
function GObject:TweenScale(endValue, duration)
    return GTween.To(self.scale, endValue, duration):SetTarget(self, TweenPropType.Scale)
end

---@param endValue number
---@param duration number
---@return GTweener
function GObject:TweenScaleX(endValue, duration)
    return GTween.To(self._scaleX, endValue, duration):SetTarget(self, TweenPropType.ScaleX)
end

---@param endValue number
---@param duration number
---@return GTweener
function GObject:TweenScaleY(endValue, duration)
    return GTween.To(self._scaleY, endValue, duration):SetTarget(self, TweenPropType.ScaleY)
end

---@param endValue Vector2
---@param duration number
---@return GTweener
function GObject:TweenResize(endValue, duration)
    return GTween.To(self.size, endValue, duration):SetTarget(self, TweenPropType.Size)
end

---@param endValue number
---@param duration number
---@return GTweener
function GObject:TweenFade(endValue, duration)
    return GTween.To(self._alpha, endValue, duration):SetTarget(self, TweenPropType.Alpha)
end

---@param endValue number
---@param duration number
---@return GTweener
function GObject:TweenRotate(endValue, duration)
    return GTween.To(self._rotation, endValue, duration):SetTarget(self, TweenPropType.Rotation)
end
--endregion

--endregion

--region FairyGUI.GObject properties
local __get = Class.init_get(GObject)
local __set = Class.init_set(GObject)

---@param self FairyGUI.GObject
__get.x = function(self) return self._x end

---@param self FairyGUI.GObject
---@param val number
__set.x = function(self, val) self:SetPosition(val, self._y, self._z) end

---@param self FairyGUI.GObject
__get.y = function(self) return self._y end

---@param self FairyGUI.GObject
---@param val number
__set.y = function(self, val) self:SetPosition(self._x, val, self._z) end

---@param self FairyGUI.GObject
__get.z = function(self) return self._z end

---@param self FairyGUI.GObject
---@param val number
__set.z = function(self, val) self:SetPosition(self._x, self._y, val) end

---@param self FairyGUI.GObject
__get.xy = function(self) return Vector2(self._x, self._y) end

---@param self FairyGUI.GObject
---@param val Love2DEngine.Vector2
__set.xy = function(self, val) self:SetPosition(val.x, val.y, self._z) end

---@param self FairyGUI.GObject
__get.position = function(self) return Vector3(self._x, self._y, self._z) end

---@param self FairyGUI.GObject
---@param val Love2DEngine.Vector3
__set.position = function(self, val) self:SetPosition(val.x, val.y, val.z) end

---@param self FairyGUI.GObject
__get.pixelSnapping = function(self) return self._pixelSnapping end

---@param self FairyGUI.GObject
---@param val boolean
__set.pixelSnapping = function(self, val)
    self._pixelSnapping = val
    self:HandlePositionChanged()
end

---@param self FairyGUI.GObject
__get.width = function(self) return self._width end

---@param self FairyGUI.GObject
---@param val number
__set.width = function(self, val)
    self:SetSize(val, self._rawHeight)
end

---@param self FairyGUI.GObject
__get.height = function(self) return self._height end

---@param self FairyGUI.GObject
---@param val number
__set.height = function(self, val)
    self:SetSize(self._rawWidth, val)
end

---@param self FairyGUI.GObject
__get.size = function(self) return Vector2(self.width, self.height) end

---@param self FairyGUI.GObject
---@param val Love2DEngine.Vector2
__set.size = function(self, val)
    self:SetSize(val.x, val.y)
end

---@param self FairyGUI.GObject
__get.actualWidth = function(self) return self.width * self._scaleX end

---@param self FairyGUI.GObject
__get.actualHeight = function(self) return self.height * self._scaleY end

---@param self FairyGUI.GObject
__get.xMin = function(self) return self._pivotAsAnchor and (self._x - self._width * self._pivotX) or self._x end

---@param self FairyGUI.GObject
---@param val number
__set.xMin = function(self, val)
    if self._pivotAsAnchor then
        self:SetPosition(val + self._width * self._pivotX, self._y, self._z)
    else
        self:SetPosition(val, self._y, self._z)
    end
end

---@param self FairyGUI.GObject
__get.yMin = function(self) return self._pivotAsAnchor and (self._y - self._height * self._pivotY) or self._y end

---@param self FairyGUI.GObject
---@param val number
__set.yMin = function(self, val)
    if self._pivotAsAnchor then
        self:SetPosition(self._x,val + self._height * self._pivotY, self._z)
    else
        self:SetPosition(self._x, val, self._z)
    end
end

---@param self FairyGUI.GObject
__get.scaleX = function(self) return self._scaleX end

---@param self FairyGUI.GObject
---@param val number
__set.scaleX = function(self, val)
    self:SetScale(val, self._scaleY)
end

---@param self FairyGUI.GObject
__get.scaleY = function(self) return self._scaleY end

---@param self FairyGUI.GObject
---@param val number
__set.scaleY = function(self, val)
    self:SetScale(self._scaleX, val)
end

---@param self FairyGUI.GObject
__get.scale = function(self) return Vector2(self._scaleX, self._scaleY) end

---@param self FairyGUI.GObject
---@param val Love2DEngine.Vector2
__set.scale = function(self, val)
    self:SetScale(val.x, val.y)
end

---@param self FairyGUI.GObject
__get.skew = function(self)
    if self.displayObject ~= nil then
        return self.displayObject.skew
    end
    return Vector2.zero
end

---@param self FairyGUI.GObject
---@param val Love2DEngine.Vector2
__set.skew = function(self, val)
    if self.displayObject ~= nil then
        self.displayObject.skew = val
    end
end

---@param self FairyGUI.GObject
__get.pivotX = function(self) return self._pivotX end

---@param self FairyGUI.GObject
---@param val number
__set.pivotX = function(self, val)
    self:SetPivot(val, self._pivotY)
end

---@param self FairyGUI.GObject
__get.pivotY = function(self) return self._pivotY end

---@param self FairyGUI.GObject
---@param val number
__set.pivotY = function(self, val)
    self:SetPivot(self._pivotX, val)
end

---@param self FairyGUI.GObject
__get.pivot = function(self) return Vector2(self._pivotX, self._pivotY) end

---@param self FairyGUI.GObject
---@param val Love2DEngine.Vector2
__set.pivot = function(self, val)
    self:SetPivot(val.x, val.y)
end

---@param self FairyGUI.GObject
__get.pivotAsAnchor = function(self) return self._pivotAsAnchor end

---@param self FairyGUI.GObject
---@param val boolean
__set.pivotAsAnchor = function(self, val)
    self:SetPivot(self._pivotX, self._pivotY, val)
end

---@param self FairyGUI.GObject
__get.touchable = function(self) return self._touchable end

---@param self FairyGUI.GObject
---@param val boolean
__set.touchable = function(self, val)
    if self._touchable ~= val then
        self._touchable = val
        self:UpdateGear(3)

        if self.displayObject ~= nil then
            self.touchable = self._touchable
        end
    end
end

---@param self FairyGUI.GObject
__get.grayed = function(self) return self._grayed end

---@param self FairyGUI.GObject
---@param val boolean
__set.grayed = function(self, val)
    if self._grayed ~= val then
        self._grayed = val
        self:HandleGrayedChanged()
        self:UpdateGear(3)
    end
end

---@param self FairyGUI.GObject
__get.enabled = function(self) return not self._grayed and self._touchable end

---@param self FairyGUI.GObject
---@param val boolean
__set.enabled = function(self, val)
    self.grayed = not val
    self.touchable = val
end

---@param self FairyGUI.GObject
__get.rotation = function(self) return self._rotation end

---@param self FairyGUI.GObject
---@param val number
__set.rotation = function(self, val)
    self._rotation = val
    if self.displayObject ~= nil then
        self.displayObject.rotation = self._rotation
    end
    self:UpdateGear(3)
end

---@param self FairyGUI.GObject
__get.rotationX = function(self) return self._rotationX end

---@param self FairyGUI.GObject
---@param val number
__set.rotationX = function(self, val)
    self._rotationX = val
    if self.displayObject ~= nil then
        self.displayObject.rotationX = self._rotationX
    end
end

---@param self FairyGUI.GObject
__get.rotationY = function(self) return self._rotationY end

---@param self FairyGUI.GObject
---@param val boolean
__set.rotationY = function(self, val)
    self._rotationY = val
    if self.displayObject ~= nil then
        self.displayObject.rotationY = self._rotationY
    end
end

---@param self FairyGUI.GObject
__get.alpha = function(self) return self._alpha end

---@param self FairyGUI.GObject
---@param val number
__set.alpha = function(self, val)
    self._alpha = val
    self:HandleAlphaChanged()
    self:UpdateGear(3)
end

---@param self FairyGUI.GObject
__get.visible = function(self) return self._visible end

---@param self FairyGUI.GObject
---@param val boolean
__set.visible = function(self, val)
    if self._visible ~= val then
        self:HandleVisibleChanged()
        if self.parent ~= nil then
            self.parent:SetBoundsChangedFlag()
        end
    end
end

---@param self FairyGUI.GObject
__get.internalVisible = function(self) return self._internalVisible and (self.group == nil or self.group.internalVisible) end

---@param self FairyGUI.GObject
__get.internalVisible2 = function(self) return self._visible and (self.group == nil or self.group.internalVisible2) end

---@param self FairyGUI.GObject
__get.sortingOrder = function(self) return self._sortingOrder end

---@param self FairyGUI.GObject
---@param val number
__set.sortingOrder = function(self, val)
    if val < 1 then
        val = 1
    end
    if self._sortingOrder ~= val then
        local old = self._sortingOrder
        self._sortingOrder = val
        if self.parent ~= nil then
            self.parent:ChildSortingOrderChanged(self, old, self._sortingOrder)
        end
    end
end

---@param self FairyGUI.GObject
__get.focusable = function(self) return self._focusable end

---@param self FairyGUI.GObject
---@param val boolean
__set.focusable = function(self, val)
    self._focusable = val
end

---@param self FairyGUI.GObject
__get.focused = function(self) return self.root.focus == self end

---@param self FairyGUI.GObject
__get.tooltips = function(self) return self._tooltips end

---@param self FairyGUI.GObject
---@param val boolean
__set.tooltips = function(self, val)
    if (not string.isNullOrEmpty(self._tooltips)) then
        self.onRollOver:Remove(self.__rollOverDelegate)
        self.onRollOut:Remove(self.__rollOutDelegate)
    end

    self._tooltips = value
    if (not string.isNullOrEmpty(self._tooltips)) then
        self.onRollOver:Add(self.__rollOverDelegate)
        self.onRollOut:Add(self.__rollOutDelegate)
    end
end

---@param self FairyGUI.GObject
__get.filter = function(self)
    return self.displayObject ~= nil and self.displayObject.filter or nil
end

---@param self FairyGUI.GObject
---@param val FairyGUI.IFilter
__set.filter = function(self, val)
    if self.displayObject ~= nil then
        self.displayObject.filter = val
    end
end

---@param self FairyGUI.GObject
__get.blendMode = function(self)
    return self.displayObject ~= nil and self.displayObject.blendMode or BlendMode.None
end

---@param self FairyGUI.GObject
---@param val FairyGUI.BlendMode
__set.blendMode = function(self, val)
    if self.displayObject ~= nil then
        self.displayObject.BlendMode = val
    end
end

---@param self FairyGUI.GObject
__get.gameObjectName = function(self)
    if self.displayObject ~= nil then
        return self.displayObject.gameObject.name
    end
    return nil
end

---@param self FairyGUI.GObject
---@param val boolean
__set.gameObjectName = function(self, val)
    if self.displayObject ~= nil then
        self.displayObject.gameObject.name = val
    end
end

---@param self FairyGUI.GObject
__get.inContainer = function(self)
    return self.displayObject ~= nil and self.displayObject.parent ~= nil
end

---@param self FairyGUI.GObject
__get.onStage = function(self)
    return self.displayObject ~= nil and self.displayObject.stage ~= nil
end

---@param self FairyGUI.GObject
__get.resourceURL = function(self)
    if self.packageItem ~= nil then
        return UIPackage.URL_PREFIX + self.packageItem.owner.id + self.packageItem.id
    end
    return nil
end

---@param self FairyGUI.GObject
__get.gearXY = function(self)
    return self:GetGear(1)
end

---@param self FairyGUI.GObject
__get.gearSize = function(self)
    return self:GetGear(2)
end

---@param self FairyGUI.GObject
__get.gearLook = function(self)
    return self:GetGear(3)
end

---@param self FairyGUI.GObject
__get.group = function(self)
    return self._group
end

---@param self FairyGUI.GObject
---@param val FairyGUI.GGroup
__set.group = function(self, val)
    if (self._group ~= val) then
        if (self._group ~= nil) then
            self._group:SetBoundsChangedFlag(true)
        end
        self._group = val
        if (self._group ~= nil) then
            self._group:SetBoundsChangedFlag(true)
        end
        self:HandleVisibleChanged()
        if (self.parent ~= nil) then
            self.parent:ChildStateChanged(self)
        end
    end
end

---@param self FairyGUI.GObject
__get.root = function(self)
    local p = self
    while (p.parent ~= nil) do
        p = p.parent
    end

    if p:isa(GRoot) then
        return p
    end

    if (p.displayObject ~= nil and p.displayObject.parent ~= nil) then
        local d = p.displayObject.parent:GetChild("GRoot")
        if (d ~= nil and d.gOwner:isa(GRoot)) then
            return d.gOwner
        end
    end

    return GRoot.inst
end

---@param self FairyGUI.GObject
__get.text = function(self)
    return nil
end

---@param self FairyGUI.GObject
__get.icon = function(self)
    return nil
end

---@param self FairyGUI.GObject
__get.draggable = function(self)
    return self._draggable
end

---@param self FairyGUI.GObject
---@param val boolean
__set.draggable = function(self, val)
    if self._draggable ~= val then
        self._draggable = val
        self:InitDrag()
    end
end

---@param self FairyGUI.GObject
__get.dragging = function(self)
    return self.draggingObject == self
end

---@param self FairyGUI.GObject
__get.asImage = function(self) return self end

---@param self FairyGUI.GObject
__get.asCom = function(self) return self end

---@param self FairyGUI.GObject
__get.asButton = function(self) return self end

---@param self FairyGUI.GObject
__get.asLabel = function(self) return self end

---@param self FairyGUI.GObject
__get.asProgress = function(self) return self end

---@param self FairyGUI.GObject
__get.asSlider = function(self) return self end

---@param self FairyGUI.GObject
__get.asComboBox = function(self) return self end

---@param self FairyGUI.GObject
__get.asTextField = function(self) return self end

---@param self FairyGUI.GObject
__get.asRichTextField = function(self) return self end

---@param self FairyGUI.GObject
__get.asTextInput = function(self) return self end

---@param self FairyGUI.GObject
__get.asLoader = function(self) return self end

---@param self FairyGUI.GObject
__get.asList = function(self) return self end

---@param self FairyGUI.GObject
__get.asGraph = function(self) return self end

---@param self FairyGUI.GObject
__get.asGroup = function(self) return self end

---@param self FairyGUI.GObject
__get.asMovieClip = function(self) return self end
--endregion

FairyGUI.GObject = GObject
return GObject