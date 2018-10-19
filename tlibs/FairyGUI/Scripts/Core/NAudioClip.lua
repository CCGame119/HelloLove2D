--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:29
--

local Class = require('libs.Class')

local AudioClip = Love2DEngine.AudioClip
local Assets = Love2DEngine.Assets
local Object = Love2DEngine.Object
local DestroyMethod = FairyGUI.DestroyMethod

---@class FairyGUI.NAudioClip:ClassType
---@field public destroyMethod FairyGUI.DestroyMethod
---@field public nativeClip Love2DEngine.AudioClip
local NAudioClip = Class.inheritsFrom('NAudioClip')

---@param audioClip Love2DEngine.AudioClip
function NAudioClip:__ctor(audioClip)
    self.nativeClip = audioClip
end

function NAudioClip:Unload()
    if self.nativeClip == nil then return end

    if self.destroyMethod == DestroyMethod.Unload then
        Assets.UnloadAsset(self.nativeClip)
    elseif self.destroyMethod == DestroyMethod.Destroy then
        Object.DestroyImmediate(self.nativeClip, true)
    end

    self.nativeClip = nil
end

function NAudioClip:Reload(audioClip)
    self.nativeClip = audioClip
end

FairyGUI.NAudioClip = NAudioClip
return NAudioClip