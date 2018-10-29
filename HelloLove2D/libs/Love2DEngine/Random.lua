--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/29 13:54
--

local Class = require('libs.Class')

local Vector3 = Love2DEngine.Vector3

---@class Love2DEngine.Random:ClassType
---@field insideUnitSphere Love2DEngine.Vector3
local Random = Class.inheritsFrom('Random')

-- TODO: FairyGUI.Random

local __get = Class.init_get(Random, true)

---@param self   Love2DEngine.Random
__get.insideUnitSphere = function(self)
    local pt = Vector3(math.random(), math.random(), math.random())
    return pt.normalized
end

Love2DEngine.Random = Random
return Random