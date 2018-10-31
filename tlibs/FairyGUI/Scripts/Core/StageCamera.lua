--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 10:24
--

local Class = require('libs.Class')
local bit = require('bit')
local lshift = bit.lshift

local LuaBehaviour = Love2DEngine.LuaBehaviour
local Transform = Love2DEngine.Transform
local Camera = Love2DEngine.Camera
local CameraClearFlags = Love2DEngine.CameraClearFlags
local Screen = Love2DEngine.Screen
local Vector3 = Love2DEngine.Vector3
local GameObject = Love2DEngine.GameObject
local LayerMask = Love2DEngine.LayerMask

local EMRenderSupport = FairyGUI.EMRenderSupport
local HitTestContext = FairyGUI.HitTestContext


---@class FairyGUI.StageCamera:Love2DEngine.LuaBehaviour
---@field public constantSize boolean
---@field public cachedTransform Love2DEngine.Transform
---@field public cachedCamera Love2DEngine.Camera
---@field private screenWidth number
---@field private screenHeight number
---@field private isMain boolean
local StageCamera = Class.inheritsFrom('StageCamera', {constantSize = true}, LuaBehaviour)

---@type Love2DEngine.Camera
StageCamera.main = nil

StageCamera.screenSizeVer = 1

StageCamera.Name = "Stage Camera"
StageCamera.LayerName = "UI"

StageCamera.DefaultCameraSize = 5
StageCamera.UnitsPerPixel = 0.02

function StageCamera:OnEnable()
    self.cachedTransform = self.transform
    self.cachedCamera = self:GetComponent(Camera)
    if self.gameObject.name == StageCamera.Name then
        self.main = self.cachedCamera
        self.isMain = true
    end
    self:OnScreenSizeChanged()
end

function StageCamera:Update()
    if self.screenWidth ~= Screen.width or self.screenHeight ~= Screen.height then
        self:OnScreenSizeChanged()
    end
end

function StageCamera:OnScreenSizeChanged()
    self.screenWidth = Screen.width
    self.screenHeight = Screen.height
    if self.screenWidth == 0 or self.screenHeight == 0 then
        return
    end

    local upp
    if self.constantSize then
        self.cachedCamera.orthographicSize = StageCamera.DefaultCameraSize
        uppp = self.cachedCamera.orthographicSize * 2 / self.screenHeight
    else
        upp = 0.02
        self.cachedCamera.orthographicSize = self.screenHeight / 2 * StageCamera.UnitsPerPixel
    end
    self.cachedTransform.localPosition =
    Vector3(self.cachedCamera.orthographicSize * self.screenWidth / self.screenHeight, -self.cachedCamera.orthographicSize)

    if self.isMain then
        StageCamera.UnitsPerPixel = upp
        StageCamera.screenSizeVer = StageCamera.screenSizeVer + 1
    end
end

function StageCamera:OnRenderObject()
    if self.isMain then
        EMRenderSupport.Update()
    end
end

function StageCamera:ApplyModifiedProperties()
    self.screenWidth = 0
end

function StageCamera.CheckMainCamera()
    if GameObject.Find(StageCamera.Name) == nil then
        local layer = LayerMask.NameToLayer(StageCamera.LayerName)
        self:CreateCamera(StageCamera.Name, lshift(layer, 1))
    end
    HitTestContext.cachedMainCamera = Camera.main
end

function StageCamera.CheckCaptureCamera()
    if GameObject.Find(StageCamera.Name) == nil then
        local layer = LayerMask.NameToLayer(StageCamera.LayerName)
        self:CreateCamera(StageCamera.Name, lshift(layer, 1))
    end
end

---@param name string
---@param cullingMask number
function StageCamera.CreateCamera(name, cullingMask)
    local cameraObject = GameObject:get(name)
    local camera = cameraObject:AddComponent(Camera)
    camera.depth = 1
    camera.cullingMask = cullingMask
    camera.clearFlags = CameraClearFlags.Depth
    camera.orthographic = true
    camera.orthographicSize = StageCamera.DefaultCameraSize
    camera.nearClipPlane = -30
    camera.farClipPlane = 30
    cameraObject.AddComponent(StageCamera)

    return camera
end


FairyGUI.StageCamera = StageCamera
return StageCamera