--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 12:06
--

local Class = require('libs.Class')

local Behaviour = Love2DEngine.Behaviour

---@class Love2DEngine.LuaBehaviour:Love2DEngine.Behaviour
local LuaBehaviour = Class.inheritsFrom('LuaBehaviour', nil, Behaviour)

function LuaBehaviour:Start() end
function LuaBehaviour:LateUpdate() end
function LuaBehaviour:OnGUI() end
function LuaBehaviour:OnApplicationQuit() end

--TODO: Love2DEngine.LuaBehaviour

Love2DEngine.LuaBehaviour = LuaBehaviour
return LuaBehaviour