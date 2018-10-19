--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:24
--

local Class = require('libs.Class')

local DisplayObject = FairyGUI.DisplayObject

---@class FairyGUI.FlipType:enum
local FlipType = {
    None = 0,
    Horizontal = 1,
    Vertical = 2,
    Both = 3
}

---@class FairyGUI.Image:ClassType
local Image = Class.inheritsFrom('Image', nil, DisplayObject)

--TODO: FairyGUI.Image

FairyGUI.FlipType = FlipType
FairyGUI.Image = Image
return Image