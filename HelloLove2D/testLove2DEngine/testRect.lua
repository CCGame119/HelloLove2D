--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 16:47
--

require('libs.Love2DEngine')

local Rect = Love2DEngine.Rect
local Vector2 = Love2DEngine.Vector2

function Rect_tostring()
    local rc = Rect.zero
    print(tostring(rc))
    local v = Vector2.zero
    print(tostring(v))
end
