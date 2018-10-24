--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/26 17:31
--
local Class = require('libs.Class')

---@class Pool:ClassType @ 对象池
---@field protected cls Class @对象类
---@field protected _objs @对象列表
---@field public count number
local Pool = Class.inheritsFrom('Pool')

function Pool:__ctor(cls)
    self.cls = cls
    self._objs = {}
end

---回收对象
---@param obj cls @ 对象
function Pool:push(obj)
    table.insert(self._objs, obj)
end

---弹出对象
---@return cls @ 对象
function Pool:pop()
    if #self._objs > 0 then
        return table.remove(self._objs)
    end

    return self.cls.new()
end

local __get = Class.init_get(Pool)

---@param self Pool
__get.count = function(self)
    return #self._objs
end

return Pool