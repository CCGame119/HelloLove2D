--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 14:22
--

local Class = require('libs.Class')

local NativeBlendMode = Love2DEngine.Rendering.BlendMode

---@class FairyGUI.BlendMode:number
local BlendMode =  {
    Normal = 0,
    None = 1,
    Add = 2,
    Multiply = 3,
    Screen = 4,
    Erase = 5,
    Mask = 6,
    Below = 7,
    Off = 8,
    Custom1 = 9,
    Custom2 = 10,
    Custom3 = 11
}

---@class FairyGUI.BlendModeUtils.BlendFactor:ClassType
local BlendFactor = Class.inheritsFrom('BlendFactor')

---@param srcFactor Love2DEngine.Rendering.BlendMode
---@param dstFactor Love2DEngine.Rendering.BlendMode
---@param pma boolean
function BlendFactor:__ctor(srcFactor, dstFactor, pma)
    self.srcFactor = srcFactor
    self.dstFactor = dstFactor
    self.pma = pma or false
end


---@class FairyGUI.BlendModeUtils:ClassType
local BlendModeUtils = Class.inheritsFrom('BlendModeUtils')

---@type FairyGUI.BlendModeUtils.BlendFactor[]
BlendModeUtils.Factors = {
    --Normal
    BlendFactor.new(NativeBlendMode.SrcAlpha, NativeBlendMode.OneMinusSrcAlpha),
    --None
    BlendFactor.new(NativeBlendMode.One, NativeBlendMode.One),
    --Add
    BlendFactor.new(NativeBlendMode.SrcAlpha, NativeBlendMode.One),
    --Multiply
    BlendFactor.new(NativeBlendMode.DstColor, NativeBlendMode.OneMinusSrcAlpha, true),
    --Screen
    BlendFactor.new(NativeBlendMode.One, NativeBlendMode.OneMinusSrcColor, true),
    --Erase
    BlendFactor.new(NativeBlendMode.Zero, NativeBlendMode.OneMinusSrcAlpha),
    --Mask
    BlendFactor.new(NativeBlendMode.Zero, NativeBlendMode.SrcAlpha),
    --Below
    BlendFactor.new(NativeBlendMode.OneMinusDstAlpha, NativeBlendMode.DstAlpha),
    --Off
    BlendFactor.new(NativeBlendMode.One, NativeBlendMode.Zero),
    --Custom1
    BlendFactor.new(NativeBlendMode.SrcAlpha, NativeBlendMode.OneMinusSrcAlpha),
    --Custom2
    BlendFactor.new(NativeBlendMode.SrcAlpha, NativeBlendMode.OneMinusSrcAlpha),
    --Custom3
    BlendFactor.new(NativeBlendMode.SrcAlpha, NativeBlendMode.OneMinusSrcAlpha)
}

---@param mat Love2DEngine.Material
---@param blendMode FairyGUI.BlendMode
function BlendModeUtils.Apply(mat, blendMode)
    local bf = BlendModeUtils.Factors[blendMode]
    mat:SetFloat('_BlendSrcFactor', bf.srcFactor)
    mat:SetFloat('_BlendDstFactor', bf.dstFactor)

    if bf.pma then
        mat:SetFloat('_ColorOption', 1)
    end
end

FairyGUI.BlendMode = BlendMode
BlendModeUtils.BlendFactor = BlendFactor
FairyGUI.BlendModeUtils = BlendModeUtils
return BlendMode, BlendModeUtils