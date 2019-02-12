--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2019/1/26 16:40
--

local Class = require('libs.Class')

local GameObject = Love2DEngine.GameObject
local Transform = Love2DEngine.Transform
local MeshRenderer = Love2DEngine.MeshRenderer
local Time = Love2DEngine.Time

---@class Love2DEngine.RenderingPipeLine:ClassType
local RenderingPipeLine = Class('RenderingPipeLine')

function RenderingPipeLine.onDraw()
    Time.frameCount = Time.frameCount + 1
    RenderingPipeLine.__onDrawHierarchy(Transform.root)
end

--- 渲染对象数
---@param transform Love2DEngine.Transform
function RenderingPipeLine.__onDrawHierarchy(transform)
    for i, trans in ipairs(transform.childs) do
        local go = trans.gameObject
        if go.active then
           local renderer = go:GetComponent(MeshRenderer)
            if renderer then
                renderer:OnRender()
            end
        end
        RenderingPipeLine.__onDrawHierarchy(go.transform)
    end
end

Love2DEngine.RenderingPipeLine = RenderingPipeLine
return RenderingPipeLine