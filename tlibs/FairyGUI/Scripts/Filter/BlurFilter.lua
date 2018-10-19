--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:58
--

local Class = require('libs.Class')

local Material = Love2DEngine.Material
local RenderTexture = Love2DEngine.RenderTexture
local Graphics = Love2DEngine.Graphics
local Vector2 = Love2DEngine.Vector2
local DisplayOptions = FairyGUI.DisplayOptions
local IFilter = FairyGUI.IFilter
local ShaderConfig = FairyGUI.ShaderConfig

---@class FairyGUI.BlurFilter:FairyGUI.IFilter
---@field public blurSize number
---@field public target FairyGUI.DisplayObject
---@field private _target FairyGUI.DisplayObject
---@field private _blitMaterial Love2DEngine.Material
local BlurFilter = Class.inheritsFrom('BlurFilter', nil, IFilter)

function BlurFilter:__ctor()
    self.blurSize = 1
end

function BlurFilter:Update()
end

---@param source Love2DEngine.RenderTexture
---@param dest Love2DEngine.RenderTexture
---@param iteration number
function BlurFilter:FourTapCone(source, dest, iteration)
    local off = self.blurSize * iteration + 0.5
    Graphics.BlitMultiTap(source, dest, self._blitMaterial,
            Vector2(-off, -off), Vector2(-off, off),
            Vector2(off, off), Vector2(off, -off))
end

---@param source Love2DEngine.RenderTexture
---@param dest Love2DEngine.RenderTexture
function BlurFilter:DownSample4x(source, dest)
    local off = 1
    Graphics.BlitMultiTap(source, dest, self._blitMaterial,
            Vector2(off, off),Vector2(-off, off),
            Vector2(off, off), Vector2(off, -off))
end

function BlurFilter:OnRenderImage()
    if self.blurSize < 0.01 then return end

    local sourceTexture = self._target.paintingGraphics.texture.nativeTexture
    local rtW = sourceTexture.width / 8
    local rtH = sourceTexture.height / 8
    local buffer = RenderTexture.GetTemporary(rtW, rtH, 0)

    self:DownSample4x(sourceTexture, buffer)

    for i = 1, 2 do
        local buffer2 = RenderTexture.GetTemporary(rtW, rtH, 0)
        self:FourTapCone(buffer, buffer2, i)
        RenderTexture.ReleaseTemporary(buffer)
        buffer = buffer2
    end
    Graphics.Blit(buffer, sourceTexture)

    RenderTexture.ReleaseTemporary(buffer)
end

local __get = Class.init_get(BlurFilter)
local __set = Class.init_set(BlurFilter)

---@param self FairyGUI.BlurFilter
__get.target = function(self) return self._target end
---@param self FairyGUI.BlurFilter
---@param val FairyGUI.DisplayObject
__set.target = function(self, val)
    self._target = val
    self._target:EnterPaintingMode(1, nil)
    self._target.onPaint:Add(self.OnRenderImage, self)

    self._blitMaterial = Material.new(ShaderConfig.GetShader("FairyGUI/BlurFilter"))
    self._blitMaterial.hideFlags = DisplayOptions.hideFlags
end

FairyGUI.BlurFilter = BlurFilter
return BlurFilter