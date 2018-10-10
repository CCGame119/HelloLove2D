--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 13:51
--

local Class = require('libs.Class')

---@class FairyGUI.HitTestContext:ClassType
---@field forTouch boolean
---@field screenPoint Love2DEngine.Vector2
---@field worldPoint Love2DEngine.Vector3
---@field direction Love2DEngine.Vector3
local HitTestContext = Class.inheritsFrom('HitTestContext')

--TODO: FairyGUI.HitTestContext

FairyGUI.HitTestContext = HitTestContext
return HitTestContext