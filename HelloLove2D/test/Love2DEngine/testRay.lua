--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/11 13:25
--
local Ray = Love2DEngine.Ray
local Vecter3 = Love2DEngine.Vector3

function Love2DEngine_Cases.Ray_cases()
    local ori, dir = Vecter3(1,1,1), Vecter3(2,2,3)
    local r = Ray(ori, dir)
    print(tostring(r))
end
