require('libs.Love2DEngine.Love2DEngine')
local GameMode = require('src.logic.GameMode')

---============test============
require('test.Love2DEngine.main')
require('test.Love2D.main')
require('test.FairyGUI.main')

mx, my = 0, 0

-- 初始化矩形的一些默认值.
function love.load()
    GameMode:onLoad()

    love.testCase()
end

-- Updating
function love.update(dt)
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end
    if love.keyboard.isDown('p') then
        collectgarbage('collect')
    end

    if love.mouse.isDown(1) then
        mx = love.mouse.getX()
        my = love.mouse.getY()

        FairyGUI_Cases.callback0:Invoke(dt)
    end

    GameMode:onUpdate(dt)
end

-- 渲染颜色矩形.
function love.draw()

    GameMode:onDraw()

    Love2D_Cases.graphics_case.newText_cases()
end

function love.testCase()
    --FairyGUI_Cases.EventCallback0_case(GameMode.onShoot, GameMode)
    --FairyGUI_Cases.TweenValue_calse()

    --Love2DEngine_Cases.Matrix4x4_case()
    --Love2DEngine_Cases.Vector2_case()
    --Love2DEngine_Cases.Vector3_case()
    --Love2DEngine_Cases.Vector4_case()
end