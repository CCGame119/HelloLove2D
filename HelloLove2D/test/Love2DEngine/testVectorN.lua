--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/8 13:52
--

local Vector2 = Love2DEngine.Vector2
local Vector3 = Love2DEngine.Vector3
local Vector4 = Love2DEngine.Vector4

function Love2DEngine_Cases.Vector2_case()
    math.randomseed(os.time())
    local x, y = math.random(), math.random()
    local vec = Vector2.new(x, y)
    if vec:isa(Vector2) then
        print(tostring(vec))
    end
end

function Love2DEngine_Cases.Vector3_case()
    math.randomseed(os.time())
    local x, y, z = math.random(), math.random(), math.random()
    local vec = Vector3.new(x, y, z)
    if vec:isa(Vector3) then
        print(tostring(vec))
    end
end

function Love2DEngine_Cases.Vector4_case()
    math.randomseed(os.time())
    local x, y, z, w = math.random(), math.random(), math.random(), math.random()
    local vec = Vector4.new(x, y, z, w)
    if vec:isa(Vector4) then
        print(vec.normalized)
        print(tostring(vec))
    end
end

