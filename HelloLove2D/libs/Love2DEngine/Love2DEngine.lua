--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 13:34
--

local bit = require('bit')
local bor = bit.bor

--region Love2DEngine 模块定义
---@class Love2DEngine:namespace
Love2DEngine = {name = 'Love2DEngine'}

---@class Love2DEngine.RenderMode:enum
local RenderMode = {
    ScreenSpaceOverlay = 0,
    ScreenSpaceCamera = 1,
    WorldSpace = 2,
}

---@class Love2DEngine.HideFlags:enum
local HideFlags = {
    None = 0,
    HideInHierarchy = 1,
    HideInInspector = 2,
    DontSaveInEditor = 4,
    NotEditable = 8,
    DontSaveInBuild = 16, -- 0x00000010
    DontUnloadUnusedAsset = 32, -- 0x00000020
}
HideFlags.DontSave = bor(HideFlags.DontUnloadUnusedAsset, HideFlags.DontSaveInBuild, HideFlags.DontSaveInEditor) -- 0x00000034
HideFlags.HideAndDontSave = bor(HideFlags.DontSave, HideFlags.NotEditable, HideFlags.HideInHierarchy) -- 0x0000003D

Love2DEngine.RenderMode = RenderMode
Love2DEngine.HideFlags = HideFlags
--endregion

--region Love2DEngine 模块初始化
require('libs.Love2DEngine.Assets')

require('libs.Love2DEngine.Vector2')
require('libs.Love2DEngine.Vector3')
require('libs.Love2DEngine.Vector4')
require('libs.Love2DEngine.Quaternion')
require('libs.Love2DEngine.Rect')
require('libs.Love2DEngine.Ray')
require('libs.Love2DEngine.Matrix4x4')

require('libs.Love2DEngine.Devices.Screen')
require('libs.Love2DEngine.Devices.Input')

require('libs.Love2DEngine.Rendering.Rendering')
--endregion

return Love2DEngine