--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 15:01
--

local Class = require('libs.Class')

---@class FairyGUI.Margin:ClassType
---@field public left number
---@field public right number
---@field public top number
---@field public bottom number
---@field public zero FairyGUI.Margin
local Margin = Class.inheritsFrom('Margin', {left = 0, right = 0, top = 0, bottom = 0})

function Margin:__ctor(l,r,t,b)
    self.left, self.right, self.top, self.bottom = l, r, t, b
end

---@return FairyGUI.Margin
function Margin:Clone()
    return Margin.New(self.left, self.right, self.top, self.bottom)
end

local __get = Class.init_get(Margin, true)
local __set = Class.init_set(Margin, true)

__get.zero = function() return Margin.new() end

Margin.__call = function(t, l,r,t,b)
    return Margin.new(l,r,t,b)
end

FairyGUI.Margin = Margin
setmetatable(Margin, Margin)
return Margin