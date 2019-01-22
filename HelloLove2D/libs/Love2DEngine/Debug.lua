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
    print(string.format('[DEBUG]: %s', msg))
end

---@param msg string
function Debug.LogInfo(msg)
    print(string.format('[INFO]: %s', msg))
end

---@param msg string
function Debug.LogWarn(msg)
    print(string.format('[WARN]: %s', msg))
end

---@param msg string
function Debug.LogError(msg)
    print(string.format('[ERROR]: %s', msg))
end

Debug.Log = Debug.LogInfo

--TODO: Love2DEngine.Debug

Love2DEngine.Debug = Debug
return Debug