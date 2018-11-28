--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 15:56
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2
local Color = Love2DEngine.Color

local UBBParser = Utils.UBBParser
local XMLUtils = Utils.XMLUtils

local GObject = FairyGUI.GObject
local ITextColorGear = FairyGUI.ITextColorGear
local AutoSizeType = FairyGUI.AutoSizeType
local TextField = FairyGUI.TextField
local UIConfig = FairyGUI.UIConfig

---@class FairyGUI.GTextField:FairyGUI.GObject @implement FairyGUI.ITextColorGear
---@field public text string
---@field public templateVars table<string, string>
---@field public textFormat FairyGUI.TextFormat
---@field public color Love2DEngine.Color
---@field public align FairyGUI.AlignType
---@field public verticalAlign FairyGUI.VertAlignType
---@field public singleLine boolean
---@field public stroke number
---@field public strokeColor Love2DEngine.Color
---@field public shadowOffset Love2DEngine.Vector2
---@field public UBBEnabled boolean
---@field public autoSize FairyGUI.AutoSizeType
---@field public textWidth number
---@field public textHeight number
---@field protected _textField FairyGUI.TextField
---@field protected _text string
---@field protected _ubbEnabled boolean
---@field protected _updatingSize boolean
---@field protected _templateVars table<string, string>
local GTextField = Class.inheritsFrom('GTextField', nil, GObject, {ITextColorGear})

function GTextField:__ctor()
    GObject.__ctor(self)

    local tf = self._textField.textFormat
    tf.font = UIConfig.defaultFont
    tf.size = 12
    tf.color = Color.black
    tf.lineSpacing = 3
    tf.letterSpacing = 0
    self._textField.textFormat = tf

    self._text = ''
    self._textField.autoSize = AutoSizeType.Both
    self._textField.wordWrap = false
end

function GTextField:CreateDisplayObject()
    self._textField = TextField.new()
    self._textField.gOwner = self
    self.displayObject = self._textField
end

function GTextField:SetTextFieldText()
    local str = self._text
    if (self._templateVars ~= nil) then
        str = self:ParseTemplate(str)
    end

    if (self._ubbEnabled) then
        self._textField.htmlText = UBBParser.inst:Parse(XMLUtils.EncodeString(str))
    else
        self._textField.text = str
    end
end

function GTextField:GetTextFieldText()

end

---@param name string
---@param value string
function GTextField:SetVar(name, value)
    if (self._templateVars == nil) then
        self._templateVars = {}
    end
    self._templateVars[name] = value

    return self
end

function GTextField:FlushVars()
    self:SetTextFieldText()
    self:UpdateSize()
end

---@param template String
function GTextField:ParseTemplate(template)
    local pos1, pos2 = 0, 0
    local pos3
    local tag
    local value
    ---@type String
    local buffer
    pos2 = template:indexOf('{', pos1)
    while pos2 ~= -1 do
        if (pos2 > 0 and template[pos2 - 1] == '\\') then
            buffer = buffer:Append(template(pos1, pos2 - 1))
            buffer = buffer:Append('{')
            pos1 = pos2 + 1
            --continue
        else
            buffer = buffer:Append(template(pos1, pos2))
            pos1 = pos2
            pos2 = template:indexOf('}', pos1)
            if (pos2 == -1) then
                break
            end

            if (pos2 == pos1 + 1) then
                buffer = buffer:Append(template(pos1, pos1 + 2))
                pos1 = pos2 + 1
                --continue
            else
                tag = template(pos1 + 1, pos2)
                pos3 = tag:indexOf('=')
                if (pos3 ~= -1) then
                    value = self._templateVars[tag(1, pos3 - 1)]
                    if value == nil then
                        value = tag(pos3 + 1)
                    end
                else
                    value = self._templateVars[tag]
                    if value == nil then
                        value = ""
                    end
                end
                buffer = buffer:Append(value)
                pos1 = pos2 + 1
            end
        end
    end

    if (pos1 < template:len()) then
        buffer = buffer:Append(template, pos1, template:len() - pos1)
    end

    return buffer
end

function GTextField:UpdateSize()
    local displayObject = self.displayObject

    if (self._updatingSize) then
        return
    end

    self._updatingSize = true

    if (self._textField.autoSize == AutoSizeType.Both) then
        self.size = displayObject.size
    elseif (self._textField.autoSize == AutoSizeType.Height) then
        self.height = displayObject.height
    end

    self._updatingSize = false
end

function GTextField:HandleSizeChanged()
    local displayObject = self.displayObject

    if (self._updatingSize) then
        return
    end

    if (self.underConstruct) then
        displayObject:SetSize(self.width, self.height)
    elseif (self._textField.autoSize ~= AutoSizeType.Both) then
        if (self._textField.autoSize == AutoSizeType.Height) then
            displayObject.width = self.width  -- 先调整宽度，让文本重排
            if (self._text ~= '') then   -- 文本为空时，1是本来就不需要调整， 2是为了防止改掉文本为空时的默认高度，造成关联错误
                self:SetSizeDirectly(self.width, displayObject.height)
            end
        else
            displayObject:SetSize(self.width, self.height)
        end
    end
end

function GTextField:Setup_BeforeAdd(buffer, beginPos)
    GObject.Setup_BeforeAdd(self, buffer, beginPos)

    buffer:Seek(beginPos, 5)

    local tf = self._textField.textFormat

    tf.font = buffer:ReadS()
    tf.size = buffer:ReadShort()
    tf.color = buffer:ReadColor()
    self.align = buffer:ReadByte()
    self.verticalAlign = buffer:ReadByte()
    tf.lineSpacing = buffer:ReadShort()
    tf.letterSpacing = buffer:ReadShort()
    self._ubbEnabled = buffer:ReadBool()
    self.autoSize = buffer:ReadByte()
    tf.underline = buffer:ReadBool()
    tf.italic = buffer:ReadBool()
    tf.bold = buffer:ReadBool()
    self.singleLine = buffer:ReadBool()
    if (buffer:ReadBool()) then
        self.strokeColor = buffer:ReadColor()
        self.stroke = math.floor(buffer:ReadFloat())
    end

    if (buffer:ReadBool()) then
        self.strokeColor = buffer:ReadColor()
        local f1 = buffer:ReadFloat()
        local f2 = buffer:ReadFloat()
        self.shadowOffset = Vector2(f1, f2)
    end

    if (buffer:ReadBool()) then
        self._templateVars = {}
    end

    self._textField.textFormat = tf
end

function GTextField:Setup_AfterAdd(buffer, beginPos)
    GObject.Setup_AfterAdd(self, buffer, beginPos)

    buffer:Seek(beginPos, 6)

    local str = buffer:ReadS()
    if (str ~= nil ) then
        self.text = str
    end
end


local __get = Class.init_get(GTextField)
local __set = Class.init_set(GTextField)

---@param self FairyGUI.GTextField
__get.text = function(self)
    self:GetTextFieldText()
    return self._text
end

---@param self FairyGUI.GTextField
---@param val string
__set.text = function(self, val)
    if (val == nil) then
        val = ''
    end
    self._text = val
    self:SetTextFieldText()
    self:UpdateSize()
    self:UpdateGear(6)
end

---@param self FairyGUI.GTextField
__get.templateVars = function(self) return self._templateVars end

---@param self FairyGUI.GTextField
---@param val table<string, string>
__set.templateVars = function(self, val)
    if (self._templateVars == nil and val == nil) then
        return
    end

    self._templateVars = val

    self:FlushVars()
end

---@param self FairyGUI.GTextField
__get.textFormat = function(self) return self._textField.textFormat end

---@param self FairyGUI.GTextField
---@param val FairyGUI.TextFormat
__set.textFormat = function(self, val)
    self._textField.textFormat = val
    if not self.underConstruct then
        self:UpdateSize()
    end
end

---@param self FairyGUI.GTextField
__get.color = function(self) return self._textField.textFormat.color end

---@param self FairyGUI.GTextField
---@param val Love2DEngine.Color
__set.color = function(self, val)
    if (self._textField.textFormat.color ~= val) then
        local tf = self._textField.textFormat
        tf.color = val
        self._textField.textFormat = tf
        self:UpdateGear(4)
    end
end

---@param self FairyGUI.GTextField
__get.align = function(self) return self._textField.align end

---@param self FairyGUI.GTextField
---@param val FairyGUI.AlignType
__set.align = function(self, val) self._textField.align = val end

---@param self FairyGUI.GTextField
__get.verticalAlign = function(self) return self._textField.verticalAlign end

---@param self FairyGUI.GTextField
---@param val FairyGUI.VertAlignType
__set.verticalAlign = function(self, val) self._textField.verticalAlign = val end

---@param self FairyGUI.GTextField
__get.singleLine = function(self) return self._textField.singleLine end

---@param self FairyGUI.GTextField
---@param val boolean
__set.singleLine = function(self, val) self._textField.singleLine = val end

---@param self FairyGUI.GTextField
__get.stroke = function(self) return self._textField.stroke end

---@param self FairyGUI.GTextField
---@param val number
__set.stroke = function(self, val) self._textField.stroke = val end

---@param self FairyGUI.GTextField
__get.strokeColor = function(self)
    return self._textField.strokeColor
end

---@param self FairyGUI.GTextField
---@param val Love2DEngine.Color
__set.strokeColor = function(self, val)
    self._textField.strokeColor = val
    self:UpdateGear(4)
end

---@param self FairyGUI.GTextField
__get.shadowOffset = function(self) return self._textField.shadowOffset end

---@param self FairyGUI.GTextField
---@param val Love2DEngine.Vector2
__set.shadowOffset = function(self, val) self._textField.shadowOffset = val end

---@param self FairyGUI.GTextField
__get.UBBEnabled = function(self) return self._ubbEnabled end

---@param self FairyGUI.GTextField
---@param val boolean
__set.UBBEnabled = function(self, val) self._ubbEnabled = val end

---@param self FairyGUI.GTextField
__get.autoSize = function(self) return self._textField.autoSize end

---@param self FairyGUI.GTextField
---@param val FairyGUI.AutoSizeType
__set.autoSize = function(self, val)
    local _textField = self._textField

    _textField.autoSize = val
    if (val == AutoSizeType.Both) then
        _textField.wordWrap = false

        if (not self.underConstruct) then
            self:SetSize(_textField.textWidth, _textField.textHeight)
        end
    else
        _textField.wordWrap = true

        if (val == AutoSizeType.Height) then
            if (not self.underConstruct) then
                self.height = _textField.textHeight
            end
        else
            self.displayObject:SetSize(self.width, self.height)
        end
    end
end

---@param self FairyGUI.GTextField
__get.textWidth = function(self) return self._textField.textWidth end

---@param self FairyGUI.GTextField
__get.textHeight = function(self) return self._textField.textHeight end


FairyGUI.GTextField = GTextField
return GTextField