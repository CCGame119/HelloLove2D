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
local Time = Class.inheritsFrom('Time', {
    timeSinceLevelLoad = 0,
    fixedTime = 0,
    fixedUnscaledTime = 0,
    fixedUnscaledDeltaTime = 0,
    fixedDeltaTime = 0,
    frameCount = 0,
    realtimeSinceStartup = 0,
})

local __get = Class.init_get(Time, true)

__get.deltaTime = function(self)
    return love.timer.getDelta()
end

__get.deltaTime = function(self)
    return love.timer.getDelta()
end

__get.unscaledDeltaTime = function(self)
    return love.timer.getDelta()
end

__get.time = function(self)
    return love.timer.getTime()
end

__get.time = function(self)
    return love.timer.getTime()
end

__get.timeScale = function(self)
    return love.timer.getTime()
end

__get.unscaledTime = function(self)
    return love.timer.getTime()
end

Love2DEngine.Time = Time
setmetatable(Time, Time)
return Time