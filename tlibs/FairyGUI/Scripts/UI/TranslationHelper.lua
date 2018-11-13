--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:55
--

---@class dictString table<string, string>
local Class = require('libs.Class')

local ObjectType = FairyGUI.ObjectType

---@class FairyGUI.TranslationHelper:ClassType
local TranslationHelper = Class.inheritsFrom('TranslationHelper')

---@type table<string, dictString>
TranslationHelper.strings = nil

---@param source Utils.XML
function TranslationHelper.LoadFromXML(source)
    TranslationHelper.strings = {}
    local et = source:GetEnumerator("string")
    while et:MoveNext() do
        local cxml = et.Current
        local key = cxml:GetAttribute("name")
        local text = cxml.text
        local i = key:find("-", 1, true)
        if i ~= nil then
            local key2 = key(1, i - 1)
            local key3 = key(i + 1)
            local col = TranslationHelper.strings[key2]
            if nil == col then
                col = {}
                TranslationHelper.strings[key2] = col
            end
            col[key3] = text
        end
    end
end

---@param item FairyGUI.PackageItem
function TranslationHelper.TranslateComponent(item)
    if (TranslationHelper.strings == nil) then
        return
    end

    local strings = TranslationHelper.strings[item.owner.id .. item.id]
    if nil == strings then
        return
    end

    local elementId, value
    local buffer = item.rawData

    buffer:Seek(0, 2)

    local childCount = buffer:ReadShort()

    for i = 1, childCount do
        local dataLen = buffer:ReadShort()
        local curPos = buffer.position

        buffer:Seek(curPos, 0)

        ---@type FairyGUI.ObjectType
        local type = buffer:ReadByte()
        buffer:Skip(4)
        elementId = buffer:ReadS()

        if (type == ObjectType.Component) then
            if (buffer:Seek(curPos, 6)) then
                type = buffer:ReadByte()
            end
        end

        buffer:Seek(curPos, 1)

        value = strings[elementId .. "-tips"]
        if (nil ~= value) then
            buffer:WriteS(value)
        end

        buffer:Seek(curPos, 2)

        local gearCnt = buffer:ReadShort()
        for j = 1, gearCnt do
            local nextPos = buffer:ReadShort()
            nextPos = nextPos + buffer.position

            if (buffer:ReadByte() == 6) then --gearText
                buffer:Skip(2) --controller
                local valueCnt = buffer:ReadShort()
                for k = 1, valueCnt do
                    local page = buffer:ReadS()
                    if (page ~= nil) then
                        value = strings[elementId .. "-texts_" .. k]
                        if nil ~= value then
                            buffer:WriteS(value)
                        else
                            buffer:Skip(2)
                        end
                    end
                end
                value = strings[elementId .. "-texts_def"]
                if (buffer:ReadBool() and nil ~= value) then
                    buffer:WriteS(value)
                end
            end

            buffer.position = nextPos
        end

        if type == ObjectType.Text or
                type == ObjectType.RichText or
                type == ObjectType.InputText then
            value = strings[elementId]
            if nil ~= value then
                buffer:Seek(curPos, 6)
                buffer:WriteS(value)
            end
            value = strings[elementId .. "-prompt"]
            if nil ~= value then
                buffer:Seek(curPos, 4)
                buffer:WriteS(value)
            end
        elseif type == ObjectType.List then
            buffer:Seek(curPos, 8)
            buffer:Skip(2)
            local itemCount = buffer:ReadShort()
            for j = 1, itemCount do
                local nextPos = buffer:ReadShort()
                nextPos = nextPos + buffer.position

                buffer:Skip(2) --url
                value = strings[elementId .. "-" .. j]
                if nil ~= value then
                    buffer:WriteS(value)
                else
                    buffer:Skip(2)
                end
                value = strings[elementId .. "-" .. j .. "-0"]
                if nil ~= value then
                    buffer:WriteS(value)
                end
                buffer.position = nextPos
            end
        elseif type == ObjectType.Label then
            if (buffer:Seek(curPos, 6) and buffer:ReadByte() == type) then
                value = strings[elementId]
                if nil ~= value then
                    buffer:WriteS(value)
                else
                    buffer:Skip(2)
                end

                buffer:Skip(2)
                if buffer:ReadBool() then
                    buffer:Skip(4)
                end
                buffer:Skip(4)
                value = strings[elementId .. "-prompt"]
                if nil ~= value then
                    buffer:WriteS(value)
                end
            end
        elseif type == ObjectType.Button then
            if (buffer:Seek(curPos, 6) and buffer:ReadByte() == type) then
                value = strings[elementId]
                if nil ~= value then
                    buffer:WriteS(value)
                else
                    buffer:Skip(2)
                end
                value = strings[elementId .. "-0"]
                if nil ~= value then
                    buffer:WriteS(value)
                end
            end
        elseif type == ObjectType.ComboBox then
            if (buffer:Seek(curPos, 6) and buffer:ReadByte() == type) then
                local itemCount = buffer:ReadShort()
                for j = 1, itemCount do
                    local nextPos = buffer:ReadShort()
                    nextPos = nextPos + buffer.position

                    value = strings[elementId .. "-" .. j]
                    if nil ~= value then
                        buffer:WriteS(value)
                    end

                    buffer.position = nextPos
                end

                value = strings[elementId]
                if nil ~= value then
                    buffer:WriteS(value)
                end
            end
        end

        buffer.position = curPos + dataLen
    end
end


FairyGUI.TranslationHelper = TranslationHelper
return TranslationHelper