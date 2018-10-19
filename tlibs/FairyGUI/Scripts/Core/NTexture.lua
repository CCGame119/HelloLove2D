--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 15:20
--

local Class = require('libs.Class')

local Rect = Love2DEngine.Rect
local Texture = Love2DEngine.Texture
local Texture2D = Love2DEngine.Texture2D
local TextureFormat = Love2DEngine.TextureFormat
local DisplayOptions = FairyGUI.DisplayOptions
local Color = Love2DEngine.Color
local Rect = Love2DEngine.Rect
local Object = Love2DEngine.Object
local Assets = Love2DEngine.Assets

local ShaderConfig = FairyGUI.ShaderConfig
local MaterialManager = FairyGUI.MaterialManager

local error = error
local setmetatable = setmetatable

---@class FairyGUI.DestroyMethod:enum
local DestroyMethod = { Destroy = 0, Unload = 1, None = 2 }

---@class FairyGUI.NTexture:ClassType
---@field public uvRect Love2DEngine.Rect
---@field public rotated boolean
---@field public refCount number
---@field public lastActive number
---@field public destroyMethod FairyGUI.DestroyMethod
---@field public width number
---@field public height number
---@field public root FairyGUI.NTexture
---@field public disposed boolean
---@field public nativeTexture Love2DEngine.Texture
---@field public alphaTexture Love2DEngine.Texture
---@field public Empty boolean
---@field private _nativeTexture Love2DEngine.Texture
---@field private _alphaTexture Love2DEngine.Texture
---@field private _region Love2DEngine.Rect
---@field private _root FairyGUI.NTexture
---@field private _materialManagers table<string, FairyGUI.MaterialManager>
local NTexture = Class.inheritsFrom('NTexture')

---@type FairyGUI.NTexture
NTexture._empty = nil
---@type number
NTexture._gCounter = 0

---@param texture Love2DEngine.Texture|FairyGUI.NTexture
---@param alphaTexture_or_region Love2DEngine.Texture|Love2DEngine.Rect
---@param xSclae_or_rotated number|boolean
---@param yScale number
function NTexture:__ctor(texture_or_root, alphaTexture_or_region, xSclae_or_rotated, yScale)
    if Class.isa(texture_or_root, NTexture) then
        local root = texture_or_root
        local region = alphaTexture_or_region
        self._root = root
        self.rotated = xSclae_or_rotated
        region.x = region.x + root._region.x
        region.y = region.y + root._region.y
        self.uvRect = Rect(region.x * root.uvRect.width / root.width, 1 - region.yMax * root.uvRect.height / root.height,
            region.width * root.uvRect.width / root.width, region.height * root.uvRect.height / root.height)
        if (rotated) then
            local tmp = region.width
            region.width = region.height
            region.height = tmp
            tmp = self.uvRect.width
            self.uvRect.width = self.uvRect.height
            self.uvRect.height = tmp
        end
        self._region = region

        return
    end

    local texture = texture_or_root
    self._root = self
    self._nativeTexture = texture
    if Class.isa(alphaTexture_or_region, Rect) then
        local region = alphaTexture_or_region
        self._region = region
        self.uvRect = Rect(region.x / self._nativeTexture.width, 1 - region.yMax / self._nativeTexture.height,
                region.width / self._nativeTexture.width, region.height / self._nativeTexture.height)
    else
        self._alphaTexture = alphaTexture_or_region or nil
        self.uvRect = Rect(0, 0, xSclae_or_rotated or 1, yScale or 1)
        self._region = Rect(0, 0, texture_or_root.width, texture_or_root.height)
    end
end

---@return Love2DEngine.Texture2D
function NTexture.CreateEmptyTexture()
    local emptyTexture = Texture2D.new(1, 1, TextureFormat.RGB24, false)
    emptyTexture.name = 'White Texture'
    emptyTexture.hideFlags = DisplayOptions.hideFlags
    emptyTexture:SetPixel(0, 0, Color.white)
    emptyTexture:Apply()
    return emptyTexture
end

function NTexture.DisposeEmpty()
    if NTexture._empty ~= nil then
        local tmp = NTexture._empty
        NTexture._empty = nil
        tmp:Dispse()
    end
end

---@param shaderName string
---@param keywords string[]
---@return FairyGUI.MaterialManager
function NTexture:GetMaterialManager(shaderName, keywords)
    if self._root ~= self then
        return self._root:GetMaterialManager(shaderName, keywords)
    end

    if self._materialManagers == nil then
        self._materialManagers = {}
    end

    local key = shaderName
    if keywords ~= nil then
        --对于带指定关键字的，目前的设计是不参加共享材质了，因为逻辑会变得更复杂
        NTexture._gCounter = NTexture._gCounter + 1
        key = shaderName .. '_' .. NTexture._gCounter
    end

    local mm = self._materialManagers[key]
    if nil == mm then
        mm = MaterialManager.new(self, ShaderConfig.GetShader(shaderName), keywords)
        mm._managerKey = key
        table.insert(self._materialManagers, mm)
    end
    return mm
end

---@param manager FairyGUI.MaterialManager
function NTexture:DestroyMaterialManager(manager)
    for i, v in ipairs(self._materialManagers) do
        if v == manager then
            table.remove(self._materialManagers, i)
            break
        end
    end
    manager:DestoryMaterials()
end

---@param destroyMaterial boolean
function NTexture:Unload(destroyMaterial)
    local destroyMaterial = destroyMaterial or false
    if self == NTexture._empty then
        return
    end

    if self._root ~= self then
        error("Unload is not allow to call on none root NTexture.")
    end

    if self._nativeTexture ~= nil then
        if self.destroyMethod == DestroyMethod.Destroy then
            Object.DestroyImmediate(self._nativeTexture, true)
            if self._alphaTexture ~= nil then
                Object.DestroyImmediate(self._alphaTexture, true)
            end
        elseif destroyMethod == DestroyMethod.Unload then
            Assets.UnloadAsset(self._nativeTexture)
            if self._alphaTexture ~= nil then
                Assets.UnloadAsset(self._alphaTexture)
            end
        end

        self._nativeTexture = nil
        self._alphaTexture = nil

        if destroyMaterial then
            self:DestroyMaterial()
        else
            self:RefreshMaterial()
        end
    end
end

---@param nativeTexture Love2DEngine.Texture
---@param alphaTexture Love2DEngine.Texture
function NTexture:Reload(nativeTexture, alphaTexture)
    if self._root ~= self then
        error("Reload is not allow to call on none root NTexture.")
    end

    self._nativeTexture = nativeTexture
    self._alphaTexture = alphaTexture

    self:RefreshMaterial()
end

function NTexture:RefreshMaterial()
    if self._materialManagers ~= nil and #self._materialManagers > 0 then
        for i, v in ipairs(self._materialManagers) do
            v:RefreshMaterial()
        end
    end
end

function NTexture:DestroyMaterial()
    if self._materialManagers ~= nil and #self._materialManagers > 0 then
        for i, v in ipairs(self._materialManagers) do
            v:DestroyMaterial()
        end
    end
end

function NTexture:Dispose()
    if self == NTexture._empty then
        return
    end

    if self._root == self then
        self:Unload(true)
    end
    self._root = nil
end

NTexture.__call = function(t, texture_or_root, alphaTexture_or_region, xSclae_or_rotated, yScale)
    return NTexture.new(texture_or_root, alphaTexture_or_region, xSclae_or_rotated, yScale)
end

local __get = Class.init_get(NTexture, true)

__get.Empty = function(self)
    if NTexture._empty == nil then
        NTexture._empty = NTexture.new(NTexture.CreateEmptyTexture())
    end
    return NTexture._empty
end

__get.width = function(self) return self._region.width end
__get.height = function(self) return self._region.height end
__get.root = function(self) return self._root end
__get.disposed = function(self) return self._root == nil end
__get.nativeTexture = function(self) return (self._root ~= nil and self._root._nativeTexture or nil) end
__get.alphaTexture = function(self) return (self._root ~= nil and self._root._alphaTexture or nil) end

FairyGUI.DestroyMethod = DestroyMethod
FairyGUI.NTexture = NTexture
setmetatable(NTexture, NTexture)
return NTexture