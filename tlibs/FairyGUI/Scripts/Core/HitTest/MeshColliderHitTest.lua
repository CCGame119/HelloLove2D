--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 14:35
--

local Class = require('libs.Class')

local RaycastHit = Love2DEngine.RaycastHit
local ColliderHitTest = FairyGUI.ColliderHitTest
local HitTestContext = FairyGUI.HitTestContext

---@class FairyGUI.MeshColliderHitTest:FairyGUI.ColliderHitTest
---@field private width number
---@field private height number
local MeshColliderHitTest = Class.inheritsFrom('MeshColliderHitTest', nil, ColliderHitTest)

---@param collider Love2DEngine.MeshCollider
function MeshColliderHitTest:__ctor(collider)
    self.collider = collider
end

---@param x number
---@param y number
---@param w number
---@param h number
function MeshColliderHitTest:SetArea(x, y, w, h)
    self.width, self.height = w, h
end

---@param container FairyGUI.Container
---@param localPoint Love2DEngine.Vector2
function MeshColliderHitTest:HitTest(container, localPoint)
    local camera = container.GetRenderCamera()

    local hit = RaycastHit.new()
    if not HitTestContext.GetRaycastHitFromCache(camera, hit) then
        return false
    end

    if hit.collider ~= self.collider then
        return false
    end

    localPoint:Set(hit.textureCoord.x * self.width, (1-hit.textureCoord.y) * self.height)
end

---@param camera Love2DEngine.Camera
---@param screenPoint Love2DEngine.Vector3
---@param point Love2DEngine.Vector2
function MeshColliderHitTest:ScreenToLocal(camera, screenPoint, point)
    local ray = camera:ScreenPointToRay(screenPoint)
    local hit = RaycastHit.new()
    if self.collider.Raycast(ray, hit, 100) then
        local point = Vector2(hit.textureCoord.x * self.width, (1 - hit.textureCoord.y) * self.height)
        return true
    end
    return false
end


FairyGUI.MeshColliderHitTest = MeshColliderHitTest
return MeshColliderHitTest