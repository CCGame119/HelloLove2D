require('libs.Love2DEngine')

require('libs.utils.package_ex')
package.addSearchPath("/tlibs/FairyGUI/Scripts/?.lua")

require('Utils.Delegate')
require('FairyGUI')
require('Event.EventDispatcher')
local delegate = FairyGUI.EventCallback0.new()

local VInputDevice = require('libs.Love2DEngine.Devices.Input')
local GameMode = require('src.logic.GameMode')
local graphics_case = require('test.graphics_case')
local Sprite = require('libs.Sprite')

require('testLove2DEngine.testRect')

mx, my = 0, 0

-- 初始化矩形的一些默认值.
function love.load()
    GameMode:onLoad()

    delegate:Add(GameMode.onShoot, GameMode)

    GameMode.player.name = 'test'

    Rect_tostring()
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

        delegate(dt)
    end

    GameMode:onUpdate(dt)
end

-- 渲染颜色矩形.
function love.draw()
    --graphics_case.clear_cases()

    GameMode:onDraw()

    --graphics_case.newText_cases()
end

function addSearchPath(path)
    local fullPath = string.format(";%s%s", love.filesystem.getSourceBaseDirectory(), path)
    package.path = package.path .. fullPath
end