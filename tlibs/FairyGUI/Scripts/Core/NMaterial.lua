--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 16:46
--

local Class = require('libs.Class')

local Shader = Love2DEngine.Shader
local Material = Love2DEngine.Material
local BlendMode = FairyGUI.BlendMode

---@class FairyGUI.NMaterial:ClassType
---@field public frameId number
---@field public clipId number
---@field public stencilSet boolean
---@field public blendMode FairyGUI.BlendMode
---@field public combined boolean
---@field public material Love2DEngine.Material
local NMaterial = Class.inheritsFrom('NMaterial',
        {frameId=0, clipId=0, stencilSet=false, blendMode=BlendMode.Normal, combined=false})

---@param shader Love2DEngine.Shader
function NMaterial:__ctor(shader)
    self.material = Material.new(shader)
end

FairyGUI.NMaterial = NMaterial
return NMaterial