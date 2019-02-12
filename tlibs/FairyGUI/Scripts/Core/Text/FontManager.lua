--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:17
--

local Class = require('libs.Class')

local DynamicFont = FairyGUI.DynamicFont
local UIPackage = FairyGUI.UIPackage

---@class FairyGUI.FontManager:ClassType
local FontManager = Class.inheritsFrom('FontManager')

---@type table<string, FairyGUI.BaseFont>
FontManager.sFontFactory = {}

---@param font FairyGUI.BaseFont
---@param alias string
function FontManager.RegisterFont(font, alias)
    if FontManager.sFontFactory[font.name] == nil then
        FontManager.sFontFactory[font.name] = font
    end

    if alias ~= nil then
        if FontManager.sFontFactory[alias] == nil then
            FontManager.sFontFactory[alias] = font
        end
    end
end

---@param font FairyGUI.BaseFont
function FontManager.UnregisterFont(font)
    for n, v in pairs(FontManager.sFontFactory) do
        if v == font then
            FontManager.sFontFactory[n] = nil
        end
    end
end

---@param name string
---@return FairyGUI.BaseFont
function FontManager.GetFont(name)
    local ret
    if (name:startsWith(UIPackage.URL_PREFIX)) then
        ret = UIPackage.GetItemAssetByURL(name)
        if (ret ~= nil) then
            return ret
        end
    end

    ret = FontManager.sFontFactory[name]
    if nil == ret then
        ret = DynamicFont.new(name)
        FontManager.sFontFactory[name] = ret
    end

    return ret
end

function FontManager.Clear()
    FontManager.sFontFactory = {}
end


FairyGUI.FontManager = FontManager
return FontManager