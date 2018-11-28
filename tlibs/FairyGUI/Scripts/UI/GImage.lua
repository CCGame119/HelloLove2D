--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:26
--
local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local IColorGear = FairyGUI.IColorGear
local FillMethod = FairyGUI.FillMethod
local FlipType = FairyGUI.FlipType
local Image = FairyGUI.Image

---@class FairyGUI.GImage:FairyGUI.GObject @implement IColorGear
---@field public color Love2DEngine.Color
---@field public flip FairyGUI.FlipType
---@field public fillMethod FairyGUI.FillMethod
---@field public fillOrigin number
---@field public fillClockwise boolean
---@field public fillAmount number
---@field public texture FairyGUI.NTexture
---@field public material Love2DEngine.Material
---@field public shader string
---@field private _content FairyGUI.Image
local GImage = Class.inheritsFrom('GImage', nil, GObject, {IColorGear})

function GImage:__ctor()
    GObject.__ctor(self)
end

function GImage:CreateDisplayObject()
    self._content = Image.new()
    self._content.gOwner = self
    self.displayObject = self._content
end

function GImage:ConstructFromResource()
    local packageItem = self.packageItem
    local _content = self._content

    packageItem:Load()

    self.sourceWidth = packageItem.width
    self.sourceHeight = packageItem.height
    self.initWidth = self.sourceWidth
    self.initHeight = self.sourceHeight
    _content.scale9Grid = packageItem.scale9Grid
    _content.scaleByTile = packageItem.scaleByTile
    _content.tileGridIndice = packageItem.tileGridIndice

    _content.texture = packageItem.texture

    self:SetSize(self.sourceWidth, self.sourceHeight)
end

function GImage:Setup_BeforeAdd(buffer, beginPos)
    GObject.Setup_BeforeAdd(self, buffer, beginPos)

    local _content = self._content

    buffer:Seek(beginPos, 5)

    if (buffer:ReadBool()) then
        _content.color = buffer:ReadColor()
    end

    _content.flip = buffer:ReadByte()
    _content.fillMethod = buffer:ReadByte()
    if (_content.fillMethod ~= FillMethod.None) then
        _content.fillOrigin = buffer:ReadByte()
        _content.fillClockwise = buffer:ReadBool()
        _content.fillAmount = buffer:ReadFloat()
    end
end


local __get = Class.init_get(GImage)
local __set = Class.init_set(GImage)

---@param self FairyGUI.GImage
__get.color  = function(self) return self._content.color end

---@param self FairyGUI.GImage
---@param val Love2DEngine.Color
__set.color  = function(self, val)
    self._content.color = val
    self:UpdateGear(4)
end

---@param self FairyGUI.GImage
__get.flip  = function(self) return self._content.flip end

---@param self FairyGUI.GImage
---@param val FairyGUI.FlipType
__set.flip  = function(self, val) self._content.flip = val end

---@param self FairyGUI.GImage
__get.fillMethod  = function(self) return self._content.fillMethod end

---@param self FairyGUI.GImage
---@param val FairyGUI.FillMethod
__set.fillMethod  = function(self, val) self._content.fillMethod = val end

---@param self FairyGUI.GImage
__get.fillOrigin  = function(self) return self._content.fillOrigin end

---@param self FairyGUI.GImage
---@param val number
__set.fillOrigin  = function(self, val) self._content.fillOrigin = val end

---@param self FairyGUI.GImage
__get.fillClockwise  = function(self) return self._content.fillClockwise end

---@param self FairyGUI.GImage
---@param val boolean
__set.fillClockwise  = function(self, val) self._content.fillClockwise = val end

---@param self FairyGUI.GImage
__get.fillAmount  = function(self) return self._content.fillAmount end

---@param self FairyGUI.GImage
---@param val number
__set.fillAmount  = function(self, val)
    self._content.fillAmount = val
end

---@param self FairyGUI.GImage
__get.texture  = function(self) return self._content.texture end

---@param self FairyGUI.GImage
---@param val FairyGUI.NTexture
__set.texture  = function(self, val)
    if (val ~= nil) then
        self.sourceWidth = val.width
        self.sourceHeight = val.height
    else
        self.sourceWidth = 0
        self.sourceHeight = 0
    end
    self.initWidth = self.sourceWidth
    self.initHeight = self.sourceHeight
    self._content.texture = val
end

---@param self FairyGUI.GImage
__get.material  = function(self) return self._content.material end

---@param self FairyGUI.GImage
---@param val Love2DEngine.Material
__set.material  = function(self, val) self._content.material = val end

---@param self FairyGUI.GImage
__get.shader  = function(self) return self._content.shader end

---@param self FairyGUI.GImage
---@param val string
__set.shader  = function(self, val) self._content.shader = val end


FairyGUI.GImage = GImage
return GImage