--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 13:51
--

local Class = require('libs.Class')

local Physics = Love2DEngine.Physics

---@class FairyGUI.HitTestContext:ClassType
---@field public screenPoint Love2DEngine.Vector2
---@field public worldPoint Love2DEngine.Vector3
---@field public direction Love2DEngine.Vector3
---@field public forTouch boolean
---@field public layerMask number
---@field public maxDistance number
---@field public cachedMainCamera Love2DEngine.Camera
---@field private raycastHits table<Love2DEngine.Camera, Love2DEngine.Ray>
local HitTestContext = Class.inheritsFrom('HitTestContext')

---========= static member==============
HitTestContext.forTouch = false
HitTestContext.layerMask = -1
HitTestContext.maxDistance = math.huge
HitTestContext.raycastHits = {}

---@param camera Love2DEngine.Camera
---@param hit Love2DEngine.RaycastHit
function HitTestContext.GetRaycastHitFromCache(camera, hit)
    local hitRef = HitTestContext.raycastHits[camera]
    if nil ~= hitRef then
        local ray = camera:ScreenPointToRay(HitTestContext.screenPoint)
        if Physics.Raycast(ray, hit, HitTestContext.maxDistance, HitTestContext.layerMask) then
            HitTestContext.raycastHits[camera] = hit
            return true
        else
            HitTestContext.raycastHits[camera] = nil
            return true
        end
    elseif hitRef == nil then
        hit:Reset()
        return false
    else
        hit:Assign(hitRef)
        return true
    end
end

---@param camera Love2DEngine.Camera
---@param hit Love2DEngine.RaycastHit
function HitTestContext.CacheRaycastHit(camera, hit)
    HitTestContext.raycastHits[camera] = hit
end

function HitTestContext.ClearRaycastHitCache()
    HitTestContext.raycastHits = {}
end


FairyGUI.HitTestContext = HitTestContext
return HitTestContext