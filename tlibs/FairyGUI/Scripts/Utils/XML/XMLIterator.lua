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
---@field private CDATA_START string
---@field private CDATA_END string
---@field private COMMENT_START string
---@field private COMMENT_END string
local  XMLIterator = Class.inheritsFrom('XMLIterator',
        {
            CDATA_START = "<![CDATA[",
            CDATA_END = "]]>",
            COMMENT_START = "<!--",
            COMMENT_END = "-->",
        })

XMLIterator.tagName = ''
XMLIterator.tagType = XMLTagType.Start
XMLIterator.lastTagName = ''

XMLIterator.source = ''
XMLIterator.sourceLen = 0
XMLIterator.parsePos = 0
XMLIterator.tagPos = 0
XMLIterator.tagLength = 0
XMLIterator.lastTagEnd = 0
XMLIterator.attrParsed = false
XMLIterator.lowerCaseName = false

XMLIterator.buffer = ''
---@type table<string, string>
XMLIterator.attributes = {}

---@param source string
---@param lowerCaseName boolean @def false
function XMLIterator:Begin(source, lowerCaseName)
    lowerCaseName = lowerCaseName or false
    XMLIterator.source = source
    XMLIterator.lowerCaseName = lowerCaseName
    XMLIterator.sourceLen = #source
    XMLIterator.parsePos = 1
    XMLIterator.lastTagEnd = 0
    XMLIterator.tagPos = 0
    XMLIterator.tagLength = 0
    XMLIterator.tagName = nil
end

---@return boolean
function XMLIterator:NextTag()
    local pos = 1
    local c = ''
    XMLIterator.tagType = XMLTagType.Start
    XMLIterator.buffer.Length = 0
    XMLIterator.lastTagEnd = XMLIterator.parsePos
    XMLIterator.attrParsed = false
    XMLIterator.lastTagName = XMLIterator.tagName

    pos = string.find(XMLIterator.source, '<', XMLIterator.parsePos, true)
    while pos ~= nil do
        XMLIterator.parsePos = pos
        pos = pos + 1

        if pos == XMLIterator.sourceLen + 1 then
            break
        end

        c = XMLIterator.source[pos]
        if c == '!' then
            if XMLIterator.sourceLen > pos + 7 and string.sub(XMLIterator.source, pos - 1, pos + 8) == XMLIterator.CDATA_START then
                pos = string.find(XMLIterator.source, XMLIterator.CDATA_END, pos, true)
                XMLIterator.tagType = XMLTagType.CDATA
                XMLIterator.tagName = ''
                XMLIterator.tagPos = XMLIterator.parsePos
                if pos == nil then
                    XMLIterator.tagLength = XMLIterator.sourceLen - XMLIterator.parsePos
                else
                    XMLIterator.tagLength = pos + 3 - XMLIterator.parsePos
                end
                XMLIterator.parsePos = XMLIterator.parsePos + XMLIterator.tagLength
                return true
            end

            if XMLIterator.sourceLen > pos + 2 and string.sub(XMLIterator.source, pos - 1, pos + 3) == XMLIterator.COMMENT_START then
                pos = string.find(XMLIterator.source, XMLIterator.COMMENT_END, pos, true)
                XMLIterator.tagType = XMLTagType.Comment
                XMLIterator.tagName = ''
                XMLIterator.tagPos = XMLIterator.parsePos
                if pos == nil then
                    XMLIterator.tagLength = XMLIterator.sourceLen - XMLIterator.parsePos
                else
                    XMLIterator.tagLength = pos + 3 - XMLIterator.parsePos
                end
                XMLIterator.parsePos = XMLIterator.parsePos + XMLIterator.tagLength
                return true
            end

            pos = pos + 1
            XMLIterator.tagType = XMLTagType.Instruction
        elseif c == '/' then
            pos = pos + 1
            XMLIterator.tagType = XMLTagType.End
        elseif c == '?' then
            pos = pos + 1
            XMLIterator.tagType = XMLTagType.Instruction
        end

        while pos <= XMLIterator.sourceLen do
            c = XMLIterator.source[pos]
            if string.isWhiteSpace(c) or c == '>' or c == '/' then
                break
            end
            pos = pos + 1
        end

        if pos == XMLIterator.sourceLen + 1 then
            break
        end


        XMLIterator.buffer = XMLIterator.buffer .. string.sub(XMLIterator.source, XMLIterator.parsePos + 1, pos)
        if #XMLIterator.buffer > 0 and XMLIterator.buffer[1] == '/' then
            XMLIterator.buffer = string.sub(XMLIterator.buffer, 2)
        end

        local singleQuoted, doubleQuoted = false, false
        local possibleEnd = -1
        while pos <= XMLIterator.sourceLen do
            c = XMLIterator.source[pos]
            if c == '"' then
                if not singleQuoted then
                    doubleQuoted = not doubleQuoted
                end
            elseif c == "'" then
                if not doubleQuoted then
                    singleQuoted = not singleQuoted
                end
            elseif c == '>' then
                if not (singleQuoted or doubleQuoted) then
                    possibleEnd = -1
                    break
                end
                possibleEnd = pos
            elseif c == '<' then
                break
            end
            pos = pos + 1
        end
        if possibleEnd ~= -1 then
            pos = possibleEnd
        end

        if pos == XMLIterator.sourceLen + 1 then
            break
        end

        if XMLIterator.source[pos - 1] == '/' then
            XMLIterator.tagType = XMLTagType.Void
        end

        XMLIterator.tagName = XMLIterator.buffer
        if XMLIterator.lowerCaseName then
            XMLIterator.tagName = string.lower(XMLIterator.tagName)
        end
        XMLIterator.tagPos = XMLIterator.parsePos
        XMLIterator.tagLength = pos + 1 - XMLIterator.parsePos
        XMLIterator.parsePos = XMLIterator.parsePos + XMLIterator.tagLength

        return true
    end

    XMLIterator.tagPos = XMLIterator.sourceLen
    XMLIterator.tagLength = 0
    XMLIterator.tagName = nil
    return false
end

---@return string
function XMLIterator:GetTagSource()
    return string.sub(XMLIterator.source, XMLIterator.tagPos, XMLIterator.tagPos + XMLIterator.tagLength)
end

---@return string
function XMLIterator:GetRawText()

end

--TODO: Utils.XMLIterator

Utils.XMLTagType = XMLTagType
Utils.XMLIterator = XMLIterator
return XMLIterator