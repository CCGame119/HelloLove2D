--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/1 16:06
--

local Class = require('libs.Class')

---@class Love2DEngine.RuntimePlatform:enum
local RuntimePlatform = {
    WindowsPlayer = 2,
    Android = 11,
    IPhonePlayer = 8,
}

---@class Love2DEngine.Application:ClassType
---@field platform Love2DEngine.RuntimePlatform
local Application = Class.inheritsFrom('Application')

--TODO: Love2DEngine.Application

Love2DEngine.RuntimePlatform = RuntimePlatform
Love2DEngine.Application = Application
return Application