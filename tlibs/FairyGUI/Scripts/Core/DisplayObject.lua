--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 17:56
--

--region 模块引用
local Class = require('libs.Class')

local GameObject = Love2DEngine.GameObject
local Transform = Love2DEngine.Transform
local Vector2 = Love2DEngine.Vector2
local Vector3 = Love2DEngine.Vector3
local Matrix4x4 = Love2DEngine.Matrix4x4
local Rect = Love2DEngine.Rect
local Material = Love2DEngine.Material
local RenderMode = Love2DEngine.RenderMode
local DisplayOptions = Love2DEngine.DisplayOptions
local Screen = Love2DEngine.Screen

local EventDispatcher = FairyGUI.EventDispatcher
local Container = FairyGUI.Container
local NGraphics = FairyGUI.NGraphics
local GObject = FairyGUI.GObject
local EventListener = FairyGUI.EventListener
local EventCallback0 = FairyGUI.EventCallback0
local BlendMode = FairyGUI.BlendMode
local IFilter = FairyGUI.IFilter
local Margin = FairyGUI.Margin
local ToolSet = FairyGUI.ToolSet
local ShaderConfig = FairyGUI.ShaderConfig
local CaptureCamera = FairyGUI.CaptureCamera
local HitTestContext = FairyGUI.HitTestContext

local Approximately = math.Approximately
local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

--endregion

--region 类定义
---@class FairyGUI.DisplayObject:FairyGUI.EventDispatcher
---@field public name string
---@field public parent FairyGUI.Container
---@field public gameObject Love2DEngine.GameObject
---@field public cachedTransform Love2DEngine.Transform
---@field public graphics FairyGUI.NGraphics
---@field public paintingGraphics FairyGUI.NGraphics
---@field public onPaint FairyGUI.EventCallback0
---@field public gOwner FairyGUI.GObject
---@field public id number
---@field public onClick FairyGUI.EventListener
---@field public onRightClick FairyGUI.EventListener
---@field public onTouchBegin FairyGUI.EventListener
---@field public onTouchMove FairyGUI.EventListener
---@field public onTouchEnd FairyGUI.EventListener
---@field public onRollOver FairyGUI.EventListener
---@field public onRollOut FairyGUI.EventListener
---@field public onMouseWheel FairyGUI.EventListener
---@field public onAddedToStage FairyGUI.EventListener
---@field public onRemoveFromStage FairyGUI.EventListener
---@field public onKeyDown FairyGUI.EventListener
---@field public onClickLink FairyGUI.EventListener
---@field public alpha number
---@field public visible boolean
---@field public grayed boolean
---@field public x number
---@field public y number
---@field public z number
---@field public scaleX number
---@field public scaleY number
---@field public scale Love2DEngine.Vector2
---@field public rotation number
---@field public rotationX number
---@field public rotationY number
---@field public skew Love2DEngine.Vector2
---@field public perspective boolean
---@field public focalLength number
---@field public xy Love2DEngine.Vector2
---@field public position Love2DEngine.Vector3
---@field public width number
---@field public height number
---@field public size Love2DEngine.Vector2
---@field public pivot Love2DEngine.Vector2
---@field public location Love2DEngine.Vector3
---@field public material Love2DEngine.Material
---@field public shader Love2DEngine.Shader
---@field public renderingOrder number
---@field public layer int
---@field public isDisposed boolean
---@field public topmost FairyGUI.Container
---@field public stage FairyGUI.Stage
---@field public worldSpaceContainer FairyGUI.Container
---@field public touchable boolean
---@field public paintingMode boolean
---@field public cacheAsBitmap boolean
---@field public filter FairyGUI.IFilter
---@field public blendMode FairyGUI.BlendMode
---@field private _visible boolean
---@field private _touchable boolean
---@field private _pivot Love2DEngine.Vector2
---@field private _pivotOffset Love2DEngine.Vector3
---@field private _skew Love2DEngine.Vector2
---@field private _renderingOrder number
---@field private _alpha number
---@field private _grayed boolean
---@field private _blendMode FairyGUI.BlendMode
---@field private _filter FairyGUI.IFilter
---@field private _home Love2DEngine.Transform
---@field private _perspective boolean
---@field private _focalLenght number
---@field private _rotation Love2DEngine.Vector3
---@field protected _captureDelegate FairyGUI.EventCallback0 @缓存这个delegate，可以防止Capture状态下每帧104B的GC
---@field protected _paintingMode number @1-滤镜，2-blendMode，4-transformMatrix, 8-cacheAsBitmap
---@field protected _paintingMargin FairyGUI.Margin
---@field protected _paintingFlag number
---@field protected _paintingMaterial Love2DEngine.Material
---@field protected _cacheAsBitmap boolean
---@field protected _contentRect Love2DEngine.Rect
---@field protected _requireUpdateMesh boolean
---@field protected _transformMatrix Love2DEngine.Matrix4x4
---@field protected _ownsGameObject boolean
---@field public _disposed boolean
---@field public _touchDisabled boolean
---@field public _internal_bounds number[]
---@field public _skipInFairyBatching boolean
---@field public _outlineChanged boolean
local DisplayObject = Class.inheritsFrom('DisplayObject', {}, EventDispatcher)
--endregion

--region 类变量
DisplayObject._gInstanceCounter = 0
--endregion

--region 成员函数
function DisplayObject:__ctor(...)
    self._alpha = 1
    self._visible = true
    self._touchable = true
    DisplayObject._gInstanceCounter = DisplayObject._gInstanceCounter + 1
    self.id = DisplayObject._gInstanceCounter
    self._blendMode = BlendMode.Normal
    self._focalLenght = 2000
    self._captureDelegate = EventCallback0.new() --缓存这个delegate，可以防止Capture状态下每帧104B的GC
    self._captureDelegate:Add(self.Capture, self)
    self._outlineChanged = true
    self._internal_bounds = {0,0,0,0}

    self.onPaint = EventCallback0.new()

    self.onRightClick = EventListener.new(self, 'onRightClick')
    self.onTouchBegin = EventListener.new(self, 'onTouchBegin')
    self.onTouchMove = EventListener.new(self, 'onTouchMove')
    self.onTouchEnd = EventListener.new(self, 'onTouchEnd')
    self.onRollOver = EventListener.new(self, 'onRollOver')
    self.onRollOut = EventListener.new(self, 'onRollOut')
    self.onMouseWheel = EventListener.new(self, 'onMouseWheel')
    self.onAddedToStage = EventListener.new(self, 'onAddedToStage')
    self.onRemoveFromStage = EventListener.new(self, 'onRemoveFromStage')
    self.onKeyDown = EventListener.new(self, 'onKeyDown')
    self.onClickLink = EventListener.new(self, 'onClickLink')

    self._pivot = Vector2()
    self._pivotOffset = Vector3()
    self._skew = Vector2()

    self._cacheAsBitmap = false
end

---@param gameObjectName string
function DisplayObject:CreateGameObject(gameObjectName)
    self.gameObject = GameObject:get(gameObjectName)
    self.cachedTransform = self.gameObject.transform
    self.gameObject:SetActive(false)
    self._ownsGameObject = true
end

---@param gameObject Love2DEngine.GameObject
function DisplayObject:SetGameObject(gameObject)
    self.gameObject = gameObject
    self.cachedTransform = self.gameObject.transform
    self._rotation = self.cachedTransform.localEulerAngles
    self._ownsGameObject = false
end

function DisplayObject:DestroyGameObject()
    if self._ownsGameObject and self.gameObject ~= nil then
        GameObject.recycle(self.gameObject)
        self.gameObject = nil
        self.cachedTransform = nil
    end
end

---@param xv number
---@param yv number
function DisplayObject:SetXY(xv, yv)
    self:SetPosition(xv, yv, self.cachedTransform.localPosition.z)
end

---@param xv number
---@param yv number
---@param zv number
function DisplayObject:SetPosition(xv, yv, zv)
    local v = self.cachedTransform.localPosition
    v.x, v.y, v.z = xv, -yv, zv
    self.cachedTransform.localPosition = v
    self._outlineChanged = true
end

---@param wv number
---@param hv number
function DisplayObject:SetSize(wv, hv)
    local wc = Approximately(wv, self._contentRect.width)
    local hc = Approximately(hv, self._contentRect.height)

    if wc or hc then
        self._contentRect.width = wv
        self._contentRect.height = hv
        self:OnSizeChanged(wc, hc)
    end
end

---virtual
function DisplayObject:EnsureSizeCorrect()

end

---@param widthChanged boolean
---@param heightChanged boolean
function DisplayObject:OnSizeChanged(widthChanged, heightChanged)
    self:ApplyPivot()
    self._paintingFlag = 1
    if nil ~= self.graphics then
        self._requireUpdateMesh = true
    end
    self._outlineChanged = true
end

---@param xv number
---@param yv number
function DisplayObject:SetScale(xv, yv)
    local v = self.cachedTransform.localScale
    v.x = self:ValidateScale(xv)
    v.z = v.x
    v.y = self:ValidateScale(yv)
    self.cachedTransform.localScale = v
    self._outlineChanged = true
    self:ApplyPivot()
end

-- 在scale过小情况（极端情况=0），当使用Transform的坐标变换时，变换到世界，再从世界变换到本地，会由于精度问题造成结果错误。
-- 这种错误会导致Batching错误，因为Batching会使用缓存的outline。
-- 这里限制一下scale的最小值作为当前解决方案。
-- 这个方案并不完美，因为限制了本地scale值并不能保证对世界scale不会过小。
---@param value number
---@return number
function DisplayObject:ValidateScale(value)
    if value >= 0 and value < 0.001 then
        value = 0.001
    elseif value < 0 and value > -0.001 then
        value = -0.001
    end
    return value
end

function DisplayObject:UpdateTransformMatrix()
    local matrix = Matrix4x4.identity
    --TODO:DisplayObject:UpdateTransformMatrix
end

function DisplayObject:UpdatePivotOffset()
    local _pivot, _contentRect = self._pivot, self._contentRect
    local px = _pivot.x * _contentRect.width
    local py = _pivot.y * _contentRect.height

    local matrix = Matrix4x4.TRS(Vector3.zero, self.cachedTransform.localRotation,
            self.cachedTransform.localScale)
    self._pivotOffset = matrix:MultiplyPoint(Vector3(px, -py, 0))
end

function DisplayObject:ApplyPivot()
    local _pivot = self._pivot
    if _pivot.x ~= 0 or _pivot.y ~= 0 then
        local oldOffset = self._pivotOffset

        self:UpdatePivotOffset()
        local v = self.cachedTransform.localPosition
        v:Add(oldOffset):Sub(self._pivotOffset)
        self.cachedTransform.localPosition = v
        self._outlineChanged = true
    end
end

---@param value FairyGUI.Container
function DisplayObject:InternalSetParent(value)
    if self.parent ~= value then
        if value == nil and self.parent._disposed then
            self.parent = value
        else
            self.parent = value
            self:UpdateHierachy()
        end
        self._outlineChanged = true
    end
end

---进入绘画模式，整个对象将画到一张RenderTexture上，然后这种贴图将代替原有的显示内容。
---可以在onPaint回调里对这张纹理进行进一步操作，实现特殊效果。
---可能有多个地方要求进入绘画模式，这里用requestorId加以区别，取值是1、2、4、8、16以此类推。1024内内部保留。用户自定义的id从1024开始。
---@param requestorId number @请求者id
---@param margin FairyGUI.Margin @纹理四周的留空。如果特殊处理后的内容大于原内容，那么这里的设置可以使纹理扩大。
function DisplayObject:EnterPaintingMode(requestorId, margin)
    local first = (self._paintingMode == 0)
    self._paintingMode = bor(self._paintingMode, requestorId)
    if first then
        if nil == self.paintingGraphics then
            if nil == self.graphics then
                self.paintingGraphics = NGraphics.new(self.gameObject)
            else
                local go = GameObject:get(self.gameObject.name .. " (Painter)")
                go.layer = self.gameObject.layer
                ToolSet.SetParent(go.transform, self.cachedTransform)
                go.hideFlags = DisplayOptions.hideFlags
                self.paintingGraphics = NGraphics.new(go)
            end
        else
            self.paintingGraphics.enabled = true
        end
        self.paintingGraphics.vertexMatrix = nil

        if self._paintingMaterial == nil then
            self._paintingMaterial = Material.new(ShaderConfig.GetShader(ShaderConfig.imageShader))
            self._paintingMaterial.hideFlags = DisplayOptions.hideFlags
        end
        self.paintingGraphics.material = self._paintingMaterial

        if self.isa(Container) then
            self:SetChildrenLayer(CaptureCamera.hiddenLayer)
            self:UpdateBatchingFlags()
        else
            self:InvalidateBatchingState()
        end

        if self.graphics ~= nil then
            self.gameObject.layer = CaptureCamera.hiddenLayer
        end

        self._paintingMargin = Margin.new()
    end
    if margin ~= nil then
        self._paintingMargin = margin
    end
    self._paintingFlag = 1
end

---离开绘画模式
---@param requestorId number
function DisplayObject:LeavePaintingMode(requestorId)
    if self._paintingMode == 0 or self._disposed then
        return
    end

    self._paintingMode = bnot(self._paintingMode, requestorId)
    if self._paintingMode == 0 then
        self.paintingGraphics:ClearMesh()
        self.paintingGraphics.enabled = false

        if self.isa(Container) then
            self:SetChildrenLayer(self.layer)
            self:UpdateBatchingFlags()
        else
            self:InvalidateBatchingState()
        end

        if self.graphics ~= nil then
            self.gameObject.layer = self.paintingGraphics.gameObject.layer
        end
    end
end

---@param targetSpace
function DisplayObject:GetBounds(targetSpace)
    self:EnsureSizeCorrect()

    if targetSpace == self or self._contentRect.width == 0 or self._contentRect.height == 0 then
        return self._contentRect
    end

    if targetSpace == self.parent and self._rotation.z == 0 then
        local sx, sy = self.scaleX, self.scaleY
        return Rect.new(self.x, self.y, self._contentRect.width * sx, self._contentRect.height * sy)
    end

    return self:TransformRect(self._contentRect, targetSpace)
end

function DisplayObject:InternalHitTest()
    if not self._visible or (HitTestContext.forTouch and (not self._touchable or self._touchDisabled)) then
        return nil
    end
    return self:HitTest()
end

function DisplayObject:InternalHitTestMask()
    if self._visible then
        return self:HitTest()
    end
    return nil
end

function DisplayObject:HitTest()
    local rect = self:GetBounds(self)
    if rect.width == 0 or rect.height == 0 then
        return nil
    end

    local localPoint = self:WorldToLocal(HitTestContext.worldPoint, HitTestContext.direction)
    if rect:Contains(localPoint) then
        return self
    end
    return nil
end

---将舞台坐标转换为本地坐标
function DisplayObject:GlobalToLocal(point)
    local wsc = self.worldSpaceContainer

    if wsc ~= nil then
        local cam = wsc:GetRenderCamera()
        local worldPoint, direction
        local screenPoint = Vector3()
        screenPoint.x = point.x
        screenPoint.y = Screen.height - point.y

        if wsc.hitArea:isa(MeshColliderHitTest) then
            --TODO: DisplayObject:GlobalToLocal
        end
    end
end

--endregion

--region 属性访问器
local __get = Class.init_get(DisplayObject)
local __set = Class.init_set(DisplayObject)

__get.alpha = function(self)
    return self._alpha
end

__set.alpha = function(self, val)
    self._alpha = val
end

__get.grayed = function(self)
    return self._grayed
end
__set.grayed = function(self, val)
    self._grayed = val
end

__get.visible = function(self)
    return self._visible
end

---@param self FairyGUI.DisplayObject
__set.visible = function(self, val)
    if val ~= self._visible then
        self._visible = val
        self._outlineChanged = true
        if nil ~= self.parent and self._visible then
            self.gameObject:SetActive(true)
            self:InvalidateBatchingState()
            if self:isa(Container) then
                self:InvalidateBatchingState(true)
            end
        else
            self.gameObject:SetActive(false)
        end
    end
end

---@param self FairyGUI.DisplayObject
__get.x = function(self)
    return self.cachedTransform.localPosition.x
end

---@param self FairyGUI.DisplayObject
__set.x = function(self, val)
    local pos = self.cachedTransform.localPosition
    pos.x = val
    self.cachedTransform.localPosition = pos
    self._outlineChanged = true
end

---@param self FairyGUI.DisplayObject
__get.y = function(self)
    return -self.cachedTransform.localPosition.y
end

---@param self FairyGUI.DisplayObject
__set.y = function(self, val)
    local pos = self.cachedTransform.localPosition
    pos.y = -val
    self.cachedTransform.localPosition = pos
    self._outlineChanged = true
end

---@param self FairyGUI.DisplayObject
__get.z = function(self)
    return self.cachedTransform.localPosition.z
end

---@param self FairyGUI.DisplayObject
__set.z = function(self, val)
    local pos = self.cachedTransform.localPosition
    pos.z = val
    self.cachedTransform.localPosition = pos
    self._outlineChanged = true
end

---@param self FairyGUI.DisplayObject
__get.xy = function(self)
    return Vector2(self.x, self.y)
end

---@param self FairyGUI.DisplayObject
__set.xy = function(self, val)
    self:SetPosition(val.x, val.y, self.cachedTransform.localPosition.z)
end

---@param self FairyGUI.DisplayObject
__get.position = function(self)
    return Vector2(self.x, self.y, self.z)
end

---@param self FairyGUI.DisplayObject
__set.position = function(self, val)
    self:SetPosition(val.x, val.y, val.z)
end

---@param self FairyGUI.DisplayObject
__get.width = function(self)
    self:EnsureSizeCorrect()
    return self._contentRect.width
end

---@param self FairyGUI.DisplayObject
__set.width = function(self, val)
    if not Approximately(val, self._contentRect.width) then
        self._contentRect.width = val
        self:OnSizeChanged(true, false)
    end
end

---@param self FairyGUI.DisplayObject
__get.height = function(self)
    self:EnsureSizeCorrect()
    return self._contentRect.height
end

---@param self FairyGUI.DisplayObject
__set.height = function(self, val)
    if not Approximately(val, self._contentRect.height) then
        self._contentRect.height = val
        self:OnSizeChanged(false, true)
    end
end

---@param self FairyGUI.DisplayObject
__get.size = function(self)
    self:EnsureSizeCorrect()
    return self._contentRect.size
end

---@param self FairyGUI.DisplayObject
__set.size = function(self, val)
    self:SetSize(val.x, val.y)
end

---@param self FairyGUI.DisplayObject
__get.ScaleX = function(self)
    return self.cachedTransform.localScale.x
end

---@param self FairyGUI.DisplayObject
__set.ScaleX = function(self, val)
    local scale = self.cachedTransform.localScale
    scale.x = self:ValidateScale(val)
    scale.z = scale.x
    self.cachedTransform.localScale = scale
    self._outlineChanged = true
    self:ApplyPivot()
end

---@param self FairyGUI.DisplayObject
__get.ScaleY = function(self)
    return self.cachedTransform.localScale.y
end

---@param self FairyGUI.DisplayObject
__set.ScaleY = function(self, val)
    local scale = self.cachedTransform.localScale
    scale.y = self:ValidateScale(val)
    self.cachedTransform.localScale = scale
    self._outlineChanged = true
    self:ApplyPivot()
end

---@param self FairyGUI.DisplayObject
__get.scale = function(self)
    return self.cachedTransform.localScale
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Vector2
__set.scale = function(self, val)
    self:SetScale(val.x, val.y)
end

---@param self FairyGUI.DisplayObject
__get.rotation = function(self)
    return -self._rotation.z
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Vector2
__set.rotation = function(self, val)
    self._rotation.z = -val
    self._outlineChanged = true
    if self._perspective then
        self:UpdateTransformMatrix()
    else
        self.cachedTransform.localEulerAngles = self._rotation
        self:ApplyPivot()
    end
end

---@param self FairyGUI.DisplayObject
__get.rotationX = function(self)
    return self._rotation.x
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Vector2
__set.rotationX = function(self, val)
    self._rotation.x = val
    self._outlineChanged = true
    if self._perspective then
        self:UpdateTransformMatrix()
    else
        self.cachedTransform.localEulerAngles = self._rotation
        self:ApplyPivot()
    end
end

---@param self FairyGUI.DisplayObject
__get.rotationY = function(self)
    return self._rotation.y
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Vector2
__set.rotationY = function(self, val)
    self._rotation.y = val
    self._outlineChanged = true
    if self._perspective then
        self:UpdateTransformMatrix()
    else
        self.cachedTransform.localEulerAngles = self._rotation
        self:ApplyPivot()
    end
end

---@param self FairyGUI.DisplayObject
__get.skew = function(self)
    return self._skew
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Vector2
__set.skew = function(self, val)
    self._skew = val
    self._outlineChanged = true

    self:UpdateTransformMatrix()
end

---@param self FairyGUI.DisplayObject
__get.perspective = function(self)
    return self._perspective
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Vector2
__set.perspective = function(self, val)
    if self._perspective ~= val then
       self.perspective = val
        if val then
            self.cachedTransform.localEulerAngles = Vector3.zero
        else
            self.cachedTransform.localEulerAngles = self._rotation
        end
        self:ApplyPivot()
        self:UpdateTransformMatrix()
    end
end

---@param self FairyGUI.DisplayObject
__get.focalLength = function(self)
    return self._focalLength
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Vector2
__set.focalLength = function(self, val)
    if val <= 0 then
        val = 1

        self._focalLenght = val
        if self._transformMatrix ~= nil then
            self:UpdateTransformMatrix()
        end
    end
end

---@param self FairyGUI.DisplayObject
__get.pivot = function(self)
    return self._pivot
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Vector2
__set.pivot = function(self, val)
    local _pivot = self._pivot
    local _contentRect = self._contentRect
    local deltaPivot = Vector2()
    deltaPivot.x = (val.x - _pivot.x)*_contentRect.width
    deltaPivot.y = (-val.y + _pivot.y)*_contentRect.height
    local oldOffset = self._pivotOffset

    self._pivot = val
    self:UpdatePivotOffset()
    local v = self.cachedTransform.localPosition
    v:Add(oldOffset):Sub(self._pivotOffset):Add(deltaPivot)
    self.cachedTransform.localPosition = v
    self._outlineChanged = true

    if self._transformMatrix ~= nil then
        self:UpdateTransformMatrix()
    end
end

---@param self FairyGUI.DisplayObject
__get.location = function(self)
    local pos = self.position
    local _pivotOffset = self._pivotOffset
    pos.x = pos.x + _pivotOffset.x
    pos.y = pos.y - _pivotOffset.y
    pos.z = pos.z - _pivotOffset.z
    return self._pivot
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Vector2
__set.location = function(self, val)
    local _pivotOffset = self._pivotOffset
    self:SetPosition(val.x - _pivotOffset.x,
            val.y + _pivotOffset.y, val.z - _pivotOffset.y)
end

---@param self FairyGUI.DisplayObject
__get.material = function(self)
    if self.graphics ~= nil then
        return self.graphics.material
    end

    return nil
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Material
__set.material = function(self, val)
    if self.graphics ~= nil then
        self.graphics.material = val
    end
end

---@param self FairyGUI.DisplayObject
__get.shader = function(self)
    if self.graphics ~= nil then
        return self.graphics.shader
    end

    return nil
end

---@param self FairyGUI.DisplayObject
---@param val Love2DEngine.Shader
__set.shader = function(self, val)
    if self.graphics ~= nil then
        self.graphics.shader = val
    end
end

---@param self FairyGUI.DisplayObject
__get.renderingOrder = function(self)
    return self._renderingOrder
end

---@param self FairyGUI.DisplayObject
---@param val number
__set.renderingOrder = function(self, val)
    self._renderingOrder = val
    if self.graphics ~= nil then
        self.graphics.sortingOrder = val
    end
    if self._paintingMode > 0 then
        self.paintingGraphics.sortingOrder = val
    end
end

---@param self FairyGUI.DisplayObject
__get.layer = function(self)
    if self._paintingMode > 0 then
        return self.paintingGraphics.gameObject.layer
    end
    return self.gameObject.layer
end

---@param self FairyGUI.DisplayObject
---@param val number
__set.layer = function(self, val)
    if self._paintingMode > 0 then
        self.paintingGraphics.gameObject.layer = val
    else
        self.gameObject.layer = val
    end
end

---@param self FairyGUI.DisplayObject
__get.isDisposed = function(self)
    return self._disposed or self.gameObject == nil
end

---@param self FairyGUI.DisplayObject
__get.topmost = function(self)
    local currentObject = self
    while currentObject.parent ~= nil do
        currentObject = currentObject.parent
    end
    return currentObject
end

---@param self FairyGUI.DisplayObject
__get.stage = function(self)
    return self.topmost
end

---@param self FairyGUI.DisplayObject
__get.worldSpaceContainer = function(self)
    local wsc = nil
    currentObject = self
    while currentObject.parent ~= nil do
        if currentObject:isa(Container) and currentObject.renderMode == RenderMode.WorldSpace then
            wsc = currentObject
            break
        end
        currentObject = currentObject.parent
    end
    return wsc
end

---@param self FairyGUI.DisplayObject
__get.touchable = function(self)
    return self._touchable
end

---@param self FairyGUI.DisplayObject
---@param val boolean
__set.touchable = function(self, val)
    self._touchable = val
end

---@param self FairyGUI.DisplayObject
__get.paintingMode = function(self)
    return self._paintingMode > 0
end

---@param self FairyGUI.DisplayObject
__get.cacheAsBitmap = function(self)
    return self._cacheAsBitmap
end

---@param self FairyGUI.DisplayObject
---@param val boolean
__set.cacheAsBitmap = function(self, val)
    self._cacheAsBitmap = val
    if val then
        self:EnterPaintingMode(8, nil)
    else
        self:LeavePaintingMode(8)
    end
end


---@param self FairyGUI.DisplayObject
__get.filter = function(self)
    return self._filter
end

---@param self FairyGUI.DisplayObject
---@param val FairyGUI.IFilter
__set.filter = function(self, val)
    if val == self._filter then
        return
    end

    if self._filter ~= nil then
        self._filter:Dispose()
    end

    if val ~= nil and val.target ~= nil then
        val.target.filter = nil
    end

    self._filter =  val
    if self._filter ~= nil then
        self._filter.target = self
    end
end


---@param self FairyGUI.DisplayObject
__get.blendMode = function(self)
    return self._blendMode
end

---@param self FairyGUI.DisplayObject
---@param val FairyGUI.BlendMode
__set.blendMode = function(self, val)
    self._blendMode = val
    self:InvalidateBatchingState()

    if self:isa(Container) then
        if self._blendMode ~= BlendMode.Normal then
            self:EnterPaintingMode(2, nil)
            self.paintingGraphics.blendMode = self._blendMode
        else
            self:LeavePaintingMode(2)
        end
    else
        self.graphics.blendMode = self._blendMode
    end
end



--endregion
--TODO: FairyGUI.DisplayObject

--region 模块定义
FairyGUI.DisplayObject = DisplayObject
return DisplayObject
--endregion