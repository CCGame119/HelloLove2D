--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:57
--

local Class = require('libs.Class')

local Matrix4x4 = Love2DEngine.Matrix4x4
local Vector4 = Love2DEngine.Vector4
local Material = Love2DEngine.Matrix4x4
local IFilter = FairyGUI.IFilter
local DisplayObject = FairyGUI.DisplayObject
local Image = FairyGUI.Image
local MovieClip = FairyGUI.MovieClip
local ShaderConfig = FairyGUI.ShaderConfig
local DisplayOptions = FairyGUI.DisplayOptions

---@class FairyGUI.ColorFilter:FairyGUI.IFilter
---@field public target FairyGUI.DisplayObject
---@field private _target FairyGUI.DisplayObject
---@field private _matrix number[]
---@field private _shaderMatrix Love2DEngine.Matrix4x4
---@field private _offset Love2DEngine.Vector4
---@field private _material Love2DEngine.Material
---@field private _savedMaterial Love2DEngine.Material
local ColorFilter = Class.inheritsFrom('ColorFilter', nil, IFilter)

ColorFilter.LUMA_R = 0.299
ColorFilter.LUMA_G = 0.587
ColorFilter.LUMA_B = 0.114

---@type number[]
ColorFilter.IDENTITY = { 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0 }
---@type string[]
ColorFilter.FILTER_KEY = { "COLOR_FILTER" }

function ColorFilter.__ctor()
    self._matrix = {}
    table.copy_l(ColorFilter.IDENTITY, self._matrix)
end

function ColorFilter:Dispose()
    if self._target:isa(Image) or self._target:isa(MovieClip) then
        self._target.graphics.materialKeywords = nil
    elseif not self._target.isDisposed then
        --恢复原来的材质
        self._target.paintingGraphics.material = self._savedMaterial
        self._target:LeavePaintingMode(1)
    end

    if self._material ~= nil then
        Material.Destroy(self._material)
    end

    self._savedMaterial = nil
    self._material = nil
    self._target = nil
end

function ColorFilter:Update()
    local mat = nil
    if self._target:isa(Image) or self._target:isa(MovieClip) then
        mat = self._target.graphics.material
    else
        mat = self._material
    end

    if mat ~= nil then
        mat:SetMatrix("_ColorMatrix", self._shaderMatrix)
        mat:SetVector("_ColorOffset", self._offset)
    end
end

function ColorFilter:Invert()
    self:ConcatValues(
            -1, 0, 0, 0, 1,
            0, -1, 0, 0, 1,
            0, 0, -1, 0, 1,
            0, 0, 0, 1, 0)
end

---@param sat number
function ColorFilter:AdjustSaturation(sat)
    sat = sat + 1

    local invSat = 1 - sat
    local invLumR = invSat * ColorFilter.LUMA_R
    local invLumG = invSat * ColorFilter.LUMA_G
    local invLumB = invSat * ColorFilter.LUMA_B

    self:ConcatValues(
            (invLumR + sat), invLumG, invLumB, 0, 0,
            invLumR, (invLumG + sat), invLumB, 0, 0,
            invLumR, invLumG, (invLumB + sat), 0, 0,
            0, 0, 0, 1, 0)
end

---@param value number
function ColorFilter:AdjustContrast(value)
    local s = value + 1
    local o = 128 / 255 * (1 - s)

    self:ConcatValues(
            s, 0, 0, 0, o,
            0, s, 0, 0, o,
            0, 0, s, 0, o,
            0, 0, 0, 1, 0)
end

---@param value number
function ColorFilter:AdjustBrightness(value)
    self:ConcatValues(
            1, 0, 0, 0, value,
            0, 1, 0, 0, value,
            0, 0, 1, 0, value,
            0, 0, 0, 1, 0)
end

---@param value number
function ColorFilter:AdjustHue(value)
    value = value * math.pi

    local cos = math.cos(value)
    local sin = math.sin(value)

    local LUMA_R =ColorFilter.LUMA_R
    local LUMA_G =ColorFilter.LUMA_G
    local LUMA_B =ColorFilter.LUMA_B

    self:ConcatValues(
    ((LUMA_R + (cos * (1 - LUMA_R))) + (sin * -(LUMA_R))), ((LUMA_G + (cos * -(LUMA_G))) + (sin * -(LUMA_G))), ((LUMA_B + (cos * -(LUMA_B))) + (sin * (1 - LUMA_B))), 0, 0,
    ((LUMA_R + (cos * -(LUMA_R))) + (sin * 0.143)), ((LUMA_G + (cos * (1 - LUMA_G))) + (sin * 0.14)), ((LUMA_B + (cos * -(LUMA_B))) + (sin * -0.283)), 0, 0,
    ((LUMA_R + (cos * -(LUMA_R))) + (sin * -((1 - LUMA_R)))), ((LUMA_G + (cos * -(LUMA_G))) + (sin * LUMA_G)), ((LUMA_B + (cos * (1 - LUMA_B))) + (sin * LUMA_B)), 0, 0,
    0, 0, 0, 1, 0)
end

---@param color Love2DEngine.Color
---@param amount number
function ColorFilter:Tint(color, amount)
    local q = 1 - amount

    local rA = amount * color.r
    local gA = amount * color.g
    local bA = amount * color.b

    local LUMA_R =ColorFilter.LUMA_R
    local LUMA_G =ColorFilter.LUMA_G
    local LUMA_B =ColorFilter.LUMA_B

    self:ConcatValues(
            q + rA * LUMA_R, rA * LUMA_G, rA * LUMA_B, 0, 0,
            gA * LUMA_R, q + gA * LUMA_G, gA * LUMA_B, 0, 0,
            bA * LUMA_R, bA * LUMA_G, q + bA * LUMA_B, 0, 0,
            0, 0, 0, 1, 0)
end

function ColorFilter:Reset()
    table.copy_l(ColorFilter.IDENTITY, self._matrix)

    self:UpdateMatrix()
end

function ColorFilter:ConcatValues(...)
    ---@type number[]
    local values = {...}
    local i = 0
    ---@type number[]
    local tmp = {}
    for y = 1, 4 do
        for x = 1, 5 do
            tmp[i + x] = values[i] * self._matrix[x] +
                    values[i + 1] * self._matrix[x + 5] +
                    values[i + 2] * self._matrix[x + 10] +
                    values[i + 3] * self._matrix[x + 15] +
                    (x == 5 and values[i + 4] or 0)
        end
        i = i + 5
    end
    table.copy_l(tmp, self._matrix)

    self:UpdateMatrix()
end

function ColorFilter:UpdateMatrix()
    self._shaderMatrix:SetRow(1, Vector4(self._matrix[1], self._matrix[2], self._matrix[3], self._matrix[4]))
    self._shaderMatrix:SetRow(2, Vector4(self._matrix[6], self._matrix[7], self._matrix[8], self._matrix[9]))
    self._shaderMatrix:SetRow(3, Vector4(self._matrix[11], self._matrix[12], self._matrix[13], self._matrix[14]))
    self._shaderMatrix:SetRow(4, Vector4(self._matrix[16], self._matrix[17], self._matrix[18], self._matrix[19]))
    self._offset = Vector4(self._matrix[5], self._matrix[10], self._matrix[15], self._matrix[20])
end

local __get = Class.init_get(ColorFilter)
local __set = Class.init_set(ColorFilter)

---@param self FairyGUI.ColorFilter
__get.target = function(self) return self._target end

---@param self FairyGUI.ColorFilter
---@param val FairyGUI.DisplayObject
__set.target = function(self, val)
    self._target = val
    --这里做一个优化，如果对象是图片或者动画，则通过直接修改目标的材质完成滤镜功能
    if self._target:isa(Image) or self._target:isa(MovieClip) then
        self._target.graphics.materialKeywords = ColorFilter.FILTER_KEY
    else -- 否则通过绘画模式，需要建立一张RT，所以会有一定消耗
        if self._material == nil then
            self._material = Material.new(ShaderConfig.GetShader(ShaderConfig.imageShader))
            self._material.hideFlags = DisplayOptions.hideFlags
            self._material:EnableKeyword(ColorFilter.FILTER_KEY[0])
        end
        self._target:EnterPaintingMode(1, nil)
        self._savedMaterial = self._target.paintingGraphics.material --保存原来的材质
        self._target.paintingGraphics.material = self._material --设置后材质的所有权已转移到paintingGraphics
    end
end

FairyGUI.ColorFilter = ColorFilter
return ColorFilter