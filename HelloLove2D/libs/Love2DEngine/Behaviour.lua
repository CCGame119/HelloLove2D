--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 14:03
--

local Class = require('libs.Class')

local Component = Love2DEngine.Component

---@class Love2DEngine.Behaviour:Love2DEngine.Component
---@field public enabled boolean
---@field public isActiveAndEnabled boolean
local Behaviour = Class.inheritsFrom('Behaviour',  {
    isActiveAndEnabled = false
}, Component)

function Behaviour:__ctor()
    self.enabled = true
end

Love2DEngine.Behaviour = Behaviour
return Behaviour