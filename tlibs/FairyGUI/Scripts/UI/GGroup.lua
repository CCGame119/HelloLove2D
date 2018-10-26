--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:22
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject

---@class FairyGUI.GGroup:FairyGUI.GObject
local GGroup = Class.inheritsFrom('GGroup', nil, GObject)

--TODO: FairyGUI.GGroup

FairyGUI.GGroup = GGroup
return GGroup