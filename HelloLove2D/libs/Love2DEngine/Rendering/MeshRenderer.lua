--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 15:11
--

local Class = require('libs.Class')

local graphics = love.graphics

local Renderer = Love2DEngine.Renderer

---@class Love2DEngine.MeshRenderer:Love2DEngine.Renderer
local MeshRenderer = Class.inheritsFrom('MeshRenderer', nil, Renderer)

function MeshRenderer:OnRender()
    local go = self._gameObject
    local transform = go.transform
    if go and transform then
        local pos = transform.position
        --graphics.draw(self.img, pos.x, pos.y)
    end
end

--TODO: Love2DEngine.MeshRenderer

Love2DEngine.MeshRenderer = MeshRenderer
return MeshRenderer