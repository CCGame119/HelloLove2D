--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/18 11:51
--

local Matrix4x4 = Love2DEngine.Matrix4x4

function Love2DEngine_Cases.Matrix4x4_case()
    local mat = Matrix4x4.identity
    print(tostring(mat))
    mat.e11 = 4
    mat.e22 = 8
    mat.e44 = 2
    mat.e34 = 5
    local rmat = Matrix4x4.Inverse(mat)
    print(tostring(mat))
    print(tostring(rmat))
end