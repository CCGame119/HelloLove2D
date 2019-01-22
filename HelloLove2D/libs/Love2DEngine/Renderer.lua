--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 15:12
--

local Class = require('libs.Class')

local Component = Love2DEngine.Component

---@class Love2DEngine.Renderer:Love2DEngine.Component
local Renderer = Class.inheritsFrom('Renderer', nil, Component)

function Renderer:OnRender()

end

--TODO: Love2DEngine.Renderer

Love2DEngine.Renderer = Renderer
return Renderer