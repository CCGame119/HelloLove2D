--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/1 16:41
--

local Class = require('libs.Class')

---@class Love2DEngine.LoadSceneMode:enum
local LoadSceneMode = {
    Single = 0,
    Additive = 1,
}

---@class Love2DEngine.Scene:ClassType
local Scene = Class.inheritsFrom('Scene')

--TODO: Love2DEngine.Scene

Love2DEngine.LoadSceneMode = LoadSceneMode
Love2DEngine.Scene = Scene
return Scene