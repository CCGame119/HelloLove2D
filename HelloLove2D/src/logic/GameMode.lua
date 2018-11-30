--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 13:50
--

local Class = require('libs.Class')
local VInputDevice = require('libs.Love2DEngine.Devices.Input')
local Bullet = require('src.entity.Bullet')
local Plane = require('src.entity.Plane')
local Enemy = require('src.entity.Enemy')
local Collision = require('libs.physics.Collision')
local Screen = require('libs.Love2DEngine.Devices.Screen')

---@class GameMode:table @游戏Mode
---@field public score number @ 分数
---@field public isAlive boolean @ 玩家是否活着
---@field public canShoot boolean @ 是否可以射击
---@field public canShootTimerMax number @ 射击时间间隔上限
---@field public canShootTimer number @ 射击计时器
---@field public player Plane @ 玩家
---@field public bullets Bullet[] @ 子弹列表
---@field public createEnemyTimerMax number @ 创建敌人间隔
---@field public createEnemyTimer number @ 创建敌人计时器
---@field public enemys Enemy[] @ 子弹列表
local GameMode = Class.inheritsFrom('GameMode')

function GameMode:onLoad()
    self.score = 0
    self.isAlive = true
    if not self.gunSFX then
        self.gunSFX = love.audio.newSource("assets/sfxs/gun-sound.wav", "static")
    end

    -- Timers
    self.canShoot = true
    self.canShootTimerMax = 0.2
    self.canShootTimer = self.canShootTimerMax
    self.createEnemyTimerMax = 0.4
    self.createEnemyTimer = self.createEnemyTimerMax

    -- Entity Storage
    self.bullets = {}
    self.enemys = {}
    self.player = Plane:get()
end

--- 游戏刷新回调
---@param dt number @delta timer
function GameMode:onUpdate(dt)
    self:onShoot(dt)
    self:onUpdateSprites(dt)
    self:onSpawnEnemy(dt)
    self:onCollision(dt)
    self:onReload(dt)
end

function GameMode:onReload(dt)
    if not self.isAlive and VInputDevice.isResetDown() then
        self:onLoad()
    end
end

function GameMode:onCollision(dt)
    local x1,y1,w1,h1, x2,y2,w2,h2
    for i = #self.enemys, 1, -1 do
        local enemy = self.enemys[i]
        x1,y1,w1,h1 = enemy:bound()
        for j = #self.bullets, 1, -1 do
            local bullet = self.bullets[j]
            x2,y2,w2,h2 = bullet:bound()
            if Collision.CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2) then
                Enemy:recycle(table.remove(self.enemys, i))
                Bullet:recycle(table.remove(self.bullets, j))
                self.score = self.score + 1
            end
        end
        x2,y2,w2,h2 = self.player:bound()
        if Collision.CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
        and self.isAlive then
            Enemy.recycle(table.remove(self.enemys, i))
            self.isAlive = false
        end
    end
end

--- 创建敌人
function GameMode:onSpawnEnemy(dt)
    if #self.enemys > 10 then return end

    self.createEnemyTimer = self.createEnemyTimer - dt
    if self.createEnemyTimer < 0 then
        self.createEnemyTimer = self.createEnemyTimerMax

        -- create enemy
        local x = math.random(10, Screen.w - 10)
        local newEnemy = Enemy:get():init(x, -10)
        table.insert(self.enemys, newEnemy)
    end
end

--- 更新精灵
function GameMode:onUpdateSprites(dt)
    local rx, ry = VInputDevice.getJoyStickInput()
    if 0 ~= rx or 0 ~= ry then
        self.player:move(rx, ry, dt)
    end

    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        bullet:move(dt)
        if bullet.y < 0 then
            Bullet:recycle(table.remove(self.bullets, i))
        end
    end

    for i = #self.enemys, 1, -1 do
        local enemy = self.enemys[i]
        enemy:move(dt)
        if enemy.y > Screen.h + 50 then
            Enemy:recycle(table.remove(self.enemys, i))
        end
    end
end

function GameMode:onShoot(dt)
    if not self.isAlive then return end

    self.canShootTimer = self.canShootTimer - 1*dt
    if self.canShootTimer < 0 then
        self.canShoot = true
    end

    if VInputDevice.isFireKeyDown() and self.canShoot then
        local newBullet = Bullet:get():init(self.player:bulletSpawnPoint())
        table.insert(self.bullets, newBullet)

        self.canShoot = false
        self.canShootTimer = self.canShootTimerMax

        self.gunSFX:play()
    end
end

--- 渲染
function GameMode:onDraw()
    for i, enemy in ipairs(self.enemys) do
        enemy:onDraw()
    end

    for i, bullet in ipairs(self.bullets) do
        bullet:onDraw()
    end

    if self.isAlive then
        self.player:onDraw()
    else
        love.graphics.print("Press 'R' to restart", Screen.pos(0.45, 0.49))
    end

    love.graphics.print("Sorce: " .. self.score, Screen.pos(0.02, 0.01))
    love.graphics.print("FPS: " .. love.timer.getFPS(), Screen.pos(0.8, 0.01))
    love.graphics.print("MEM: " .. collectgarbage('count'), Screen.pos(0.8, 0.025))
    love.graphics.print("TIME: " .. love.timer.getTime(), Screen.pos(0.8, 0.040))
end

return GameMode