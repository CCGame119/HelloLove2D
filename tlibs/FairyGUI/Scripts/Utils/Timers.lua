--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 19:02
--
local Class = require('libs.Class')
local Delegate = require('libs.Delegate')
local Pool = require('libs.Pool')

local Debug = Love2DEngine.Debug
local Timer = Love2DEngine.Time
local Object = Love2DEngine.Object
local GameObject = Love2DEngine.GameObject
local HideFlags = Love2DEngine.HideFlags
local LuaBehaviour = Love2DEngine.LuaBehaviour

---@class FairyGUI.TimerCallback:Delegate @fun(param:any)
local TimerCallback = Delegate.newDelegate('TimerCallback')

---@class FairyGUI.Timers:ClassType
---@field public inst FairyGUI.Timers
---@field private _items table<FairyGUI.TimerCallback, FairyGUI.Anymous_T>
---@field private _toAdd table<FairyGUI.TimerCallback, FairyGUI.Anymous_T>
---@field private _toRemove FairyGUI.Anymous_T[]
---@field private _pool Pool<FairyGUI.Anymous_T>
---@field private _engine FairyGUI.TimersEngine
---@field private gameObject Love2DEngine.GameObject
local Timers = Class.inheritsFrom('Timers')

Timers.Repeat = 0
Timers.time = 0
Timers.catchCallbackExceptions = true
---@type FairyGUI.Timers
Timers._inst = nil
Timers.catchCallbackExceptions = true

function Timers:__ctor()
    Timers._inst = self
    self.gameObject = GameObject:get("FairyGUI.Timers")
    self.gameObject.hideFlags = HideFlags.HideInHierarchy
    self.gameObject:SetActive(true)
    --Object.DontDestroyOnLoad(gameObject)

    self._engine = self.gameObject:AddComponent(FairyGUI.TimersEngine)

    self._items = {}
    self._toAdd = {}
    self._toRemove = {}
    self._pool = Pool.new(FairyGUI.Anymous_T)
end

---@param interval number
---@param Repeat number
---@param callback FairyGUI.TimerCallback
---@param param any @default: nil
function Timers:Add(interval, Repeat, callback, callbackParam)
    if callback == nil then
        Debug.LogWarn("timer callback is null, " .. interval + "," .. Repeat)
        return
    end
    assert(callback:isa(TimerCallback), "type mismatch")

    local t = self._items[callback]
    if nil ~= t then
        t:set(interval, Repeat, callback, callbackParam)
        t.elapsed = 0
        t.deleted = false
        return
    end

    t = self._toAdd[callback]
    if nil ~= t then
        t:set(interval, Repeat, callback, callbackParam)
        return
    end

    t = self:GetFromPool()
    t.interval = interval
    t.Repeat = Repeat
    t.callback = callback
    t.param = callbackParam
    self._toAdd[callback] = t
end

---@param callback FairyGUI.TimerCallback
---@param callbackParam any
function Timers:CallLater(callback, callbackParam)
    self:Add(0.001, 1, callback, callbackParam)
end

---@param callback FairyGUI.TimerCallback
---@param callbackParam any
function Timers:AddUpdate(callback, callbackParam)
    self:Add(0.001, 0, callback, callbackParam)
end

---@param routine fun():thread
function Timers:StartCoroutine(routine)
    self._engine:StartCoroutine(routine)
end

---@param callback FairyGUI.TimerCallback
---@return boolean
function Timers:Exists(callback)
    if self._toAdd[callback] ~= nil then
        return true
    end

    local at = self._items[callback]
    if nil ~= at then
        return not at.deleted
    end
    return false
end

---@param callback FairyGUI.TimerCallback
function Timers:Remove(callback)
    assert(not callback:isa(TimerCallback), "type mismatch")

    local t = self._toAdd[callback]
    if nil ~= t then
        self._toAdd[callback] = nil
        self:ReturnToPool(t)
    end

    t = self._items[callback]
    if self._items then
        t.deleted = true
    end
end

---@return FairyGUI.Anymous_T
function Timers:GetFromPool()
    ---@type FairyGUI.Anymous_T
    local t =  self._pool:pop()
    t.deleted = false
    t.elapsed = 0
    return t
end

---@param t FairyGUI.Anymous_T
function Timers:ReturnToPool(t)
    t.callback = nil
    self._pool:push(t)
end

function Timers:Update()
    local dt = Timer.unscaledDeltaTime

    for k, v in pairs(self._items) do
        if v.deleted then
            table.insert(self._toRemove, v)
            --continue
        else
            v.elapsed = v.elapsed + dt
            if v.elapsed < v.interval then
                --continue
            else
                v.elapsed = v.elapsed - v.interval
                if v.elapsed < 0 or v.elapsed > 0.03 then
                    v.elapsed = 0
                end

                if v.Repeat > 0 then
                    v.Repeat = v.Repeat - 1
                    if v.Repeat == 0 then
                        v.deleted = true
                        table.insert(self._toRemove, v)
                    end
                end
                self.Repeat = v.Repeat
                if v.callback ~= nil then
                    local oldTraceback = Debug.oldTraceback
                    if Timers.catchCallbackExceptions then
                        Debug.traceback = function(msg)
                            v.deleted = true
                            Debug.LogWarn("FairyGUI: timer(internal=" .. v.interval + ", repeat=" .. v.Repeat + ") callback error > " + msg)
                        end
                    end
                    v.callback(v.param)
                    if Timers.catchCallbackExceptions then
                        Debug.traceback = oldTraceback
                    end
                end
            end
        end
    end

    for i, v in ipairs(self._toRemove) do
        if v.deleted and v.callback ~= nil then
            self._items[v.callback] = nil
            self:ReturnToPool(v)
        end
    end
    self._toRemove = {}
    for i, v in pairs(self._toAdd) do
        self._items[i] = v
    end
    self._toAdd = {}
end

local __get = Class.init_get(Timers, true)
local __set = Class.init_set(Timers, true)

---@param self FairyGUI.Timers
__get.inst = function(self)
    if Timers._inst == nil then
        Timers._inst = Timers.new()
    end
    return Timers._inst
end

---@class FairyGUI.Anymous_T:ClassType
---@field public interval number
---@field public Repeat number
---@field public callback FairyGUI.TimerCallback
---@field public param any
---@field public elapsed number
---@field public deleted boolean
local Anymous_T = Class.inheritsFrom('Anymous_T')

---@param interval number
---@param Repeat number
---@param callback FairyGUI.TimerCallback
---@param param any
function Anymous_T:set(interval, Repeat, callback, param)
    self.interval = interval
    self.Repeat = Repeat
    self.callback = callback
    self.param = param
end

---@class FairyGUI.TimersEngine:Love2DEngine.LuaBehaviour
local TimersEngine = Class.inheritsFrom('TimersEngine', nil, LuaBehaviour)

function TimersEngine:Update()
    Timers.inst:Update()
end

FairyGUI.TimerCallback = TimerCallback
FairyGUI.Anymous_T = Anymous_T
FairyGUI.TimersEngine = TimersEngine
FairyGUI.Timers = Timers
setmetatable(Timers, Timers)
return Timers