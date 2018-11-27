--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:26
--
local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local IColorGear = FairyGUI.IColorGear

---@class FairyGUI.GImage:FairyGUI.GObject @implement IColorGear
---@field public color Love2DEngine.Color
---@field public flip FairyGUI.FlipType
---@field public fillMethod FairyGUI.FillMethod
---@field public fillOrigin number
---@field public fillClockwise boolean
---@field public fillAmount number
---@field public material Love2DEngine.Material
---@field public shader string
---@field private _content FairyGUI.Image
local GImage = Class.inheritsFrom('GImage', nil, GObject, {IColorGear})

function GImage:__ctor()
    GObject.__ctor(self)
end

function GImage:CreateDisplayObject() end

function GImage:ConstructFromResource() end

function GImage:Setup_BeforeAdd(buffer, beginPos)
end

--TODO: FairyGUI.GImage

local __get = Class.init_get(GImage)
local __set = Class.init_set(GImage)

---@param self FairyGUI.GImage
__get.color  = function(self) end

---@param self FairyGUI.GImage
---@param val Love2DEngine.Color
__set.color  = function(self, val) end


---@param self FairyGUI.GImage
__get.flip  = function(self) end

---@param self FairyGUI.GImage
---@param val FairyGUI.FlipType
__set.flip  = function(self, val) end


---@param self FairyGUI.GImage
__get.fillMethod  = function(self) end

---@param self FairyGUI.GImage
---@param val FairyGUI.FillMethod
__set.fillMethod  = function(self, val) end


---@param self FairyGUI.GImage
__get.fillOrigin  = function(self) end

---@param self FairyGUI.GImage
---@param val number
__set.fillOrigin  = function(self, val) end


---@param self FairyGUI.GImage
__get.fillClockwise  = function(self) end

---@param self FairyGUI.GImage
---@param val boolean
__set.fillClockwise  = function(self, val) end


---@param self FairyGUI.GImage
__get.fillAmount  = function(self) end

---@param self FairyGUI.GImage
---@param val number
__set.fillAmount  = function(self, val) end


---@param self FairyGUI.GImage
__get.material  = function(self) end

---@param self FairyGUI.GImage
---@param val Love2DEngine.Material
__set.material  = function(self, val) end


---@param self FairyGUI.GImage
__get.shader  = function(self) end

---@param self FairyGUI.GImage
---@param val string
__set.shader  = function(self, val) end


FairyGUI.GImage = GImage
return GImage