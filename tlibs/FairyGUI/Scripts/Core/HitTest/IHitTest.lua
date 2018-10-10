--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 14:38
--

local Class = require('libs.Class')

---@class FairyGUI.HitTestMode:number
local HitTestMode = {
    Default = 0,
    Raycast =1
}

---@class FairyGUI.IHitTest:ClassType
local IHitTest = Class.inheritsFrom('IHitTest')

---virtual
---@param val boolean
function IHitTest:SetEnabled(val) end

---virtual
---@param container FairyGUI.Container
---@param localPoint Love2DEngine.Vector2
---@return boolean
function IHitTest:HitTest(container, localPoint) end

FairyGUI.HitTestMode = HitTestMode
FairyGUI.IHitTest = IHitTest
return IHitTest