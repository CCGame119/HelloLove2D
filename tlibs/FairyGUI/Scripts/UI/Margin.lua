--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 15:01
--

local Class = require('libs.Class')

---@class FairyGUI.Margin:ClassType
local Margin = Class.inheritsFrom('Margin', {left = 0, right = 0, top = 0, bottom = 0})

function Margin:__ctor(l,r,t,b)
    self.left, self.right. self.top, self.bottom = l,r,t,b
end

---@return FairyGUI.Margin
function Margin:Clone()
    return Margin.New(self.left, self.right, self.top, self.bottom)
end

FairyGUI.Margin = Margin
return Margin