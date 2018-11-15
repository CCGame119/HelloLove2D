--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 19:45
--
local Class = require('libs.Class')

local RenderMode = Love2DEngine.RenderMode
local Camera = Love2DEngine.Camera
local Vector4 = Love2DEngine.Vector4
local Vector3 = Love2DEngine.Vector3
local Vector2 = Love2DEngine.Vector2
local Rect = Love2DEngine.Rect
local GameObject = Love2DEngine.GameObject

local DisplayObject = FairyGUI.DisplayObject
local EventCallback0 = FairyGUI.EventCallback0
local HitTestContext = FairyGUI.HitTestContext
local IHitTest = FairyGUI.IHitTest
local StageCamera = FairyGUI.StageCamera
local Stage = FairyGUI.Stage
local UpdateConext = FairyGUI.UpdateContext

---@class FairyGUI.Container : FairyGUI.DisplayObject
---@field public renderMode Love2DEngine.RenderMode
---@field public renderCamera Love2DEngine.Camera
---@field public opaque boolean
---@field public clipSoftness Love2DEngine.Vector4
---@field public hitArea FairyGUI.IHitTest
---@field public touchChildren boolean
---@field public onUpdate FairyGUI.EventCallback0
---@field public reverseMask boolean
---@field public numChildren number
---@field public renderMode Love2DEngine.RenderMode
---@field public fairyBatching boolean
---@field public mask FairyGUI.DisplayObject
---@field public clipRect Love2DEngine.Rect
---@field private _children FairyGUI.DisplayObject[]
---@field private _mask FairyGUI.DisplayObject
---@field private _clipRect Love2DEngine.Rect
---@field private _fBatchingRequested boolean
---@field private _fBatchingRoot boolean
---@field private _fBatching boolean
---@field private _descendants FairyGUI.DisplayObject[]
---@field protected _disabled boolean
---@field protected _panelOrder number
local Container = Class.inheritsFrom('Container', nil, DisplayObject)

---@overload fun()
---@overload fun(gameObjectName:string)
---@param attachTarget Love2DEngine.GameObject
function Container:__ctor(attachTarget)
    DisplayObject.__ctor(self)

    if nil == attachTarget then
        self:CreateGameObject('Container')
        self:Init()
        return
    end

    if type(attachTarget) == 'string' then
        local gameObjectName = attachTarget
        self:CreateGameObject(gameObjectName)
        self:Init()
        return
    end

    self:SetGameObject(attachTarget)
    self:Init()
end

function Container:Init()
    self._children = {}
    self.touchChildren = true

    self.onUpdate = EventCallback0.new()
end

---@param child FairyGUI.DisplayObject
function Container:AddChild(child)
    self:AddChildAt(child, #self._children + 1)
    return child
end

---@param child FairyGUI.DisplayObject
---@param index number
---@return FairyGUI.DisplayObject
function Container:AddChildAt(child, index)
    local count = #self._children
    if index >= 1 and index <= count + 1 then
        if child.parent == self then
            self:SetChildIndex(child, index)
        else
            child:RemoveFromParent()
            table.insert(self._children, index, child)
            child:InternalSetParent(self)

            if self.stage ~= nil then
                if child:isa(Container) then
                    child.onAddedToStage:BroadcastCall()
                else
                    child.onAddedToStage:Call()
                end

                self:InvalidateBatchingState(true)
            end
        end
        return child
    end

    assert(false, "Invalid child index")
end

---@return boolean
function Container:Contains(child)
    for i, v in ipairs(self._children) do
        if child == v then
            return true
        end
    end
    return false
end

---@param index number
---@return FairyGUI.DisplayObject
function Container:GetChildAt(index)
    return self._children[index]
end

---@param name string
---@return FairyGUI.DisplayObject
function Container:GetChild(name)
    for i, v in ipairs(self._children) do
        if v.name == name then
            return v
        end
    end
    return nil
end

---@param child FairyGUI.DisplayObject
---@return FairyGUI.DisplayObject
function Container:GetChildIndex(child)
    for i, v in ipairs(self._children) do
        if v.name == name then
            return i
        end
    end
    return 0
end

---@param child FairyGUI.DisplayObject
---@param dispose boolean
---@return FairyGUI.DisplayObject
function Container:RemoveChild(child, dispose)
    if child.parent ~= self then
        error(false, "obj is not a child")
    end
    local dispose = dispose or false
    for i, v in ipairs(self._children) do
        if v == child then
            return self:RemoveChildAt(i, dispose)
        end
    end
    return nil
end

---@param index number
---@param dispose boolean
---@return FairyGUI.DisplayObject
function Container:RemoveChildAt(index, dispose)
    local dispose = dispose or false
    local count = #self._children
    if index >= 1 and index <= count then
        local child = self._children[index]
        if self.stage ~= nil and not child._disposed then
            if child:isa(Container) then
                child.onRemoveFromStage:BroadcastCall()
            else
                child.onRemoveFromStage:Call()
            end
        end
        table.remove(self._children, index)
        self:InvalidateBatchingState(true)
        if not dispose then
            child:InternalSetParent(nil)
        else
            child:Dispose()
        end
        return child
    end
    assert(false, "Invalid child index")
end

---@param beginIndex number
---@param endIndex number
---@param dispose boolean
function Container:RemoveChildren(beginIndex, endIndex, dispose)
    local beginIndex = beginIndex or 1
    local endIndex =  endIndex or math.maxval
    local dispose = dispose or false
    if endIndex < 1 or endIndex > self.numChildren then
        endIndex = self.numChildren
    end

    for i = beginIndex, endIndex do
        self:RemoveChildAt(beginIndex, dispose)
    end
end

---@param child FairyGUI.DisplayObject
---@param index number
function Container:SetChildIndex(child, index)
    local oldIndex = 0
    for i, v in ipairs(self._children) do
        if v == child then
            oldIndex = i
            break
        end
    end
    if oldIndex == index then return end
    if oldIndex == 0 then
        error(false, 'Not a child of this container')
    end
    table.remove(self._children, oldIndex)
    if index > #self._children then
        table.insert(self._children, child)
    else
        table.insert(self._children, index, child)
    end
    self:InvalidateBatchingState(true)
end

---@param child1 FairyGUI.DisplayObject
---@param child2 FairyGUI.DisplayObject
function Container:SwapChildren(child1, child2)
    local index1, index2 = 0, 0
    for i, v in ipairs(self._children) do
        if child1 == v then
            index1 = i
        elseif child2 == v then
            index2 = i
        end
        if index1 ~= 0 and index2 ~= 0 then
            self:SwapChildrenAt(index1, index2)
            break
        end
    end
end

---@param index1 number
---@param index2 number
function Container:SwapChildrenAt(index1, index2)
    local obj1 = self._children[index1]
    local obj2 = self._children[index2]
    self._children[index1] = obj2
    self._children[index2] = obj1
    self:InvalidateBatchingState(true)
end

---@param indice number[]
---@param objs FairyGUI.DisplayObject[]
function Container:ChangeChildrenOrder(indice, objs)
    local cnt = #indice
    for i = 1, cnt do
        local obj = objs[i]
        if obj.parent ~= self then
            error(false, 'Not a child of this container')
        end
        self._children[indice[i]] = obj
    end
    self:InvalidateBatchingState(true)
end

---@param targetSpace FairyGUI.DisplayObject
---@return Love2DEngine.Rect
function Container:GetBounds(targetSpace)
    if self._clipRect ~= nil then
        return self:TransformRect(self._clipRect, targetSpace)
    end

    local count = #self._children
    local rect = Rect.zero
    if count > 0 then
        local v = self.TransformPoint(Vector2.zero, targetSpace)
        rect = Rect.MinMaxRect(v.x, v.y, 0, 0)
    elseif count == 1 then
        rect = self._children[1]:GetBounds(targetSpace)
    else
        local minX, maxX = math.fmaxval, math.fminval
        local minY, maxY = math.fmaxval, math.fminval

        for i = 1, count do
            rect = self._children[i]:GetBounds(targetSpace)
            minX = minX < rect.xMin and minX or rect.xMin
            maxX = maxX > rect.xMax and maxX or rect.xMax
            minY = minY < rect.yMin and minY or rect.yMin
            maxY = maxY > rect.yMax and maxY or rect.yMax
        end

        rect = Rect.MinMaxRect(minX, minY, maxX, maxY)
    end

    return rect
end

---@return Love2DEngine.Camera
function Container:GetRenderCamera()
    if self.renderMode == RenderMode.ScreenSpaceOverlay then
        return StageCamera.main
    end

    local cam = self.renderCamera
    if cam == nil then
        cam = HitTestContext.cachedMainCamera
    end
    if cam == nil then
        cam = StageCamera.main
    end
    return cam
end

---@param self FairyGUI.Container
---@return FairyGUI.DisplayObject
local _HitTest = function(self)
    if self._disabled then return nil end

    if self.cachedTransform.localScale.x == 0 or self.cachedTransform.localScale.y == 0 then return nil end
    
    local localPoint = Vector2()
    local savedWorldPoint = HitTestContext.worldPoint
    local savedDirection = HitTestContext.direction

    if self.hitArea ~= nil then
        if not self.hitArea:HitTest(self, localPoint) then
            HitTestContext.worldPoint = savedWorldPoint
            HitTestContext.direction = savedDirection
            return nil
        end
    else
        localPoint = self:GetHitTestLocalPoint()
        if (self._clipRect ~= nil and not self._clipRect.Contains(localPoint)) then
            HitTestContext.worldPoint = savedWorldPoint
            HitTestContext.direction = savedDirection
            return nil
        end
    end

    if self._mask ~= nil then
        local tmp = self._mask:InternalHitTestMask()
        if not self.reverseMask and tmp == nil or self.reverseMask and tmp ~= nil then
            return nil
        end
    end

    ---@type FairyGUI.DisplayObject
    local target = nil
    if self.touchChildren then
        local count = #self._children
        for i = count, 1, -1 do
            local child = self._children[i]
            if child == self._mask then
                --continue
            else
                target = child:InternalHitTest()
                if target ~= nil then
                     break
                end
            end
        end
    end

    if target ==nil and self.opaque and (self.hitArea ~= nil or self._contentRect:Contains(localPoint)) then
        target = self
    end

    HitTestContext.worldPoint = savedWorldPoint
    HitTestContext.direction = savedDirection

    return target
end

---@param stagePoint Love2DEngine.Vector2
---@param forTouch boolean
---@return FairyGUI.DisplayObject
function Container:HitTest(stagePoint, forTouch)
    if nil == stagePoint then
        return _HitTest(self)
    end

    if StageCamera.main == nil then
        if self:isa(Stage) then return self end
        return nil
    end

    HitTestContext.screenPoint = Vector2(stagePoint.x, Screen.height - stagePoint.y)
    HitTestContext.worldPoint = StageCamera.main:ScreenToWorldPoint(HitTestContext.screenPoint)
    HitTestContext.direction = Vector3.back
    HitTestContext.forTouch = forTouch

    local ret = self:HitTest()
    if ret ~= nil then return ret end
    if self:isa(Stage) then return self end
    return nil
end

---@return Love2DEngine.Vector2
function Container:GetHitTestLocalPoint()
    if  self.renderMode == RenderMode.WorldSpace then
        local camera = self:GetRenderCamera()

        local screenPoint = camera:WorldToScreenPoint(self.cachedTransform.position)
        screenPoint.x = HitTestContext.screenPoint.x
        screenPoint.y = HitTestContext.screenPoint.y

        --获得本地z轴在世界坐标的方向
        HitTestContext.worldPoint = camera:ScreenToWorldPoint(screenPoint)
        local ray = camera:ScreenPointToRay(screenPoint)
        HitTestContext.direction = Vector3.zero - ray.direction
    end

    return self:WorldToLocal(HitTestContext.worldPoint, HitTestContext.direction)
end

---@param obj FairyGUI.DisplayObject
---@return boolean
function Container:IsAncestorOf(obj)
    if obj == nil then return false end

    local p = obj.parent
    while p ~= nil do
        if p == self then
            return true
        end

        p = p.parent
    end
    return false
end

function Container:UpdateBatchingFlags()
    local oldValue = self._fBatchingRoot
    self._fBatchingRoot = self._fBatching or self._clipRect ~= nil or self._mask ~= nil or self._paintingMode > 0
    if (oldValue ~= self._fBatchingRoot) then
        if self._fBatchingRoot then
            self._fBatchingRequested = true
        elseif self._descendants ~= nil then
            self._descendants:Clear()
        end
        self:InvalidateBatchingState()
    end
end

---@param childrenChanged boolean
function Container:InvalidateBatchingState(childrenChanged)
    if nil == childrenChanged then
        DisplayObject.InvalidateBatchingState(self)
        return
    end

    if childrenChanged and self._fBatchingRoot then
        self._fBatchingRequested = true
    else
        local p = self.parent
        while p ~= nil do
            if p._fBatchingRoot then
                p._fBatchingRequested = true
                break
            end
            p = p.parent
        end
    end
end

---@param value number
function Container:SetChildrenLayer(value)
    local cnt = #self._children
    for i = 1, cnt do
        local child = self._children[i]
        child.layer = value
        if child:isa(Container) and not child.paintingMode then
            child:SetChildrenLayer(value)
        end
    end
end

---@param context FairyGUI.UpdateContext
function Container:Update(context)
    if self._disabled then return end

    DisplayObject.Update(context)

    if self._cacheAsBitmap and self._paintingMode ~= 0 and self._paintingFlag == 2 then
        if not self.onUpdate.isEmpty then
            self:onUpdate()
        end
        return
    end

    if self._mask ~= nil then
        context:EnterClipping(self.id, nil, nil, self.reverseMask)
    elseif self._clipRect ~= nil then
        context:EnterClipping(self.id, self:TransformRect(self._clipRect, nil), self.clipSoftness, false)
    end

    local savedAlpha = context.alpha
    context.alpha = context.alpha * self.alpha
    local savedGrayed = context.grayed
    context.grayed = context.grayed or self.grayed

    if self._fBatching then
        context.batchingDepth = context.batchingDepth + 1
    end

    if context.batchingDepth > 0 then
        if self._mask ~= nil then
            self._mask.graphics.maskFrameId = UpdateConext.frameId
        end

        local cnt = #self._children
        for i = 1, cnt do
            local child = self._children[i]
            if child.visible then
                child:Update(context)
            end
        end
    else
        if self._mask ~= nil then
            self._mask.graphics.maskFrameId = UpdateConext.frameId
            self._mask.renderingOrder = context.renderingOrder
            context.renderingOrder = context.renderingOrder + 1
        end

        local cnt = #self._children
        for i = 1, cnt do
            local child = self._children[i]
            if child.visible then
                if child ~= self._mask then
                    child.renderingOrder = context.renderingOrder
                    context.renderingOrder = context.renderingOrder + 1
                end
                child:Update(context)
            end
        end

        if self._mask ~= nil then
            self._mask.graphics:SetStencilEraserOrder(context.renderingOrder)
            context.renderingOrder = context.renderingOrder + 1
        end
    end

    if self._fBatching then
        if context.batchingDepth == 1 then
            self:SetRenderingOrder(context)
        end
        context.batchingDepth = context.batchingDepth + 1
    end

    context.alpha = savedAlpha
    context.grayed = savedGrayed

    if self._clipRect ~= nil or self._mask ~= nil then
        context:Leaveclipping()
    end

    if self._paintingMode > 0 and self.paintingGraphics.texture ~= nil then
        UpdateConext.OnEnd:Add(self._captureDelegate, self)
    end

    if not self.onUpdate.isEmpty then
        self:onUpdate()
    end
end

---@param context FairyGUI.UpdateContext
function Container:SetRenderingOrder(context)
    if self._fBatchingRequested then
        self:DoFairyBatching()
    end

    if self._mask ~= nil then
        self._mask.renderingOrder = context.renderingOrder
        context.renderingOrder = context.renderingOrder + 1
    end

    local cnt = #self._descendants
    for i = 1, cnt do
        local child = self._descendants[i]
        if child ~= self._mask then
            child.renderingOrder = context.renderingOrder
            context.renderingOrder = context.renderingOrder + 1
        end
        if child:isa(Container) and child._fBatchingRoot then
            child:SetRenderingOrder(context)
        end
    end

    if self._mask ~= nil and self._mask.graphics ~= nil then
        self._mask.graphics:SetStencilEraserOrder(context.renderingOrder)
        context.renderingOrder = context.renderingOrder + 1
    end
end

function Container:DoFairyBatching()
    self._fBatchingRequested = false

    self._descendants = {}
    self:CollectChildren(self, false)

    local cnt = #self._descendants

    ---@type number
    local i, j, k, m
    local curMat, testMat, lastMat -- object
    ---@type FairyGUI.DisplayObject
    local current, test
    ---@type number[]
    local bound = {}
    for i = 1, cnt do
        current = self._descendants[i]
        bound = current._internal_bounds
        curMat = current.material
        if curMat ==nil or current._skipInFairyBatching then
        else
            k = -1
            lastMat = nil
            m = i
            for j = i, 1, -1 do
                test = self._descendants[j]
                if test._skipInFairyBatching then
                    break
                end

                testMat = test.material
                if testMat ~= nil then
                    if lastMat ~= testMat then
                        lastMat = testMat
                        m = j + 1
                    end

                    if curMat == testMat then
                        k = m
                    end
                end
                if (bound[1] > test._internal_bounds[1] and bound[1] or test._internal_bounds[1]) <=
                   (bound[3] < test._internal_bounds[3] and bound[3] or test._internal_bounds[3]) and
                   (bound[2] > test._internal_bounds[2] and bound[2] or test._internal_bounds[2]) <=
                   (bound[4] < test._internal_bounds[4] and bound[4] or test._internal_bounds[4]) then
                    if k == -1 then
                        k = m
                    end
                    break
                end
            end
            if k ~= -1 and i ~= k then
                table.remove(self._descendants, i)
                table.insert(self._descendants, k, current)
            end
        end
    end
end

---@param initiator FairyGUI.Container
---@param outlineChanged boolean
function Container:CollectChildren(initiator, outlineChanged)
    local count = #self._children
    for i = 1, count do
        local child = self._children[i]
        if not child.visible then
        else
            if child:isa(Container) then
                ---@type FairyGUI.Container
                local container = child
                if container._fBatchingRoot then
                    table.insert(initiator._descendants, child)
                    if outlineChanged or container._outlineChanged then
                        local rect = container:GetBounds(initiator)
                        container._internal_bounds[1] = rect.xMin
                        container._internal_bounds[2] = rect.yMin
                        container._internal_bounds[3] = rect.xMax
                        container._internal_bounds[4] = rect.yMax
                    end
                    if container._fBatchingRequested then
                        container:DoFairyBatching()
                    end
                else
                    container:CollectChildren(initiator, outlineChanged or container._outlineChanged)
                end
            elseif child ~= initiator._mask then
                if outlineChanged or child._outlineChanged then
                    local rect = container:GetBounds(initiator)
                    container._internal_bounds[1] = rect.xMin
                    container._internal_bounds[2] = rect.yMin
                    container._internal_bounds[3] = rect.xMax
                    container._internal_bounds[4] = rect.yMax
                end
                table.insert(initiator._descendants, child)
            end

            child._outlineChanged = false
        end
    end
end

function Container:Dispose()
    if self._disposed then
        return
    end

    DisplayObject.Dispose(self)

    local numChildren = #self._children
    for i = numChildren, 1, -1 do
        local obj = self._children[i]
        obj:InternalSetParent(nil)
        obj:Dispose()
    end
end

local __get = Class.init_get(Container)
local __set = Class.init_set(Container)

---@param self FairyGUI.Container
__get.numChildren = function(self) return #self._children end

---@param self FairyGUI.Container
__get.clipRect = function(self) return self._clipRect end

---@param self FairyGUI.Container
---@param val Love2DEngine.Rect
__set.clipRect = function(self, val)
    if self._clipRect ~= val then
        self._clipRect:Assign(val)
        self:UpdateBatchingFlags()
    end
end

---@param self FairyGUI.Container
__get.mask = function(self) return self._mask end

---@param self FairyGUI.Container
---@param val FairyGUI.DisplayObject
__set.mask = function(self, val)
    if self._mask ~= val then
        self._mask = val
        self:UpdateBatchingFlags()
    end
end

---@param self FairyGUI.Container
__get.touchable = function(self) return self._touchable end

---@param self FairyGUI.Container
---@param val boolean
__set.touchable = function(self, val)
    self._touchable = val
    if self.hitArea ~= nil then
        self.hitArea:SetEnabled(val)
    end
end

---@param self FairyGUI.Container
__get.contentRect = function(self) return self._contentRect end

---@param self FairyGUI.Container
---@param val boolean
__set.contentRect = function(self, val)
    self._contentRect = val
    self:OnSizeChanged(true, true)
end

---@param self FairyGUI.Container
__get.fairyBatching = function(self) return self._fBatching end

---@param self FairyGUI.Container
---@param val boolean
__set.fairyBatching = function(self, val)
    if self._fBatching == val then return end

    self._fBatching = val
    self:UpdateBatchingFlags()
end


FairyGUI.Container = Container
return Container