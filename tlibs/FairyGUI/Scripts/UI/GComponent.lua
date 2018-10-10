--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 10:35
--
local Class = require('libs.Class')
local GObject = FairyGUI.GObject

---@class FairyGUI.GComponent:FairyGUI.GObject
local GComponent = Class.inheritsFrom('GComponent', nil, GObject)

--TODO: FairyGUI.GComponent

---@param index number
---@return FairyGUI.GObject
function GComponent:GetChildAt(index)
    --TODO: FairyGUI.GComponent:GetChildAt
end

FairyGUI.GComponent = GComponent
return GComponent