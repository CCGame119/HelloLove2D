--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 11:34
--

local Class = require('libs.Class')

---@class Utils.XMLList.Enumerator:ClassType
local Enumerator = Class.inheritsFrom('Enumerator')

---@class Utils.XMLList:ClassType
local XMLList = Class.inheritsFrom('XMLList')

--TODO: Utils.XMLList

XMLList.Enumerator = Enumerator
Utils.XMLList = XMLList
return XMLList