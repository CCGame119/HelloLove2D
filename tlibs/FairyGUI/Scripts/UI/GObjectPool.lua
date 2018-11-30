--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:42
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')
local Pool = require('libs.Pool')

local ToolSet = Utils.ToolSet

local UIPackage = FairyGUI.UIPackage
local GObject = FairyGUI.GObject

---@class FairyGUI.GObjectPool.InitCallbackDelegate:Delegate @fun(obj:FairyGUI.GObject)
local InitCallbackDelegate = Delegate.newDelegate('InitCallbackDelegate')

---@class FairyGUI.GObjectPool:ClassType
---@field public count number
---@field public initCallback FairyGUI.GObjectPool.InitCallbackDelegate
---@field private _pool table<string, Pool>
---@field private _manager Love2DEngine.Transform
local GObjectPool = Class.inheritsFrom('GObjectPool')

---@param manager Love2DEngine.Transform
function GObjectPool:__ctor(manager)
    self._manager = manager
    self._pool = {}
end

function GObjectPool:Clear()
    for i, list in ipairs(self._pool) do
        ---@param obj FairyGUI.GObject
        list:clear(function(obj) obj:Dispose() end)
    end
    self._pool = {}
end

---@param url string
---@return FairyGUI.GObject
function GObjectPool:GetObject(url)
    url = UIPackage.NormalizeURL(url)
    if (url == nil) then
        return nil
    end

    local arr = self._pool[url]
    if (nil ~= arr and arr.count > 0) then
        return arr:pop()
    end

    local obj = UIPackage.CreateObjectFromURL(url)
    if (obj ~= nil) then
        if (self.initCallback ~= nil) then
            self.initCallback(obj)
        end
    end

    return obj
end

---@param obj FairyGUI.GObject
function GObjectPool:ReturnObject(obj)
    local url = obj.resourceURL
    local arr = self._pool[url]
    if (nil ~= arr) then
        arr = Pool.new(GObject)
        self._pool[url] = arr
    end

    ToolSet.SetParent(obj.displayObject.cachedTransform, self._manager)
    arr.push(obj)
end


local __get = Class.init_get(GObjectPool)
local __set = Class.init_set(GObjectPool)

__get.count = function(self) return #self._pool end

FairyGUI.GObjectPool = GObjectPool
return GObjectPool