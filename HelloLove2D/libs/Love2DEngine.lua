--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 13:34
--

local bit = require('bit')
local bor = bit.bor

---@class Love2DEngine
Love2DEngine = {name = 'Love2DEngine'}

---@class Love2DEngine.RenderMode:number
local RenderMode = {
    ScreenSpaceOverlay = 0,
    ScreenSpaceCamera = 1,
    WorldSpace = 2,
}

---@class Love2DEngine.HideFlags
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

require('libs.Love2DEngine.Vector2')
require('libs.Love2DEngine.Vector3')
require('libs.Love2DEngine.Quaternion')
require('libs.Love2DEngine.Rect')
require('libs.Love2DEngine.Assets')
require('libs.Love2DEngine.Devices.Screen')
require('libs.Love2DEngine.Devices.Input')

Love2DEngine.RenderMode = RenderMode
Love2DEngine.HideFlags = HideFlags
return Love2DEngine