--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 14:02
--

local Class = require('libs.Class')

---@class FairyGUI.Stats:ClassType
local Stats = Class.inheritsFrom('Stats')

Stats.ObjectCount = 0
Stats.GraphicsCount = 0
Stats.LatestObjectCreation = 0
Stats.LatestGraphicsCreation = 0

FairyGUI.Stats = Stats
return  Stats