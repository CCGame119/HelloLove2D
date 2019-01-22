--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 15:09
--

local Class = require('libs.Class')

local Object = Love2DEngine.Object

---@class Love2DEngine.Mesh:Love2DEngine.Object
local Mesh = Class.inheritsFrom('Mesh', nil, Object)

function Mesh:MarkDynamic()
    -- TODO: Mesh:MarkDynamic
end

--TODO: Love2DEngine.Mesh


Love2DEngine.Mesh = Mesh
return Mesh