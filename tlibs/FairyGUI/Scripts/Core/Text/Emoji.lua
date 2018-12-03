--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:18
--

local Class = require('libs.Class')

---@class FairyGUI.Emoji:ClassType
---@field public url string 代表图片资源url。
---@field public width number 图片宽度。不设置（0）则表示使用原始宽度。
---@field public height number 图片高度。不设置（0）则表示使用原始高度。
local Emoji = Class.inheritsFrom('Emoji')

---@param url string
---@param width number
---@param height number
function Emoji:__ctor(url, width, height)
    self.url = url
    self.width = width or 0
    self.height = height or 0
end


FairyGUI.Emoji= Emoji
return Emoji