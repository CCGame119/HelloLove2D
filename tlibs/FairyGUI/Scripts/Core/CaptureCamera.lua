--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 12:05
--

local Class = require('libs.Class')

local LuaBehaviour = Love2DEngine.LuaBehaviour
local Camera = Love2DEngine.Camera
local GameObject = Love2DEngine.GameObject
local LayerMask = Love2DEngine.LayerMask
local Debug = Love2DEngine.Debug
local RenderTexture = Love2DEngine.RenderTexture
local RenderTextureFormat = Love2DEngine.RenderTextureFormat
local FilterMode = Love2DEngine.FilterMode
local TextureWrapMode = Love2DEngine.TextureWrapMode
local DisplayOptions = Love2DEngine.DisplayOptions
local Vector4 = Love2DEngine.Vector4
local Vector3 = Love2DEngine.Vector3
local Quaternion = Love2DEngine.Quaternion

local Container = FairyGUI.Container

local bit = require('bit')
local lshift = bit.lshift

---@class FairyGUI.CaptureCamera:Love2DEngine.LuaBehaviour
---@field public cachedTransform Love2DEngine.Transform
---@field public cachedCamera Love2DEngine.Camera
---@field public hiddenLayer number
---@field public layer number
---@field public hiddenLayer number
local CaptureCamera = Class.inheritsFrom('CaptureCamera', nil, LuaBehaviour)

---@type Love2DEngine.Camera
CaptureCamera._main = nil
CaptureCamera._layer = -1
CaptureCamera._hiddenLayer = -1

CaptureCamera.Name = "Capture Camera"
CaptureCamera.LayerName = "VUI"
CaptureCamera.HiddenLayerName = "Hidden VUI"

function CaptureCamera:OnEnable()
    self.cachedCamera = self:GetComponent(Camera)
    self.cachedTransform = self.gameObject.transform

    if self.gameObject.name == CaptureCamera.Name then
        self._main = self
    end
end

function CaptureCamera.CheckMain()
    if self._main ~= nil and self._main.cachedCamera ~= nil then
        return
    end

    local go = GameObject.Find(CaptureCamera.Name)
    if go ~= nil then
        self._main = go:GetComponent(CaptureCamera)
        return
    end

    local cameraObject = GameObject:get(CaptureCamera.Name)
    local camera = cameraObject:AddComponent(Camera)
    camera.depth = 0
    camera.cullingMask = lshift(self.layer, 1)
    camera.clearFlags = self.CameraClearFlags.Depth
    camera.orthographic = true
    camera.orthographicSize = 5
    camera.nearClipPlane = -30
    camera.farClipPlane = 30
    camera.enabled = false
    cameraObject:AddComponent(CaptureCamera)
end

---@param width number
---@param height number
---@param stencilSupport boolean
---@return Love2DEngine.RenderTexture
function CaptureCamera.CreateRenderTexture(width, height, stencilSupport)
    local texture = RenderTexture.new(width, height, stencilSupport and 24 or 0, RenderTextureFormat.ARGB32)
    texture.antiAliasing = 1
    texture.filterMode = FilterMode.Bilinear
    texture.anisoLevel = 0
    texture.useMipMap = false
    texture.wrapMode = TextureWrapMode.Clamp
    texture.hideFlags = DisplayOptions.hideFlags
    return texture
end

---@param target FairyGUI.DisplayObject
---@param texture Love2DEngine.RenderTexture
---@param offset Love2DEngine.Vector2
function CaptureCamera.Capture(target, texture, offset)
    CaptureCamera.CheckMain()

    local matrix = target.cachedTransform.localToWorldMatrix
    local unitsPerPixel = Vector4(matrix.e11, matrix.e21, matrix.e31, matrix.e41).magnitude

    local forward = Vector3(matrix.e13, matrix.e23, matrix.e33)
    local upwards = Vector3(matrix.e12, matrix.e22, matrix.e32)

    local halfHeight = texture.height / 2

    local camera = CaptureCamera._main.cachedCamera
    camera.targetTexture = texture
    camera.orthographicSize = halfHeight * unitsPerPixel
    CaptureCamera._main.cachedTransform.localPosition = target.cachedTransform:TransformPoint(halfHeight * camera.aspect - offset.x, -halfHeight + offset.y, 0)
    CaptureCamera._main.cachedTransform.localRotation = Quaternion.LookRotation(forward, upwards)

    local oldLayer = 0

    if target.graphics ~= nil then
        oldLayer = target.graphics.gameObject.layer
        target.graphics.gameObject.layer = CaptureCamera.layer
    end

    if target:isa(Container) then
        oldLayer = target.numChildren > 0 and target:GetChildAt(1).layer or CaptureCamera.hiddenLayer
        target:SetChildrenLayer(CaptureCamera.layer)
    end

    local old = RenderTexture.active
    RenderTexture.active = texture
    local clearstencil, cleardepth = true, true
    love.graphics.clear(0,0,0,1,clearstencil,cleardepth)
    camera:Render()
    RenderTexture.active = old

    if target.graphics ~= nil then
        target.graphics.gameObject.layer = oldLayer
    end

    if target:isa(Container) then
        target:SetChildrenLayer(oldLayer)
    end
end

local __get = Class.init_get(CaptureCamera)
local __set = Class.init_set(CaptureCamera)

__get.layer = function(self)
    if CaptureCamera._layer == -1 then
        CaptureCamera._layer = LayerMask.NameToLayer(CaptureCamera.LayerName)
        if CaptureCamera._layer == -1 then
            CaptureCamera._layer = 30
            Debug.LogWarn('Please define two layers named ' .. CaptureCamera.LayerName ' and ' .. CaptureCamera.HiddenLayerName)
        end
    end
    return CaptureCamera._layer
end

__get.hiddenLayer = function(self)
    if CaptureCamera._hiddenLayer == -1 then
        CaptureCamera._hiddenLayer = LayerMask.NameToLayer(CaptureCamera.LayerName)
        if CaptureCamera._hiddenLayer == -1 then
            CaptureCamera._hiddenLayer = 31
            Debug.LogWarn('Please define two layers named ' .. CaptureCamera.LayerName ' and ' .. CaptureCamera.HiddenLayerName)
        end
    end
    return CaptureCamera._hiddenLayer
end


FairyGUI.CaptureCamera = CaptureCamera
return CaptureCamera