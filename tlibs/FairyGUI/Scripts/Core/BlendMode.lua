--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 14:22
--

local Class = require('libs.Class')

---@class FairyGUI.BlendMode:number
local BlendMode =  {
    Normal = 0,
    None = 1,
    Add = 2,
    Multiply = 3,
    Screen = 4,
    Erase = 5,
    Mask = 6,
    Below = 7,
    Off = 8,
    Custom1 = 9,
    Custom2 = 10,
    Custom3 = 11
}

---@class FairyGUI.BlendModeUtils:ClassType
local BlendModeUtils = Class.inheritsFrom('BlendModeUtils')

--TODO: FairyGUI.BlendMode & FairyGUI.BlendModeUtils

FairyGUI.BlendMode = BlendMode
FairyGUI.BlendModeUtils = BlendModeUtils
return BlendMode, BlendModeUtils