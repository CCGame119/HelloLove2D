--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:47
--

local Class = require('libs.Class')

---@class FairyGUI.PageOption:ClassType
---@field public controller FairyGUI.Controller
---@field public index number
---@field public name string
---@field public id string
---@field private _controller FairyGUI.Controller
---@field private _id string
local PageOption = Class.inheritsFrom('PageOption')

function PageOption:Clear()
    self._id = nil
end

local __get = Class.init_get(PageOption)
local __set = Class.init_set(PageOption)

---@param self FairyGUI.PageOption
---@param val FairyGUI.Controller
__set.controller = function(self, val)
    self._controller = val
end

---@param self FairyGUI.PageOption
__get.index = function(self)
    if self._id ~= nil then
        return self._controller:GetPageIndexById(self._id)
    else
        return -1
    end
end

---@param self FairyGUI.PageOption
---@param val number
__set.index = function(self, val)
    self._id = self._controller:GetPageId(val)
end

---@param self FairyGUI.PageOption
__get.name = function(self)
    if self._id ~= nil then
        return self._controller:GetPageNameById(self._id)
    else
        return nil
    end
end

---@param self FairyGUI.PageOption
---@param val string
__set.name = function(self, val)
    self._id = self._controller:GetPageNameById(val)
end

---@param self FairyGUI.PageOption
__get.id = function(self)
    return self._id
end

---@param self FairyGUI.PageOption
---@param val string
__set.id = function(self, val)
    self._id = val
end


FairyGUI.PageOption = PageOption
return PageOption