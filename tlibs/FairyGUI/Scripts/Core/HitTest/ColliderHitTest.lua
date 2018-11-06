--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 14:37
--

local Class = require('libs.Class')

local RaycastHit = Love2DEngine.RaycastHit
local IHitTest = FairyGUI.IHitTest
local HitTestContext = FairyGUI.HitTestContext

---@class FairyGUI.ColliderHitTest:FairyGUI.IHitTest
---@field public collider Love2DEngine.Collider
local ColliderHitTest = Class.inheritsFrom('ColliderHitTest', nil, IHitTest)

---virtual
---@param x number
---@param y number
---@param w number
---@param h number
function ColliderHitTest:SetArea(x, y, w, h) end

---@param val boolean
function ColliderHitTest:SetEnabled(val)
    self.collider.enabled = val
end

---@param container FairyGUI.Container
---@param localPoint Love2DEngine.Vector2
function ColliderHitTest:HitTest(container, localPoint)
    local camera = container:GetRenderCamera()
    local hit = RaycastHit()
    if not HitTestContext.GetRaycastHitFromCache(camera, hit) then
        return false
    end

    if hit.collider ~= self.collider then
        return false
    end

    local pos = container:GetHitTestLocalPoint()
    localPoint:Set(pos.x, pos.y)
    return true
end

FairyGUI.ColliderHitTest = ColliderHitTest
return ColliderHitTest