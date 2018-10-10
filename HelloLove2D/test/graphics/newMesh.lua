--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/28 12:01
--

--[[ 网格用途：
    1. 绘制任意形状
    2. 绘制任意形状的图片： 例如：用于绘制圆形进度条
]]

local Screen = require('libs.Love2DEngine.Devices.Screen')
local graphics = love.graphics

local img_plane = graphics.newImage('assets/textures/plane.png')
local img_w, img_h = img_plane:getWidth(), img_plane:getHeight()

local vertices = {
    {   -- top-left corner (red-tinted)
        0, 0, -- position of the vertex
        0, 0, -- texture coordinate at the vertex position
        1, 0, 0, -- color of the vertex
    },
    {   -- top-right corner (green-tinted)
        img_w, 0,
        1, 0, -- texture coordinates are in the range of [0, 1]
        0, 1, 0
    },
    {   -- bottom-right corner (blue-tinted)
        img_w, img_h,
        1, 1,
        0, 0, 1
    },
    {   -- bottom-left corner (yellow-tinted)
        0, img_h,
        0, 1,
        1, 1, 0
    },
}
-- the Mesh DrawMode "fan" works well for 4-vertex Meshes.
local mesh = graphics.newMesh(vertices, "fan")
mesh:setTexture(img_plane)

local function CreateCircle(segments)
    segments = segments or 360
    local vertices = {}

    -- The first vertex is at the origin (0, 0) and will be the center of the circle.
    table.insert(vertices, {0, 0, 0.5, 0.5})

    local u, v = 0, 0
    -- Create the vertices at the edge of the circle.
    for i=0, segments do
        local angle = (i / 360) * math.pi * 2

        -- Unit-circle.
        local x = math.cos(angle)
        local y = math.sin(angle)
        u, v = 0.5+x/2, 0.5+y/2

        table.insert(vertices, {x, y, u, v})
    end

    -- The "fan" draw mode is perfect for our circle.
    return love.graphics.newMesh(vertices, "fan")
end

local seg = 0
function graphics_case.newMesh_cases()
    local x, y =  mx-img_w/2, my-img_h/2
    graphics.draw(mesh, x, y)

    seg = (seg+1)%360
    local mesh2 = CreateCircle(seg)
    mesh2:setTexture(img_plane)
    local radius = 100
    local mx, my = love.mouse.getPosition()
    love.graphics.draw(mesh2, mx, my, 0, radius, radius)
end