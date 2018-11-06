--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/17 16:01
--

local Class = require('libs.Class')

local LuaBehavior = Love2DEngine.LuaBehaviour
local Event = Love2DEngine.Event
local Stats = FairyGUI.Stats

---@class FairyGUI.StageEngine:Love2DEngine.LuaBehaviour
---@field public ObjectsOnStage number
---@field public GraphicsOnStage number
local StageEngine = Class.inheritsFrom('StageEngine', nil, LuaBehavior)

StageEngine.beingQuit = false

function StageEngine:Start()
    self.useGUILayout = false
end

function StageEngine:LateUpdate()
    FairyGUI.Stage.inst:InternalUpdate()

    self.ObjectsOnStage = Stats.ObjectCount
    self.GraphicsOnStage = Stats.GraphicsCount
end

function StageEngine:OnGUI()
    FairyGUI.Stage.inst:HandleGUIEvents(Event.current)
end

function StageEngine:OnApplicationQuit()
    self.beingQuit = true
end

FairyGUI.StageEngine = StageEngine
return StageEngine