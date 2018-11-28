--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:32
--

local Class = require('libs.Class')

local Color = Love2DEngine.Color

local GComponent = FairyGUI.GComponent
local IColorGear = FairyGUI.IColorGear
local GTextField = FairyGUI.GTextField
local GButton = FairyGUI.GButton
local GTextInput = FairyGUI.GTextInput

---@class FairyGUI.GLabel:FairyGUI.GComponent @implement IColorGear
---@field public icon string
---@field public title string
---@field public text string
---@field public editable boolean
---@field public titleColor Love2DEngine.Color
---@field public titleFontSize number
---@field public color Love2DEngine.Color
---@field protected _titleObject FairyGUI.GObject
---@field protected _iconObject FairyGUI.GObject
local GLabel = Class.inheritsFrom('GLabel', nil, GComponent, {IColorGear})

function GLabel:__ctor()
    GComponent.__ctor(self)
end

---@return FairyGUI.GTextField
function GLabel:GetTextField()
    if self._titleObject:isa(GTextField) then
        return self._titleObject
    elseif self._titleObject:isa(GLabel) then
        return self._titleObject:GetTextField()
    elseif self._titleObject:isa(GButton) then
        return self._titleObject:GetTextField()
    else
        return nil
    end
end

---@param buffer Utils.ByteBuffer
function GLabel:ConstructExtension(buffer)
    self._titleObject = self:GetChild("title")
    self._iconObject = self:GetChild("icon")
end

function GLabel:Setup_AfterAdd(buffer, beginPos)
    GComponent.Setup_AfterAdd(self, buffer, beginPos)

    if (not buffer:Seek(beginPos, 6)) then
        return
    end

    if (buffer:ReadByte() ~= self.packageItem.objectType) then
        return
    end

    local str = buffer:ReadS()
    if (str ~= nil) then
        self.title = str
    end
    str = buffer:ReadS()
    if (str ~= nil) then
        self.icon = str
    end
    if (buffer:ReadBool()) then
        self.titleColor = buffer:ReadColor()
    end
    local iv = buffer:ReadInt()
    if (iv ~= 0) then
        self.titleFontSize = iv
    end

    if (buffer:ReadBool()) then
        ---@type FairyGUI.GTextInput
        local input = self:GetTextField()
        if (input ~= nil) then
            str = buffer:ReadS()
            if (str ~= nil) then
                input.promptText = str
            end

            str = buffer:ReadS()
            if (str ~= nil) then
                input.restrict = str
            end

            iv = buffer:ReadInt()
            if (iv ~= 0) then
                input.maxLength = iv
            end
            iv = buffer:ReadInt()
            if (iv ~= 0) then
                input.keyboardType = iv
            end
            if (buffer:ReadBool()) then
                input.displayAsPassword = true
            end
        else
            buffer:Skip(13)
        end
    end
end


local __get = Class.init_get(GLabel)
local __set = Class.init_set(GLabel)

---@param self FairyGUI.GLabel
__get.icon  = function(self)
    if self._iconObject ~= nil then
        return self._iconObject.icon
    end
    return nil
end

---@param self FairyGUI.GLabel
---@param val string
__set.icon  = function(self, val)
    if self._iconObject ~= nil then
        self._iconObject.icon = val
    end

    self:UpdateGear(7)
end

---@param self FairyGUI.GLabel
__get.title  = function(self)
    if self._titleObject ~= nil then
        return self._titleObject.text
    end
    return nil
end

---@param self FairyGUI.GLabel
---@param val string
__set.title  = function(self, val)
    if self._titleObject ~= nil then
        self._titleObject.text = val
    end
    self:UpdateGear(7)
end

---@param self FairyGUI.GLabel
__get.text  = function(self) return self.title end

---@param self FairyGUI.GLabel
---@param val string
__set.text  = function(self, val)
    self.title = val
end

---@param self FairyGUI.GLabel
__get.editable  = function(self)
    if self._titleObject:isa(GTextInput) then
        return self._titleObject.asTextInput.editable
    end
    return false
end

---@param self FairyGUI.GLabel
---@param val boolean
__set.editable  = function(self, val)
    if self._titleObject:isa(GTextInput) then
        self._titleObject.asTextInput.editable = val
    end
end

---@param self FairyGUI.GLabel
__get.titleColor  = function(self)
    local tf = self:GetTextField()
    if (tf ~= nil) then
        return tf.color
    end
    return Color.black
end

---@param self FairyGUI.GLabel
---@param val Love2DEngine.Color
__set.titleColor  = function(self, val)
    local tf = self:GetTextField()
    if (tf ~= nil) then
        tf.color = val
        self:UpdateGear(4)
    end
end

---@param self FairyGUI.GLabel
__get.titleFontSize  = function(self)
    local tf = self:GetTextField()
    if (tf ~= nil) then
        return tf.textFormat.size
    end
    return 0
end

---@param self FairyGUI.GLabel
---@param val number
__set.titleFontSize  = function(self, val)
    local tf = self:GetTextField()
    if (tf ~= nil) then
        local format = self._titleObject.textFormat
        format.size = val
        tf.textFormat = format
    end
end

---@param self FairyGUI.GLabel
__get.color  = function(self) return self.titleColor end

---@param self FairyGUI.GLabel
---@param val Love2DEngine.Color
__set.color  = function(self, val) self.titleColor = val end


FairyGUI.GLabel = GLabel
return GLabel