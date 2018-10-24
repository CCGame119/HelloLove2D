--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 11:33
--
require('libs.utils.string_ex')
local Class = require('libs.Class')

---@class Utils.XMLTagType:enum
local XMLTagType = {
    Start = 0,
    End = 1,
    Void = 2,
    CDATA = 3,
    Comment = 4,
    Instruction = 5
}

---@class Utils.XMLIterator:ClassType
local  XMLIterator = Class.inheritsFrom('XMLIterator')

--TODO: Utils.XMLIterator

Utils.XMLTagType = XMLTagType
Utils.XMLIterator = XMLIterator
return XMLIterator