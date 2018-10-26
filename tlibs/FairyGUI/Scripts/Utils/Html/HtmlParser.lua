--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:24
--

local Class = require('libs.Class')

local Color32 = Love2DEngine.Color32
local TextFormat = FairyGUI.TextFormat
local ToolSet = Utils.ToolSet
local AlignType = FairyGUI.AlignType
local XMLIterator = Utils.XMLIterator
local XMLTagType = Utils.XMLTagType
local HtmlElement = Utils.HtmlElement
local HtmlElementType = Utils.HtmlElementType

local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

---@class Utils.HtmlParser.TextFormat2:FairyGUI.TextFormat
---@field colorChanged boolean
local TextFormat2 = Class.inheritsFrom('TextFormat2', nil, TextFormat)

---@class Utils.HtmlParser:ClassType
---@field protected _textFormatStack Utils.HtmlParser.TextFormat2[]
---@field protected _textFormatStackTop number
---@field protected _format Utils.HtmlParser.TextFormat2
---@field protected _elements Utils.HtmlElement[]
---@field protected _defaultOptions HtmlParseOptions
local HtmlParser = Class.inheritsFrom('HtmlParser')

HtmlParser.inst = HtmlParser.new()

---@type string[]
HtmlParser.sHelperList1 = {}
---@type string[]
HtmlParser.sHelperList1 = {}

function HtmlParser:__ctor()
    self._textFormatStack = {}
    self._format = TextFormat2.new()
    self._defaultOptions = HtmlParseOptions.new()
end

---@param aSource string
---@param defaultFormat FairyGUI.TextFormat
---@param elements Utils.HtmlElement[]
---@param parseOptions Utils.HtmlParseOptions
function HtmlParser:Parse(aSource, defaultFormat, elements, parseOptions)
    if parseOptions == nil then
        parseOptions = self._defaultOptions
    end

    self._elements = elements
    self._textFormatStackTop = 1
    self._format:CopyFrom(defaultFormat)
    self._format.colorChanged = false
    local skipText =0
    local ignoreWhiteSpace = parseOptions.ignoreWhiteSpace
    local skipNextCR = false
    local text = ''

    XMLIterator.Begin(aSource, true)
    while XMLIterator.NextTag() do
        if skipText == 0 then
            text = XMLIterator.GetText(ignoreWhiteSpace)
            if string.len(text) > 0 then
                if skipNextCR and text[1] == '\n' then
                     text = string.sub(text, 2)
                end
                self:AppendText(text)
            end
        end

        skipNextCR = false
        if XMLIterator.tagName == 'b' then
            if XMLIterator.tagType == XMLTagType.Start then
                self:PushTextFormat()
                self._format.bold = true
            else
                self:PopTextFormat()
            end
        elseif XMLIterator.tagName == 'i' then
            if XMLIterator.tagType == XMLTagType.Start then
                self:PushTextFormat()
                self._format.italic = true
            else
                self:PopTextFormat()
            end
        elseif XMLIterator.tagName == 'u' then
            if XMLIterator.tagType == XMLTagType.Start then
                self:PushTextFormat()
                self._format.underline = true
            else
                self:PopTextFormat()
            end
        elseif XMLIterator.tagName == 'sub' then
            if XMLIterator.tagType == XMLTagType.Start then
                self:PushTextFormat()
                self._format.size = math.ceil(self._format.size * 0.58)
                self._format.specialStyle = TextFormat.SpecialStyle.Subscript
            else
                self:PopTextFormat()
            end
        elseif XMLIterator.tagName == 'sup' then
            if XMLIterator.tagType == XMLTagType.Start then
                self:PushTextFormat()
                self._format.size = math.ceil(self._format.size * 0.58)
                self._format.specialStyle = TextFormat.SpecialStyle.Superscript
            else
                self:PopTextFormat()
            end
        elseif XMLIterator.tagName == 'font' then
            if XMLIterator.tagType == XMLTagType.Start then
                self:PushTextFormat()

                self._format.size = XMLIterator.GetAttributeInt("size", self._format.size)
                local color = XMLIterator.GetAttribute("color")
                if color ~= nil then
                    local parts = string.split(color, ',')
                    if #parts == 1 then
                        self._format.color = ToolSet.ConvertFromHtmlColor(color)
                        self._format.gradientColor = nil
                        self._format.colorChanged = true
                    else
                        if self._format.gradientColor == nil then
                            self._format.gradientColor = {}
                        end
                        self._format.gradientColor[1] = ToolSet.ConvertFromHtmlColor(parts[1])
                        self._format.gradientColor[2] = ToolSet.ConvertFromHtmlColor(parts[2])
                        if #parts > 2 then
                            self._format.gradientColor[3] = ToolSet.ConvertFromHtmlColor(parts[3])
                            if #parts > 3 then
                                self._format.gradientColor[4] = ToolSet.ConvertFromHtmlColor(parts[4])
                            else
                                self._format.gradientColor[4] = ToolSet.ConvertFromHtmlColor(parts[3])
                            end
                        else
                            self._format.gradientColor[3] = ToolSet.ConvertFromHtmlColor(parts[1])
                            self._format.gradientColor[4] = ToolSet.ConvertFromHtmlColor(parts[2])
                        end
                    end
                end
            elseif XMLIterator.tagType == XMLTagType.End then
                self:PopTextFormat()
            end
        elseif XMLIterator.tagName == 'br' then
            self:AppendText('\n')
        elseif XMLIterator.tagName == 'img' then
            if XMLIterator.tagType == XMLTagType.Start or XMLIterator.tagType == XMLTagType.Void then
                local element = HtmlElement.GetElement(HtmlElementType.Image)
                element:FetchAttributes()
                element.name = element:GetString('name')
                element.format.align = self._format.align
                table.insert(self._elements, element)
            end
        elseif XMLIterator.tagName == 'a' then
            if XMLIterator.tagType == XMLTagType.Start then
                 self:PushTextFormat()

                self._format.underline = bor(self._format.underline, parseOptions.linkUnderline)
                if not self._format.colorChanged and parseOptions.linkColor.a ~= 0 then
                    self._format.color = parseOptions.linkColor
                end

                local element = HtmlParser.GetElement(HtmlElementType.Link)
                element:FetchAttributes()
                element.name = element:GetString('name')
                element.format.align = self._format.align
                table.insert(self._elements, element)
            elseif XMLIterator.tagType == XMLTagType.End then
                self:PopTextFormat()

                local element = HtmlElement.GetElement(HtmlElementType.LinkEnd)
                table.insert(self._elements, element)
            end
        elseif XMLIterator.tagName == 'input' then
            local element = HtmlElement.GetElement(HtmlElementType.Input)
            element:FetchAttributes()
            element.name = element:GetString("name")
            element.format:CopyFrom(self._format)
            table.insert(self._elements, element)
        elseif XMLIterator.tagName == 'select' then
            if XMLIterator.tagType == XMLTagType.Start or XMLIterator.tagType == XMLTagType.Void then
                local element = HtmlElement.GetElement(HtmlElementType.Select)
                element:FetchAttributes()
                if XMLIterator.tagType == XMLTagType.Start then
                    HtmlParser.sHelperList1 = {}
                    HtmlParser.sHelperList2 = {}
                    while XMLIterator.NextTag() do
                        if XMLIterator.tagName == "select" then
                            break
                        end

                        if XMLIterator.tagName == "option" then
                            if XMLIterator.tagType == XMLTagType.Start or XMLIterator.tagType == XMLTagType.Void then
                                table.insert(HtmlParser.sHelperList2, XMLIterator.GetAttribute("value", ''))
                            else
                                table.insert(HtmlParser.sHelperList1, XMLIterator.GetText())
                            end
                        end
                    end
                    element:Set("items", table.clone(HtmlParser.sHelperList1))
                    element:Set("values", table.clone(HtmlParser.sHelperList2))
                end
                element.name = element:GetString("name")
                element.format:CopyFrom(self._format)
                table.insert(self._elements, element)
            end
        elseif XMLIterator.tagName == 'p' then
            if XMLIterator.tagType == XMLTagType.Start then
                self:PushTextFormat()
                local align = XMLIterator.GetAttribute("align")
                if align == "center" then
                    self._format.align = AlignType.Center
                elseif align == "right" then
                    self._format.align = AlignType.Right
                end
                if not self:IsNewLine() then
                    self:AppendText("\n")
                end
            elseif XMLIterator.tagType == XMLTagType.End then
                self:AppendText("\n")
                skipNextCR = true

                self:PopTextFormat()
            end
        elseif XMLIterator.tagName == 'ui' or XMLIterator.tagName == 'div' or XMLIterator.tagName == 'li' then
            if XMLIterator.tagType == XMLTagType.Start then
                if not self:IsNewLine() then
                    self:AppendText("\n")
                end
            else
                self:AppendText("\n")
                skipNextCR = true
            end
        elseif XMLIterator.tagName == 'html' or XMLIterator.tagName == 'body' then
            ignoreWhiteSpace = true
        elseif XMLIterator.tagName == 'head' or XMLIterator.tagName == 'style' or XMLIterator.tagName == 'script' or        
                XMLIterator.tagName == 'form' then
            if XMLIterator.tagType == XMLTagType.Start then
                skipText = skipText + 1
            elseif XMLIterator.tagType == XMLTagType.End then
                skipText = skipText - 1
            end
        end
    end

    if skipText == 0 then
         text = XMLIterator.GetText(ignoreWhiteSpace)
        if string.len(text) > 0 then
            if skipNextCR and text[1] == '\n' then
                text = string.sub(text, 2)
            end
            self:AppendText(text)
        end
    end

    self._elements = nil
end

function HtmlParser:PushTextFormat()
    local tf
    if #self._textFormatStack <= self._textFormatStackTop then
        tf = TextFormat2.new()
        table.insert(self._textFormatStack, tf)
    else
        tf = self._textFormatStack[self._textFormatStackTop]
    end
    
    tf.CopyFrom(self._format)
    tf.colorChanged = self._format.colorChanged
    self._textFormatStackTop = self._textFormatStackTop + 1
end

function HtmlParser:PopTextFormat()
    if self._textFormatStackTop > 1 then
        local tf = self._textFormatStack[self._textFormatStackTop - 1]
        self._format:CopyFrom(tf)
        self._format.colorChanged = tf.colorChanged
        self._textFormatStackTop = self._textFormatStackTop - 1
    end
end

---@return boolean
function HtmlParser:IsNewLine()
    if #self._elements > 0 then
        local element = self._elements[#self._elements]
        if element ~= nil and element.type == HtmlElementType.Text then
            return string.endWith(element.text, '\n')
        else
            return false            
        end
    end

    return true
end

---@param text string
function HtmlParser:AppendText(text) 
    local element
    if #self._elements > 0 then
        element = self._elements[#self._elements]
        if element.type == HtmlElementType.Text and element.format:EqualStyle(self._format) then
            element.text = element.text + text
            return
        end
    end

    element = HtmlElement.GetElement(HtmlElementType.Text)
    element.text = text
    element.format:CopyFrom(self._format)
    table.insert(self._elements, element)
end


HtmlParser.TextFormat2 = TextFormat2
Utils.HtmlParser = HtmlParser
return HtmlParser