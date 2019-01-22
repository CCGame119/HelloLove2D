--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 14:56
--

local Class = require('libs.Class')
require('Utils.Html.HtmlElement')

local Color = Love2DEngine.Color
local Rect = Love2DEngine.Rect

local ToolSet = Utils.ToolSet
local HtmlElementType = Utils.HtmlElementType
local HtmlParser = Utils.HtmlParser

local DisplayObject = FairyGUI.DisplayObject
local TextFormat = FairyGUI.TextFormat
local UIContentScaler = FairyGUI.UIContentScaler
local NGraphics = FairyGUI.NGraphics
local InputTextField = FairyGUI.InputTextField
local UIConfig = FairyGUI.UIConfig
local FontManager = FairyGUI.FontManager
local GlyphInfo = FairyGUI.GlyphInfo
local AutoSizeType = FairyGUI.AutoSizeType
local VertAlignType = FairyGUI.VertAlignType
local DynamicFont = FairyGUI.DynamicFont
local RTLSupport = FairyGUI.RTLSupport


---@class FairyGUI.TextField.LineInfo:ClassType
---@field public width number @行的宽度
---@field public height number @行的高度
---@field public textHeight number @行内文本的高度
---@field public charIndex number @行首的字符索引
---@field public charCount number @行包括的字符个数
---@field public y number @行的y轴位置
---@field public y2 number @行的y轴位置的备份
local LineInfo = Class.inheritsFrom('LineInfo')

LineInfo.pool = {}

---@return FairyGUI.TextField.LineInfo
function LineInfo.Borrow() end

---@param value FairyGUI.TextField.LineInfo
function LineInfo.Return(value)

end

---@param values FairyGUI.TextField.LineInfo[]
function LineInfo.Return(values)

end

---@class FairyGUI.TextField.CharPosition:ClassType
---@field public charIndex number @字符索引
---@field public lineIndex number @字符所在的行索引
---@field public offsetX number @字符的x偏移
---@field public vertCount number @字符占用的顶点数量。如果小于0，用于表示一个图片。对应的图片索引为-vertCount-1
local CharPosition = Class.inheritsFrom('CharPosition')

---@class FairyGUI.TextField:FairyGUI.DisplayObject
---@field public textFormat FairyGUI.TextFormat
---@field public align FairyGUI.AlignType
---@field public verticalAlign FairyGUI.VertAlignType
---@field public text string
---@field public htmlText string
---@field public parsedText string
---@field public autoSize FairyGUI.AutoSizeType
---@field public wordWrap boolean
---@field public singleLine boolean
---@field public stroke number
---@field public strokeColor Love2DEngine.Color
---@field public shadowOffset Love2DEngine.Vector2
---@field public textWidth number
---@field public textHeight number
---@field public htmlElements Utils.HtmlElement[]
---@field public lines FairyGUI.TextField.LineInfo[]
---@field public charPositions FairyGUI.TextField.CharPosition[]
---@field public richTextField FairyGUI.RichTextField
---@field private _verticalAlign FairyGUI.VertAlignType
---@field private _textFormat FairyGUI.TextFormat
---@field private _input boolean
---@field private _text string
---@field private _autoSize FairyGUI.AutoSizeType
---@field private _wordWrap boolean
---@field private _singleLine boolean
---@field private _html boolean
---@field private _rtl boolean
---@field private _stroke number
---@field private _strokeColor Love2DEngine.Color
---@field private _shadowOffset Love2DEngine.Vector2
---@field private _elements Utils.HtmlElement[]
---@field private _lines  FairyGUI.TextField.LineInfo[]
---@field private _charPositions FairyGUI.TextField.CharPosition[]
---@field private _font FairyGUI.BaseFont
---@field private _textWidth number
---@field private _textHeight number
---@field private _minHeight number
---@field private _textChanged boolean
---@field private _yOffset number
---@field private _fontSizeScale number
---@field private _renderScale number
---@field private _parsedText string
---@field private _richTextField FairyGUI.RichTextField
local TextField = Class.inheritsFrom('TextField', nil, DisplayObject)

TextField.GUTTER_X = 2
TextField.GUTTER_Y = 2

TextField.STROKE_OFFSET = {
    -1, 0, 1, 0,
    0, -1, 0, 1
}

TextField.BOLD_OFFSET = {
    -0.5, 0, 0.5, 0,
    0, -0.5, 0, 0.5
}

function TextField:__ctor()
    self._touchDisabled = true

    self._textFormat = TextFormat.new()
    self._strokeColor = Color.black
    self._fontSizeScale = 1
    self._renderScale = UIContentScaler.scaleFactor

    self._wordWrap = false
    self._text = ''
    self._parsedText = ''

    self._elements = {}
    self._lines = {}

    self:CreateGameObject("TextField")
    self.graphics = NGraphics.new(self.gameObject)
end

---@param richTextField FairyGUI.RichTextField
function TextField:EnableRichSupport(richTextField)
    self._richTextField = richTextField

    if richTextField:isa(InputTextField) then
        self._input = true
        self:EnableCharPositionSupport()
    end
end

function TextField:EnableCharPositionSupport()
    if self._charPositions == nil then
        self._charPositions = {}
        self._textChanged = true
    end
end

---@return boolean
function TextField:Redraw()
    if (self._font == nil) then
        self._font = FontManager.GetFont(UIConfig.defaultFont)
        self.graphics:SetShaderAndTexture(self._font.shader, self._font.mainTexture)
        self._textChanged = true
    end

    if (self._font.keepCrisp and self._renderScale ~= UIContentScaler.scaleFactor) then
        self._textChanged = true
    end

    if (self._font.mainTexture ~= self.graphics.texture) then
        if (not self._textChanged) then
            self:RequestText()
        end
        self.graphics.texture = self._font.mainTexture
        self._requireUpdateMesh = true
    end

    if (self._textChanged) then
        self:BuildLines()
    end

    if (self._requireUpdateMesh) then
        self:BuildMesh()
        return true
    else
        return false
    end
end

---@param startLine number
---@param startCharX number
---@param endLine number
---@param endCharX number
---@param clipped boolean
---@param resultRects Love2dEngine.Rect[]
function TextField:GetLinesShape(startLine, startCharX, endLine, endCharX,
                                 clipped, resultRects)
    local line1 = self._lines[startLine]
    local line2 = self._lines[endLine]
    if (startLine == endLine) then
        local r = Rect.MinMaxRect(startCharX, line1.y, endCharX, line1.y + line1.height)
        if (clipped) then
            resultRects:Add(ToolSet.Intersection(r, self._contentRect))
        else
            resultRects:Add(r)
        end
    elseif (startLine == endLine - 1) then
        local r = Rect.MinMaxRect(startCharX, line1.y, TextField.GUTTER_X + line1.width, line1.y + line1.height)
        if (clipped) then
            resultRects:Add(ToolSet.Intersection(r, self._contentRect))
        else
            resultRects:Add(r)
        end
        r = Rect.MinMaxRect(TextField.GUTTER_X, line1.y + line1.height, endCharX, line2.y + line2.height)
        if (clipped) then
            resultRects:Add(ToolSet.Intersection(r, self._contentRect))
        else
            resultRects:Add(r)
        end
    else
        local r = Rect.MinMaxRect(startCharX, line1.y, TextField.GUTTER_X + line1.width, line1.y + line1.height)
        if (clipped) then
            resultRects:Add(ToolSet.Intersection(r, self._contentRect))
        else
            resultRects:Add(r)
        end
        for i = startLine + 1, endLine do
            local line = self._lines[i]
            r = Rect.MinMaxRect(TextField.GUTTER_X, r.yMax, TextField.GUTTER_X + line.width, line.y + line.height)
            if (clipped) then
                resultRects:Add(ToolSet.Intersection(r, self._contentRect))
            else
                resultRects:Add(r)
            end
        end
        r = Rect.MinMaxRect(TextField.GUTTER_X, r.yMax, endCharX, line2.y + line2.height)
        if (clipped) then
            resultRects:Add(ToolSet.Intersection(r, self._contentRect))
        else
            resultRects:Add(r)
        end
    end
end

function TextField:OnSizeChanged(widthChanged, heightChanged)
    if (not self._updatingSize) then
        self._minHeight = self._contentRect.height

        if (self._wordWrap and widthChanged) then
            self._textChanged = true
        elseif (self._autoSize ~= AutoSizeType.None) then
            self._requireUpdateMesh = true
        end

        if (self._verticalAlign ~= VertAlignType.Top) then
            self:ApplyVertAlign()
        end
    end

    DisplayObject.OnSizeChanged(self, widthChanged, heightChanged)
end

function TextField:EnsureSizeCorrect()
    if (self._textChanged and self._autoSize ~= AutoSizeType.None) then
        self:BuildLines()
    end
end

function TextField:Update(context)
    if (self._richTextField == nil) then --如果是richTextField，会在update前主动调用了Redraw
        self:Redraw()
        DisplayObject.Update(self, context)
    end
end

---准备字体纹理
function TextField:RequestText()
    if (not self._html) then
        self._font:SetFormat(self._textFormat, self._fontSizeScale)
        self._font:PrepareCharacters(self._parsedText)
        self._font:PrepareCharacters("_-*")
    else
        local count = #self._elements
        for i = 1, count do
            local element = self._elements[i]
            if (element.type == HtmlElementType.Text) then
                self._font:SetFormat(element.format, self._fontSizeScale)
                self._font:PrepareCharacters(element.text)
                self._font:PrepareCharacters("_-*")
            end
        end
    end

    if(self._font:isa(DynamicFont) and DynamicFont.textRebuildFlag) then
        self.graphics.texture = self._font.mainTexture
    end
end

function TextField:BuildLines()
    local GUTTER_X, GUTTER_Y = TextField.GUTTER_X, TextField.GUTTER_Y

    self._textChanged = false
    self._requireUpdateMesh = true
    self._renderScale = UIContentScaler.scaleFactor

    self.Cleanup()

    if (string.len(self._text) == 0) then
        local emptyLine = LineInfo.Borrow()
        emptyLine.width, emptyLine.height = 0, 0
        emptyLine.charIndex, emptyLine.charCount = 0, 0
        emptyLine.y, emptyLine.y2 = GUTTER_Y, GUTTER_Y
        table.insert(self._lines, emptyLine)

        self._textWidth, self._textHeight = 0, 0
        self._fontSizeScale = 1

        self:BuildLinesFinal()

        return
    end

    self:ParseText()

    local letterSpacing = self._textFormat.letterSpacing
    local lineSpacing = self._textFormat.lineSpacing - 1
    local rectWidth = self._contentRect.width - GUTTER_X * 2
    local glyphWidth, glyphHeight = 0, 0
    local wordChars = 0
    local wordStart = 0
    local wordPossible = false
    local supSpace, subSpace = 0, 0

    local format = self._textFormat
    self._font:SetFormat(format, self._fontSizeScale)
    local wrap
    if (self._input) then
        if RTL_TEXT_SUPPORT then
            letterSpacing = letterSpacing + 1
        end
        wrap = not self._singleLine
    else
        wrap = self._wordWrap and not self._singleLine
    end
    self._fontSizeScale = 1

    self:RequestText()

    local elementCount = #self._elements
    local elementIndex = 0
    local element = nil
    if (elementCount > 0) then
        element = self._elements[elementIndex]
    end
    local textLength = #self._parsedText

    local line = LineInfo.Borrow()
    table.insert(self._lines, line)
    line.y,line.y2 = GUTTER_Y, GUTTER_Y


    for charIndex = 1, textLength do
        local ch = self._parsedText[charIndex]

        glyphWidth, glyphHeight = 0, 0

        while (element ~= nil and element.charIndex == charIndex) do
            if (element.type == HtmlElementType.Text) then
                format = element.format
                self._font.SetFormat(format, self._fontSizeScale)
            else
                local htmlObject = nil
                if (self._richTextField ~= nil) then
                    element.space = math.floor(rectWidth - line.width - 4)
                    htmlObject = self._richTextField.htmlPageContext:CreateObject(self._richTextField, element)
                    element.htmlObject = htmlObject
                end
                if (htmlObject ~= nil) then
                    glyphWidth = math.floor(htmlObject.width)
                    glyphHeight = math.floor(htmlObject.height)

                    glyphWidth = glyphWidth + 2
                end

                if (element.isEntity) then
                    ch = '\0' --字符只是用作占位，不需要显示
                end
            end

            elementIndex = elementIndex + 1
            if (elementIndex < elementCount) then
                element = self._elements[elementIndex]
            else
                element = nil
            end
        end

        line.charCount = line.charCount + 1
        if (ch == '\0' or ch == '\n') then
            wordChars = 0
            wordPossible = false
        else
            if (string.isSpace(ch)) then
                wordChars = 0
                wordPossible = true
            elseif (wordPossible and (ch >= 'a' and ch <= 'z' or ch >= 'A' and ch <= 'Z' or ch >= '0' and ch <= '9' or ch == '.'
                    or (RTL_TEXT_SUPPORT and self._rtl and RTLSupport.IsArabicLetter(ch)))) then
                if (wordChars == 0) then
                    wordStart = line.width
                elseif (wordChars > 10) then
                    wordChars = short.MinValue
                end
                wordChars = wordChars + 1
            else
                wordChars = 0
                wordPossible = false
            end

            if (self._font:GetGlyphSize(ch, glyphWidth, glyphHeight)) then
                if (glyphHeight > line.textHeight) then
                    line.textHeight = glyphHeight
                end

                if (format.specialStyle == TextFormat.SpecialStyle.Subscript) then
                    subSpace = math.floor(glyphHeight * 0.333)
                elseif (format.specialStyle == TextFormat.SpecialStyle.Superscript) then
                    supSpace = math.floor(glyphHeight * 0.333)
                end
            end
        end

        if (glyphWidth > 0) then
            if (glyphHeight > line.height) then
                line.height = glyphHeight
            end

            if (line.width ~= 0) then
                line.width = line.width + letterSpacing
            end
            line.width = line.width + glyphWidth
        end

        if (ch == '\n' or wrap and line.width > rectWidth and format.specialStyle == TextFormat.SpecialStyle.None) then
            if (line.textHeight == 0) then
                if (line.height == 0) then
                    if (#self._lines == 1) then
                        line.height = format.size
                    else
                        line.height = self._lines[#self._lines - 1].height
                    end
                end
                line.textHeight = line.height
            end
            if (supSpace ~= 0) then
                line.height = math.max(line.textHeight + supSpace, line.height)
            end

            local newLine = LineInfo.Borrow()
            table.insert(self._lines, newLine)
            newLine.y = line.y + (line.height + lineSpacing)
            if (newLine.y < GUTTER_Y) then
                newLine.y = GUTTER_Y
            end
            newLine.y2 = newLine.y

            if (ch == '\n' or line.charCount == 1) then --the line cannt fit even a char
                wordChars = 0
                wordPossible = false
            elseif (wordChars > 0 and wordStart > 0) then --if word had broken, move it to new line
                newLine.charCount = wordChars
                newLine.width = line.width - wordStart
                newLine.height = line.height
                newLine.textHeight = line.textHeight

                line.charCount = line.charCount - wordChars
                line.width = wordStart

                wordStart = 0
            else --move last char to new line
                newLine.charCount = 1
                newLine.width = glyphWidth
                newLine.height = glyphHeight
                if (ch ~= '\0') then
                    newLine.textHeight = newLine.height
                end

                line.charCount = line.charCount - 1
            line.width = line.width - (glyphWidth + letterSpacing)

            wordChars = 0
            wordPossible = false
            end

            newLine.charIndex = math.floor(line.charIndex + line.charCount)
            if (line.width > self._textWidth) then
                self._textWidth = line.width
            end

            if (subSpace ~= 0 and subSpace > lineSpacing) then
                supSpace = subSpace - (lineSpacing > 0 and lineSpacing or 0)
            end

            subSpace = 0

            line = newLine
        end
    end

    line = self._lines[#self._lines]
    if (line.textHeight == 0) then
        if (line.height == 0) then
            if (#self._lines == 1) then
                line.height = format.size
            else
                line.height = self._lines[#self._lines - 1].height
            end
        end
        line.textHeight = line.height
    end
    if (subSpace > 0) then
        line.height = line.height + subSpace
    end

    if (line.width > self._textWidth) then
        self._textWidth = line.width
    end
    if (self._textWidth > 0) then
        self._textWidth = self._textWidth + GUTTER_X * 2
    end
    self._textHeight = line.y + line.height + GUTTER_Y

    self._textWidth = math.ceil(self._textWidth)
    self._textHeight = math.ceil(self._textHeight)


    if (self._autoSize == AutoSizeType.Shrink and self._textWidth > rectWidth) then
        self._fontSizeScale = rectWidth / self._textWidth
        self._textWidth = rectWidth
        self._textHeight = math.ceil(self._textHeight * self._fontSizeScale)

        --调整各行的大小
        local lineCount = #self._lines
        for i = 1, lineCount do
            line = self._lines[i]
            line.y = line.y * self._fontSizeScale
            line.y2 = line.y2 * self._fontSizeScale
            line.height = line.height * self._fontSizeScale
            line.width = line.width * self._fontSizeScale
            line.textHeight = line.textHeight * self._fontSizeScale
        end
    else
        self._fontSizeScale = 1
    end

    self:BuildLinesFinal()
end

---@overload fun()
---@param buffer string
---@param source string
---@param elementIndex number
---@return number
function TextField:ParseText(buffer, source, elementIndex)
    if self._html then
        HtmlParser.inst:Parse(self._text, self._textFormat, self._elements,
                self._richTextField ~= nil and self._richTextField.htmlParseOptions or nil)
        self._parsedText = ""
    else
        self._parsedText = self._text
    end

    local elementCount = #self._elements
    if elementCount == 0 then
        local flag = self._input or self._richTextField ~= nil and self._richTextField.emojies ~= nil
        if not flag then
            -- 检查文本中是否有需要转换的字符，如果没有，节省一个new StringBuilder的操作。
            local cnt = #self._parsedText
            for i = 1, cnt do
                local ch = self._parsedText[i]
                if (ch == '\r' or ch == '\t' or string.isHighSurrogate(ch)) then
                    flag = true
                    break
                end
            end
        end

        if flag then

        end
    else
    end
end

TextField._updatingSize = false

function TextField:BuildLinesFinal()
    if (not self._input and self._autoSize == AutoSizeType.Both) then
        self._updatingSize = true
        if (self._richTextField ~= nil) then
            self._richTextField:SetSize(self._textWidth, self._textHeight)
        else
            self:SetSize(self._textWidth, self._textHeight)
        end

        self._updatingSize = false
    elseif (self._autoSize == AutoSizeType.Height) then
        self._updatingSize = true
        local h = self._textHeight
        if (self._input and h < self._minHeight) then
            h = self._minHeight
        end

        if (self._richTextField ~= nil) then
            self._richTextField.height = h
        else
            self.height = h
        end
        self._updatingSize = false
    end

    self._yOffset = 0
    self:ApplyVertAlign()
end

TextField.sCachedVerts = {}
TextField.sCachedUVs = {}
TextField.sCachedCols = {}
TextField.glyph = GlyphInfo.new()
TextField.glyph2 = GlyphInfo.new()

function TextField:BuildMesh()

end

function TextField:Cleanup()

end

function TextField:ApplyVertAlign()

end

--TODO: FairyGUI.TextField

local __get = Class.init_get(TextField)
local __set = Class.init_set(TextField)

---@param self FairyGUI.TextField
__get.textFormat = function(self)
    return self._textFormat
end

---@param self FairyGUI.TextField
---@param val FairyGUI.VertAlignType
__set.textFormat = function(self, val)
    self._textFormat = val
    local fontName = self._textFormat.font
    if string.isNullOrEmpty(fontName) then
        fontName = UIConfig.defaultFont
    end
    if self._font == nil or self._font.name ~= fontName then
        self._font = FontManager.GetFont(fontName)
        self.graphics:SetShaderAndTexture(self._font.shader, self._font.mainTexture)
    end
    if not string.isNullOrEmpty(self._text) then
        self._textChanged = true
    end
end

---@param self FairyGUI.TextField
__get.align = function(self)
    return self._textFormat.align
end

---@param self FairyGUI.TextField
---@param val FairyGUI.VertAlignType
__set.align = function(self, val)
    if self._textFormat.align ~= val then
        self._textFormat.align = val
        if not string.isNullOrEmpty(self._text) then
            self._textChanged = true
        end
    end
end

---@param self FairyGUI.TextField
__get.verticalAlign = function(self)
    return self._verticalAlign
end

---@param self FairyGUI.TextField
---@param val FairyGUI.VertAlignType
__set.verticalAlign = function(self, val)
    if self._verticalAlign ~= val then
        self._verticalAlign = val
        self:ApplyVertAlign()
    end
end

---@param self FairyGUI.TextField
__get.text = function(self)
    return self._text
end

---@param self FairyGUI.TextField
---@param val Love2DEngine.Vector2
__set.text = function(self, val)
    self._text = val
    self._textChanged = true
    self._html = false
end

---@param self FairyGUI.TextField
__get.htmlText = function(self)
    return self._text
end

---@param self FairyGUI.TextField
---@param val string
__set.htmlText = function(self, val)
    self._text = val
    self._textChanged = true
    self._html = true
end

---@param self FairyGUI.TextField
__get.parsedText = function(self)
    return self._parsedText
end

---@param self FairyGUI.TextField
__get.autoSize = function(self)
    return self._autoSize
end

---@param self FairyGUI.TextField
---@param val FairyGUI.AutoSizeType
__set.autoSize = function(self, val)
    self._autoSize = val
    self._textChanged = true
end

---@param self FairyGUI.TextField
__get.wordWrap = function(self)
    return self._wordWrap
end

---@param self FairyGUI.TextField
---@param val boolean
__set.wordWrap = function(self, val)
    self._wordWrap = val
    self._textChanged = true
end

---@param self FairyGUI.TextField
__get.singleLine = function(self)
    return self._singleLine
end

---@param self FairyGUI.TextField
---@param val boolean
__set.singleLine = function(self, val)
    self._singleLine = val
    self._textChanged = true
end

---@param self FairyGUI.TextField
__get.stroke = function(self)
    return self._stroke
end

---@param self FairyGUI.TextField
---@param val number
__set.stroke = function(self, val)
    if self._stroke ~= val then
        self._stroke = val
        self._requireUpdateMesh = true
    end
end

---@param self FairyGUI.TextField
__get.strokeColor = function(self)
    return self._strokeColor
end

---@param self FairyGUI.TextField
---@param val Love2DEngine.Color
__set.strokeColor = function(self, val)
    if self._strokeColor ~= val then
        self._strokeColor = val
        self._requireUpdateMesh = true
    end
end

---@param self FairyGUI.TextField
__get.shadowOffset = function(self)
    return self._shadowOffset
end

---@param self FairyGUI.TextField
---@param val Love2DEngine.Vector2
__set.shadowOffset = function(self, val)
    self._shadowOffset = val
    self._requireUpdateMesh = true
end

---@param self FairyGUI.TextField
__get.textWidth = function(self)
    if self._textChanged then
        self:BuildLines()
    end
    return self._textWidth
end

---@param self FairyGUI.TextField
__get.textHeight = function(self)
    if self._textChanged then
        self:BuildLines()
    end
    return self._textHeight
end

---@param self FairyGUI.TextField
__get.htmlElements = function(self)
    if self._textChanged then
        self:BuildLines()
    end
    return self._elements
end

---@param self FairyGUI.TextField
__get.lines = function(self)
    if self._textChanged then
        self:BuildLines()
    end
    return self._lines
end

---@param self FairyGUI.TextField
__get.charPositions = function(self)
    if self._textChanged then
        self:BuildLines()
    end
    if self._requireUpdateMesh then
        self:BuildMesh()
    end
    return self._charPositions
end

---@param self FairyGUI.TextField
__get.richTextField = function(self) return self._richTextField end


FairyGUI.TextField = TextField
return TextField