--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/18 16:08
--


local Class = require('libs.Class')

---@class Love2DEngine.LayerMask:ClassType
local LayerMask = Class.inheritsFrom('LayerMask')

---@param layerName string
---@return number
function LayerMask.NameToLayer(layerName)
    --TODO: LayerMask.NameToLayer
    return 0
end

--TODO: Love2DEngine.LayerMask

Love2DEngine.LayerMask = LayerMask
return LayerMask