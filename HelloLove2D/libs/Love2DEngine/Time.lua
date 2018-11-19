--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/22 10:46
--

local Class = require('libs.Class')

---@class Love2DEngine.Time:ClassType
---@field public time number
---@field public timeSinceLevelLoad number
---@field public deltaTime number
---@field public fixedTime number
---@field public unscaledTime number
---@field public fixedUnscaledTime number
---@field public unscaledDeltaTime number
---@field public fixedUnscaledDeltaTime number
---@field public fixedDeltaTime number
---@field public timeScale number
---@field public frameCount number
---@field public realtimeSinceStartup number
local Time = Class.inheritsFrom('Time')

--TODO: Love2DEngine.Time

Love2DEngine.Time = Time
return Time