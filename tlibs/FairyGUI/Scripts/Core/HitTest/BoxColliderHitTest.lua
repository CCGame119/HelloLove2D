--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 18:38
--

local Class = require('libs.Class')

local Vector3 = Love2DEngine.Vector3
local BoxCollider = Love2DEngine.BoxCollider
local ColliderHitTest = FairyGUI.ColliderHitTest

---@class FairyGUI.BoxColliderHitTest:FairyGUI.ColliderHitTest
local BoxColliderHitTest = Class.inheritsFrom('BoxColliderHitTest', nil, ColliderHitTest)

---@param collider Love2DEngine.BoxCollider
function BoxColliderHitTest.__ctor(collider)
    self.collider = collider
end

---@param x number
---@param y number
---@param w number
---@param h number
function BoxColliderHitTest:SetArea(x, y, w, h)
    self.collider.center = Vector3(x + w / 2, -y - h / 2)
    self.collider.size = Vector3(w, h, 0)
end

FairyGUI.BoxColliderHitTest = BoxColliderHitTest
return BoxColliderHitTest