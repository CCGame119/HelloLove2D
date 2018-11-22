--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/20 14:05
--

local Class = require('libs.Class')

local LuaBehaviour = Love2DEngine.LuaBehaviour
local Vector3 = Love2DEngine.Vector3
local Component = Love2DEngine.Component
local SkinnedMeshRenderer = Love2DEngine.SkinnedMeshRenderer
local MeshRenderer = Love2DEngine.MeshRenderer
local Renderer = Love2DEngine.Renderer
local Debug = Love2DEngine.Debug
local RenderMode = Love2DEngine.RenderMode
local Vector2 = Love2DEngine.Vector2
local Screen = Love2DEngine.Screen

local EMRenderTarget = FairyGUI.EMRenderTarget
local HitTestMode = FairyGUI.HitTestMode
local UIPackage = FairyGUI.UIPackage
local StageCamera = FairyGUI.StageCamera
local Container = FairyGUI.Container
local BoxCollider = FairyGUI.BoxCollider
local BoxColliderHitTest = FairyGUI.BoxColliderHitTest
local UpdateContext = FairyGUI.UpdateContext
local EventCallback0 = FairyGUI.EventCallback0
local Stage = FairyGUI.Stage
local UIContentScaler = FairyGUI.UIContentScaler

---@class FairyGUI.FitScreen:enum
local FitScreen = {
    None = 0,
    FitSize = 1,
    FitWidthAndSetMiddle = 2,
    FitHeightAndSetCenter = 3,
}

---@class FairyGUI.UIPanel:Love2DEngine.LuaBehaviour
---@field public container FairyGUI.Container @
---@field public packageName string @
---@field public componentName string @
---@field public fitScreen FairyGUI.FitScreen @
---@field public sortingOrder number @
---@field private packagePath string
---@field private renderMode Love2DEngine.RenderMode
---@field private renderCamera Love2DEngine.Camera
---@field private position Love2DEngine.Vector3
---@field private scale Love2DEngine.Vector3
---@field private rotation Love2DEngine.Vector3
---@field private fairyBatching boolean
---@field private touchDisabled boolean
---@field private cachedUISize Love2DEngine.Vector2
---@field private hitTestMode FairyGUI.HitTestMode
---@field private setNativeChildrenOrder boolean
---@field private screenSizeVer number
---@field private uiBounds Love2DEngine.Rect @Track bounds even when UI is not created, edit mode
---@field private _ui FairyGUI.GComponent
---@field private _created boolean
---@field private _renders Love2DEngine.Renderer[]
local UIPanel = Class.inheritsFrom('UIPanel', {
    renderCamera = nil,
    scale = Vector3(1, 1, 1),
    rotation = Vector3(1, 1, 1),
    fairyBatching = false,
    touchDisabled = false,
    hitTestMode =  HitTestMode.Default,
    setNativeChildrenOrder = false,
}, LuaBehaviour, {EMRenderTarget})

function UIPanel:__ctor()
    self.UpdateHitAreaDelegate = EventCallback0.new(self.UpdateHitArea, self)
    self.__onUpdateDelegate = EventCallback0.new(self.__onUpdate, self)
end

function UIPanel:OnEnable()
    if (self.container == nil) then
        self:CreateContainer()

        if (not string.isNullOrEmpty(self.packagePath) and UIPackage.GetByName(self.packageName) == nil) then
            UIPackage.AddPackage(self.packagePath)
        end
    else
        self.container._disabled = false
    end
end

function UIPanel:OnDisable()
    if (self.container ~= nil) then
        self.container._disabled = true
    end
end

function UIPanel:Start()
    if not self._created then
        self:CreateUI_PlayMode()
    end
end

function UIPanel:Update()
    if (self.screenSizeVer ~= StageCamera.screenSizeVer) then
        self:HandleScreenSizeChanged()
    end
end

function UIPanel:OnDestroy()
    if (self.container ~= nil) then
        if (self._ui ~= nil) then
            self._ui:Dispose()
            self._ui = nil
        end

        self.container:Dispose()
        self.container = nil
    end

    self._renders = nil
end

function UIPanel:__onUpdate()
    local cnt = #self._renders
    UpdateContext.current.renderingOrder = UpdateContext.current.renderingOrder + 1
    local sv = UpdateContext.current.renderingOrder
    for i = 1, cnt do
        local r = self._renders[i]
        if (r ~= nil) then
            self._renders[i].sortingOrder = sv
        end
    end
end

function UIPanel:CreateContainer()
    self.container = Container.new(self.gameObject)
    self.container.renderMode = self.renderMode
    self.container.renderCamera = self.renderCamera
    self.container.touchable = not self.touchDisabled
    self.container.self._panelOrder = self.sortingOrder
    self.container.fairyBatching = self.fairyBatching

    self:SetSortingOrder(self.sortingOrder, true)
    if (self.hitTestMode == HitTestMode.Raycast) then
        self.container.hitArea = BoxColliderHitTest.new(self.gameObject.AddComponent(BoxCollider))
    end

    if (self.setNativeChildrenOrder) then
        self:CacheNativeChildrenRenderers()

        self.container.onUpdate:Add(self.__onUpdateDelegate)
    end
end

function UIPanel:CreateUI()
    if (self._ui ~= nil) then
        self._ui:Dispose()
        self._ui = nil
    end

    self:CreateUI_PlayMode()
end

---Change the sorting order of the panel in runtime.
---@param value number @sorting order value
---@param apply boolean @false if you dont want the default sorting behavior. e.g. call Stage.SortWorldSpacePanelsByZOrder later.
function UIPanel:SetSortingOrder(value, apply)
    self.sortingOrder = value
    self.container._panelOrder = value

    if apply then
        Stage.inst:ApplyPanelOrder(self.container)
    end
end

---@param value FairyGUI.HitTestMode
function UIPanel:SetHitTestMode(value)
    if (self.hitTestMode ~= value) then
        self.hitTestMode = value
        local collider = self.gameObject:GetComponent(BoxCollider)
        if (self.hitTestMode == HitTestMode.Raycast) then
            if (collider == nil) then
                collider = self.gameObject:AddComponent(BoxCollider)
            end
            self.container.hitArea = BoxColliderHitTest.new(collider)
            if (self._ui ~= nil) then
                self:UpdateHitArea()
            end
        else
            self.container.hitArea = nil
            if (collider ~= nil) then
                Component.Destroy(collider)
            end
        end
    end
end

function UIPanel:CacheNativeChildrenRenderers()
    self._renders = {}

    local t = self.container.cachedTransform
    local cnt = t.childCount
    for i = 1,  cnt do
        local go = t:GetChild(i).gameObject
        if (go.name ~= "GComponent") then
            self._renders:addRange(go.GetComponentsInChildren(Renderer, true))
        end
    end

    cnt = #self._renders
    for i = 1, cnt do
        local r = self._renders[i]
        if (r:isa(SkinnedMeshRenderer) or r:isa(MeshRenderer)) then
            -- Set the object rendering in Transparent Queue as UI objects
            if (r.sharedMaterial ~= nil) then
                r.sharedMaterial.renderQueue = 3000
            end
        end
    end
end

function UIPanel:CreateUI_PlayMode()
    self._created = true

    if (string.isNullOrEmpty(self.packageName) or string.isNullOrEmpty(self.componentName)) then
        return
    end

    self._ui = UIPackage.CreateObject(self.packageName, self.componentName)
    if (self._ui ~= nil) then
        self._ui.position = self.position:Clone()
        if (self.scale.x ~= 0 and self.scale.y ~= 0) then
            self._ui.scale = self.scale:Clone()
        end
        self._ui.rotationX = self.rotation.x
        self._ui.rotationY = self.rotation.y
        self._ui.rotation = self.rotation.z
        if (self.container.hitArea ~= nil) then
            self:UpdateHitArea()
            self._ui.onSizeChanged:Add(self.UpdateHitAreaDelegate)
            self._ui.onPositionChanged:Add(self.UpdateHitAreaDelegate)
        end
        self.container:AddChildAt(self._ui.displayObject, 0)

        self:HandleScreenSizeChanged()
    else
        Debug.LogError("Create " .. self.componentName .. "@" .. self.packageName .. " failed!")
    end
end

function UIPanel:UpdateHitArea()
    local _ui = self.ui
    if (self.container.hitArea ~= nil) then
        self.container.hitArea:SetArea(_ui.xMin, _ui.yMin, _ui.width, _ui.height)
    end
end

function UIPanel:HandleScreenSizeChanged()
    self.screenSizeVer = StageCamera.screenSizeVer

    if (self.container ~= nil) then
        if (self.container.renderMode ~= RenderMode.WorldSpace) then
            self.container.scale = Vector2(StageCamera.UnitsPerPixel * UIContentScaler.scaleFactor, StageCamera.UnitsPerPixel * UIContentScaler.scaleFactor)
        end
    end

    local width = math.ceil(Screen.width / UIContentScaler.scaleFactor)
    local height = math.ceil(Screen.height / UIContentScaler.scaleFactor)
    if (self._ui ~= nil) then
        if self.fitScreen == FitScreen.FitSize then
            self._ui:SetSize(width, height)
            self._ui:SetXY(0, 0, true)
        elseif self.fitScreen == FitScreen.FitWidthAndSetMiddle then
            self._ui:SetSize(width, self._ui.sourceHeight)
            self._ui:SetXY(0, math.floor((height - self._ui.sourceHeight) / 2), true)
        elseif self.fitScreen == FitScreen.FitHeightAndSetCenter then
            self._ui:SetSize(self._ui.sourceWidth, height)
            self._ui:SetXY(math.floor((width - self._ui.sourceWidth) / 2), 0, true)
        end

        self:UpdateHitArea()
    else
        if self.fitScreen == FitScreen.FitSize then
            self.uiBounds.position = Vector2(0, 0)
            self.uiBounds.size = Vector2(width, height)
        elseif self.fitScreen == FitScreen.FitWidthAndSetMiddle then
            self.uiBounds.position = Vector2(0, math.floor((height - self.cachedUISize.y) / 2))
            self.uiBounds.size = Vector2(width, self.cachedUISize.y)
        elseif self.fitScreen == FitScreen.FitHeightAndSetCenter then
            self.uiBounds.position = Vector2(math.floor((width - self.cachedUISize.x) / 2), 0)
            self.uiBounds.size = Vector2(self.cachedUISize.x, height)
        end
    end
end


local __get = Class.init_get(UIPanel)
local __set = Class.init_set(UIPanel)

---@param self FairyGUI.UIPanel
__get.ui = function(self)
    if not self._created then
        if (not string.isNullOrEmpty(self.packagePath) and UIPackage.GetByName(self.packageName) == nil) then
            UIPackage.AddPackage(self.packagePath)
        end

        self:CreateUI_PlayMode()
    end

    return self._ui
end


FairyGUI.FitScreen = FitScreen
FairyGUI.UIPanel = UIPanel
return UIPanel