--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 11:33
--
require('libs.utils.string_ex')
local Class = require('libs.Class')

local XMLUtils = Utils.XMLUtils

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

local m = XMLIterator

---@param source string
---@param lowerCaseName boolean @def false
function XMLIterator.Begin(source, lowerCaseName)
    lowerCaseName = lowerCaseName or false
    m.source = source
    m.lowerCaseName = lowerCaseName
    m.sourceLen = #source
    m.parsePos = 1
    m.lastTagEnd = 0
    m.tagPos = 0
    m.tagLength = 0
    m.tagName = nil
end


---@return boolean
function XMLIterator.NextTag()
    local pos = 1
    local c = ''
    m.tagType = XMLTagType.Start
    m.buffer.Length = 0
    m.lastTagEnd = m.parsePos
    m.attrParsed = false
    m.lastTagName = m.tagName

    pos = m.source:find('<', m.parsePos, true)
    while pos ~= nil do
        m.parsePos = pos
        pos = pos + 1

        if pos == m.sourceLen + 1 then
            break
        end

        c = m.source[pos]
        if c == '!' then
            if m.sourceLen > pos + 7 and m.source(pos - 1, pos + 8) == m.CDATA_START then
                pos = m.source:find(m.CDATA_END, pos, true)
                m.tagType = XMLTagType.CDATA
                m.tagName = ''
                m.tagPos = m.parsePos
                if pos == nil then
                    m.tagLength = m.sourceLen - m.parsePos
                else
                    m.tagLength = pos + 3 - m.parsePos
                end
                m.parsePos = m.parsePos + m.tagLength
                return true
            end

            if m.sourceLen > pos + 2 and m.source(pos - 1, pos + 3) == m.COMMENT_START then
                pos = m.source:find(m.COMMENT_END, pos, true)
                m.tagType = XMLTagType.Comment
                m.tagName = ''
                m.tagPos = m.parsePos
                if pos == nil then
                    m.tagLength = m.sourceLen - m.parsePos
                else
                    m.tagLength = pos + 3 - m.parsePos
                end
                m.parsePos = m.parsePos + m.tagLength
                return true
            end

            pos = pos + 1
            m.tagType = XMLTagType.Instruction
        elseif c == '/' then
            pos = pos + 1
            m.tagType = XMLTagType.End
        elseif c == '?' then
            pos = pos + 1
            m.tagType = XMLTagType.Instruction
        end

        while pos <= m.sourceLen do
            c = m.source[pos]
            if c:isSpace() or c == '>' or c == '/' then
                break
            end
            pos = pos + 1
        end

        if pos == m.sourceLen + 1 then
            break
        end


        m.buffer = m.buffer .. m.source(m.parsePos + 1, pos)
        if #m.buffer > 0 and m.buffer[1] == '/' then
            m.buffer = m.buffer(2)
        end

        local singleQuoted, doubleQuoted = false, false
        local possibleEnd = -1
        while pos <= m.sourceLen do
            c = m.source[pos]
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

        if pos == m.sourceLen + 1 then
            break
        end

        if m.source[pos - 1] == '/' then
            m.tagType = XMLTagType.Void
        end

        m.tagName = m.buffer
        if m.lowerCaseName then
            m.tagName = string.lower(m.tagName)
        end
        m.tagPos = m.parsePos
        m.tagLength = pos + 1 - m.parsePos
        m.parsePos = m.parsePos + m.tagLength

        return true
    end

    m.tagPos = m.sourceLen
    m.tagLength = 0
    m.tagName = nil
    return false
end

---@return string
function XMLIterator.GetTagSource()
    return m.source(m.tagPos, m.tagPos + m.tagLength)
end

---@param trim boolean @def = false
---@return string
function XMLIterator.GetRawText(trim)
    trim = trim or false
    if m.lastTagEnd == m.tagPos then
        return ''
    end
    if trim then
        local i = m.lastTagEnd
        while i < m.tagPos do
            local c = m.source[i]
            if not c:isSpace() then
                break
            end
        end

        if i == m.tagPos then
            return ''
        end
        return m.source(i, i + m.tagPos):trimEnd()
    end
    
    return m.source(m.lastTagEnd, m.tagPos)
end

---@param trim boolean @def = false
---@return string
function XMLIterator.GetText(trim)
    trim = trim or false
    if m.lastTagEnd == m.tagPos then
        return ''
    end
    if trim then
        local i = m.lastTagEnd
        while i < m.tagPos do
            local c = m.source[i]
            if not c:isSpace() then
                break
            end
        end

        if i == m.tagPos then
            return ''
        end
        return XMLUtils.DecodeString(m.source(i, i + m.tagPos):trimEnd())
    end

    return XMLUtils.DecodeString(m.source(m.lastTagEnd, m.tagPos))
end

---@param attrName string
---@return boolean
function XMLIterator.HasAttribute(attrName)
    if not m.attrParsed then
        m.attributes = {}
        m.ParseAttributes(m.attributes)
        m.attrParsed = true
    end
    return m.attributes[attrName] ~= nil
end

---@param attrName string
---@param defValue string @default: nil
---@return string
function XMLIterator.GetAttribute(attrName, defValue)
    if not m.attrParsed then
        m.attributes = {}
        m.ParseAttributes(m.attributes)
        m.attrParsed = true
    end

    local value = m.attributes[attrName]
    if nil ~= value then
        return value
    end
    return defValue
end

---@param attrName string
---@param defValue number @default: 0
---@return number
function XMLIterator.GetAttributeInt(attrName, defValue)
    defValue = defValue or 0

    local value = m.GetAttribute(attrName)
    if value == nil or #value == 0 then
        return defValue
    end

    local ret = tonumber(value)
    if nil ~= ret then
        return ret
    end
    return defValue
end

XMLIterator.GetAttributeFloat = XMLIterator.GetAttributeInt

---@param attrName string
---@param defValue boolean @default: false
---@return boolean
function XMLIterator.GetAttributeBool(attrName, defValue)
    defValue = defValue or false

    local value = m.GetAttribute(attrName)
    if value == nil or #value == 0 then
        return defValue
    end

    value = string.lower(value)
    if value == 'true' then
        return true
    end
    if value == 'false' then
        return false
    end
    return defValue
end

---@param result table<string, string>
---@return table<string, string>
function XMLIterator.GetAttributes(result)
    if result == nil then
        result = {}
    end

    if m.attrParsed then
        for i, v in pairs(m.attributes) do
            result[i] = v
        end
    else
        m.ParseAttributes(result)
    end

    return result
end

---@param attrs table<string, string>
function XMLIterator.ParseAttributes(attrs)
    local attrName
    local valueStart
    local valueEnd
    local waitValue = false
    local quoted
    m.buffer = ''
    local i = m.tagPos
    local attrEnd = m.tagPos + m.tagLength

    if i < attrEnd and m.source[i] == '<' then
        while i < attrEnd do
            local c = m.source[i]
            if c:isSpace() or c == '>' or c == '/' then
                break
            end
            i = i + 1
        end
    end

    while i < attrEnd do
        local c = m.source[i]
        if c == '=' then
            valueStart = -1
            valueEnd = -1
            quoted = 0
            for j = i + 1, attrEnd do
                local c2 = m.source[j]
                if c2:isSpace() then
                    if valueStart ~= -1 and quoted == 0 then
                        valueEnd = j - 1
                        break
                    end
                elseif c2 == '>' then
                    if quoted == 0 then
                         valueEnd = j - 1
                        break
                    end
                elseif c2 == '"' then
                    if valueStart ~= -1 then
                        if quoted ~= 1 then
                            valueEnd = j - 1
                            break
                        end
                    else
                        quoted = 2
                        valueStart = j + 1
                    end
                elseif c2 == "'" then
                    if valueStart ~= -1 then
                        if quoted ~= 2 then
                            valueEnd = j - 1
                            break
                        end
                    else
                        quoted = 1
                        valueStart = j + 1
                    end
                elseif valueStart == -1 then
                    valueStart = j
                end
            end

            if valueStart ~= -1 and valueEnd ~= -1 then
                attrName = m.buffer
                if m.lowerCaseName then
                    attrName = string.lower(attrName)
                end
                m.buffer = ''
                attrs[attrName] = XMLUtils.DecodeString(m.source(valueStart, valueEnd + 1))
                i = valueEnd + 1
            else
                break
            end
        elseif not c:isSpace() then
            if waitValue or c == '/' or c == '>' then
                if #m.buffer > 0 then
                    attrName = m.buffer
                    if m.lowerCaseName then
                        attrName = string.lower(attrName)
                    end
                    m.buffer = ''
                    attrs[attrName] = ''
                end
                waitValue = false
            end
            if  c ~= '/' and c ~= '>' then
                m.buffer = m.buffer .. c
            end
        else
            if #m.buffer > 0 then
                waitValue = true
            end
        end

        i = i + 1
    end
end


Utils.XMLTagType = XMLTagType
Utils.XMLIterator = XMLIterator
return XMLIterator