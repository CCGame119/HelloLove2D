--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/27 11:19
--
require('libs.utils.table_ex')
local Screen = require('libs.Love2DEngine.Devices.Screen')
local graphics = love.graphics


local img_plane = graphics.newImage('assets/textures/plane.png')
local img_w, img_h = img_plane:getWidth(), img_plane:getHeight()
local quad = love.graphics.newQuad(0, 0, img_w/2, img_h/2, img_w, img_h)
local sprites = {'assets/textures/plane.png', 'assets/textures/enemy.png'}
local img_arr = graphics.newArrayImage(sprites)

---@class graphics_case @love.graphics 测试用例
graphics_case = {}
graphics_case.fonts = {STLITI=love.graphics.newFont("assets/fonts/STLITI.TTF", 30)}

function graphics_case.arc_cases()
    graphics.setColor( 1, 1, 0 )
    local x, y = Screen.pos(0.2, 0.2)
    local r, a1, a2 = 100, 0, math.pi*3/4

    graphics.arc("line", x, y, r, a1, a2)
    graphics.arc("line", x+2*r, y, r, a1, a2, 2)
    graphics.arc("fill", x+4*r, y, r, a1, a2)
    graphics.arc("line", "open", x, y+2*r, r, a1, a2)
    graphics.arc("line", "closed", x+2*r, y+2*r, r, a1, a2, 2)

    graphics.setColor( 1, 1, 1)
end


function graphics_case.circle_cases()
    graphics.setColor( 1, 0, 1 )
    local x, y = Screen.pos(0.2, 0.2)
    local r, a1, a2 = 100, 0, math.pi*3/4

    graphics.circle("line", x, y, r)
    graphics.circle("line", x+2*r, y, r, 4)
    graphics.circle("fill", x+4*r, y, r)

    graphics.setColor( 1, 1, 1)
end

function graphics_case.clear_cases()
    local r,g,b,a = 0,1,0,0.1
    local clearstencil, cleardepth = true, true
    graphics.clear(r,g,b,a,clearstencil,cleardepth)
end

function graphics_case.draw_cases()
    local x, y = Screen.pos(0.2, 0.2)
    local r = 0
    local sx, sy = 1, 1
    local ox, oy = img_w / 2, img_h / 2
    local kx, ky = 0, 0

    graphics.draw(img_plane, x, y, r, sx, sy, ox, oy, kx, ky)
    graphics.draw(img_plane, x, y, r, sx, sy, ox, oy, 0, ky)
    graphics.draw(img_plane, x*2, y, r, -sx, -sy , ox, oy, kx, ky)
    graphics.draw(img_plane, quad, x*3, y, r, sx, sy , ox, oy, kx, ky)
end

function graphics_case.drawInstanced_cases()

end

function graphics_case.drawLayer_cases()
    local x, y = Screen.pos(0.2, 0.2)
    local r = 0
    local sx, sy = 1, 1
    local ox, oy = 0, 0
    local kx, ky = 0, 0

    graphics.drawLayer(img_arr, 1, x, y, r, sx, sy, ox, oy, kx, ky)
    graphics.drawLayer(img_arr, 2, x, y+img_h, r, sx, sy, ox, oy, kx, ky)
end

function graphics_case.ellipse_cases()
    local mode = 'fill'
    local x, y = Screen.pos(0.2, 0.2)
    local rx, ry = 30, 40
    graphics.ellipse(mode, x, y, rx, ry)
    graphics.ellipse('line', x, y+2*ry, rx, ry)
end

function graphics_case.line_cases()
    local points = {30, 30, 90, 30,
                    90, 90, 30, 90,
                    30, 150, 90, 150}
    graphics.line(points)
end

function graphics_case.points_cases()
    local points = {30, 30, 90, 30,
                    90, 90, 30, 90,
                    30, 150, 90, 150}
    graphics.setPointSize(10)
    graphics.points(points)
end

function graphics_case.polygon_cases()
    local mode = 'fill'
    local vertices = {100, 100, 200, 100, 150, 200}
    graphics.polygon(mode, vertices)
end

function graphics_case.print_cases()
    local x, y, r = 10, 200, 0
    graphics.setColor(0, 1, 0, 1)
    graphics.print("This is a pretty lame example.", x, y)
    graphics.setColor(1, 0, 0, 1)
    x, y = 10, 250
    graphics.print("This lame example is twice as big.", x, y, r, 2, 2)
    graphics.setColor(0, 0, 1, 1)
    x, y, r = Screen.w, 0, math.pi/2
    graphics.print("This example is lamely vertical.", x, y, r, 2, 2)
    graphics.setColor(1,1,1,1)
end

function graphics_case.printf_cases()
    local x, y, limit = 25, 25, 125
    graphics.printf("This text is aligned right, and wraps when it gets too big.", x, y, limit, "right")
    x, y, limit = 100, 100, 200
    graphics.printf("This text is aligned center", x, y, limit,"center") -- center your text around x = 200/2 + 100 = 200
    x, y, limit = 100, 200, 200
    graphics.printf("This text is aligned right", x, y, limit,"right") -- align right to x = 100 + 200 = 300
end

function graphics_case.rectangle_cases()
    local mode = 'fill'
    local x, y, w, h = 40, 40, 100, 100
    graphics.rectangle(mode, x, y, w, h)
    local seg = 10
    graphics.rectangle(mode, x + 2*w, y, w, h, seg)
    graphics.rectangle(mode, x + 4*w, y, w, h, 5)
end

local mask = img_plane
local mask_shader = love.graphics.newShader[[
   vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      if (Texel(texture, texture_coords).a == 0) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }
      return vec4(1.0);
   }
]]
local function myStencilFunction()
    graphics.rectangle("fill", 225, 200, 350, 300)
end
local function myStencilFunction()
    love.graphics.setShader(mask_shader)
    love.graphics.draw(mask, 225, 200)
    love.graphics.setShader()
end
function graphics_case.stencil_cases()
    local keepvalues = false
    -- draw a rectangle as a stencil. Each pixel touched by the rectangle will have its stencil value set to 1. The rest will be 0.
    graphics.stencil(myStencilFunction, "replace", 1, false)

    graphics.setStencilTest("greater", 0)

    graphics.setColor(1, 0, 0, 0.45)
    graphics.circle("fill", 300, 300, 150, 50)

    graphics.setColor(0, 1, 0, 0.45)
    graphics.circle("fill", 500, 300, 150, 50)

    graphics.setColor(0, 0, 1, 0.45)
    graphics.circle("fill", 400, 400, 150, 50)

    graphics.setStencilTest()

    graphics.setColor(1,1,1,1)
end

function graphics_case.captureScreenshot_cases()
    love.graphics.captureScreenshot(os.date("screenshot_%Y%m%d%H%M%S.png", os.time()))
end

function graphics_case.newFont_cases()
    local oldFont = graphics.getFont()
    graphics.setFont(graphics_case.fonts.STLITI)
    graphics.print('你好，这是华文隶书！', 100, 200)
    graphics.setFont(oldFont)
end

require('test.graphics.newMesh')
require('test.graphics.newParticleSystem')
require('test.graphics.newQuad')
require('test.graphics.newShader')
require('test.graphics.newSpriteBatch')
require('test.graphics.newText')

--print(table.tostr(love.graphics.getSupported()))
--print(table.tostr(love.graphics.getTextureTypes( )))
--print(table.tostr(love.graphics.getCanvasFormats( )))
--print(table.tostr(love.graphics.getSystemLimits()))

return graphics_case