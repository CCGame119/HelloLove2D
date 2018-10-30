--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/29 17:34
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

---@class TagHandler.TagHandler:Delegate @ fun(tagName:string, end:boolean, attr)
local TagHandler = Delegate.newDelegate('TagHandler')

---@class Utils.UBBParser:ClassType
---@field protected handlers table<string, TagHan>
---@field private _text string
---@field private _readPos number
---@field public defaultImgWidth number
---@field public defaultImgHeight number
local UBBParser = Class.inheritsFrom('UBBParser', {
    defaultImgWidth = 0,
    defaultImgHeight = 0
})

UBBParser.inst = UBBParser.new()

function UBBParser:__ctor()
    self.handlers = {}
    self.handlers["url"] = self.onTag_URL
    self.handlers["img"] = self.onTag_IMG
    self.handlers["b"] = self.onTag_Simple
    self.handlers["i"] = self.onTag_Simple
    self.handlers["u"] = self.onTag_Simple
    self.handlers["sup"] = self.onTag_Simple
    self.handlers["sub"] = self.onTag_Simple
    self.handlers["color"] = self.onTag_COLOR
    self.handlers["font"] = self.onTag_FONT
    self.handlers["size"] = self.onTag_SIZE
    self.handlers["align"] = self.onTag_ALIGN
end

---@param tagName string
---@param End boolean
---@param attr string
---@return string
function UBBParser:onTag_URL(tagName, End, attr)
    if not End then
        if attr ~= nil then
            return "<a href=\"" .. attr .. "\" target=\"_blank\">"
        else
            local href = self:GetTagText(false)
            return "<a href=\"" .. href .. "\" target=\"_blank\">"
        end
    else
        return "</a>"
    end
end

---@param tagName string
---@param End boolean
---@param attr string
---@return string
function UBBParser:onTag_IMG(tagName, End, attr)
    if not End then
        local src = self:GetTagText(true)
        if src == nil or #src == 0 then
            return nil
        end
        if self.defaultImgWidth ~= 0 then
            return "<img src=\"" .. src .. "\" width=\"" .. self.defaultImgWidth .. "\" height=\"" .. self.defaultImgHeight .. "\"/>"
        else
            return "<img src=\"" .. src .. "\"/>"
        end
    else
        return nil
    end
end

---@param tagName string
---@param End boolean
---@param attr string
---@return string
function UBBParser:onTag_Simple(tagName, End, attr)
    return End and ("</" .. tagName .. ">") or ("<" .. tagName .. ">")
end

---@param tagName string
---@param End boolean
---@param attr string
---@return string
function UBBParser:onTag_COLOR(tagName, End, attr)
    if not End then
        return "<font color=\"" .. attr .. "\">"
    end
    return "</font>"
end

---@param tagName string
---@param End boolean
---@param attr string
---@return string
function UBBParser:onTag_FONT(tagName, End, attr)
    if not End then
        return "<font face=\"" .. attr .. "\">"
    end
    return "</font>"
end

---@param tagName string
---@param End boolean
---@param attr string
---@return string
function UBBParser:onTag_SIZE(tagName, End, attr)
    if not End then
        return "<font size=\"" .. attr .. "\">"
    end
    return "</font>"
end

---@param tagName string
---@param End boolean
---@param attr string
---@return string
function UBBParser:onTag_ALIGN(tagName, End, attr)
    if not End then
        return "<p align=\"" .. attr .. "\">"
    end
    return "</p>"
end

---@param remove boolean
---@return string
function UBBParser:GetTagText(remove)
    local pos1 = self._readPos
    local pos2
    local buffer = ''
    pos2 = self._text:find('[', pos1)
    while pos2 ~= nil do
        if self._text[pos2 - 1] == '\\' then
            buffer = buffer .. self._text:sub(pos1, pos2 - 2)
            buffer = buffer .. '['
            pos1 = pos2 + 1
        else
            buffer = buffer .. self._text:sub(pos1, pos2 - 1)
            break
        end
        pos2 = self._text:find('[', pos1)
    end
    if pos2 == nil then
        return nil
    end

    if remove then
        self._readPos = pos2
    end

    return buffer
end

---@param text string
---@return string
function UBBParser:Parse(text)
    self._text = text
    local pos1, pos2, pos3 = 1, 0, 0
    local End = false
    local tag, attr = '', ''
    local repl = ''
    local buffer = ''
    ---@type Utils.TagHandler
    local func
    pos2 = self._text:find('[', pos1)
    while pos2 ~= nil do
        if pos2 > 0 and self._text[pos2 - 1] == '\\' then
            buffer = buffer .. self._text:sub(pos1, pos2 - 2)
            buffer = buffer .. '['
            pos1 = pos2 + 1
            --continue
        else
            buffer = buffer .. self._text:sub(pos1, pos2 - 1)
            pos1 = pos2
            pos2 = self._text:find('[', pos1)
            if pos2 == nil then
                break
            end

            if pos2 == pos1 + 1 then
                buffer = buffer .. self._text:sub(pos1, pos1 + 1)
                pos1 = pos2 + 1
                --continue
            else
                End = self._text[pos1 + 1] == '/'
                pos3 = End and  pos1 + 2 or pos1 + 1
                tag = self._text:sub(pos3, pos2 - 1)
                self._readPos = pos2 + 1
                attr = nil
                repl = nil
                pos3 = tag:find('=')
                if pos3 ~= nil then
                    attr = tag:sub(pos3 + 1)
                    tag = tag:sub(0, pos3)
                end
                tag = tag:lower()
                func = self.handlers[tag]
                if nil ~= func then
                    repl = func(tag, End, attr)
                    if repl ~= nil then
                        buffer = buffer .. repl
                    end
                else
                    buffer = buffer .. self._text:sub(pos1, pos2)
                end
                pos1 = self._readPos
            end
        end

        pos2 = self._text:find('[', pos1)
    end

    if '' == buffer then
        self._text = nil
        return text
    end

    if pos1 < #self._text then
        buffer = buffer .. self._text:sub(pos1)
    end
    self._text = nil
    return buffer
end


Utils.TagHandler = TagHandler
Utils.UBBParser = UBBParser
return UBBParser