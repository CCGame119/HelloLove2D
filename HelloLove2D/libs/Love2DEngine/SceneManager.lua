--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/1 16:31
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

---@class Love2DEngine.SceneManager.LoveAction:Delegate @fun(scene: Love2DEngine.Scene, mode:Love2DEngine.LoadSceneMode)
local LoveAction = Delegate.newDelegate('LoveAction')

---@class Love2DEngine.SceneManager:ClassType
---@field sceneLoaded Love2DEngine.SceneManager.LoveAction
local SceneManager = Class.inheritsFrom('SceneManager')

--TODO: Love2DEngine.SceneManager

SceneManager.LoveAction = LoveAction
Love2DEngine.SceneManager = SceneManager
return SceneManager