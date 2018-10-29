--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/18 16:06
--

local Class = require('libs.Class')

---@class Love2DEngine.Debug:ClassType
---@field public traceback fun(msg:string):string
local Debug = Class.inheritsFrom('Debug')

---@param msg string
function Debug.LogDebug(msg)
    print(msg)
end

---@param msg string
function Debug.LogInfo(msg)
    print(msg)
end

---@param msg string
function Debug.LogWarn(msg)
    print(msg)
end

---@param msg string
function Debug.LogError(msg)
    print(msg)
end


--TODO: Love2DEngine.Debug

Love2DEngine.Debug = Debug
return Debug