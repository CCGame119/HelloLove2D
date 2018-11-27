--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/25 10:29
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local IColorGear = FairyGUI.IColorGear
local IAnimationGear = FairyGUI.IAnimationGear

---@class FairyGUI.GLoader:FairyGUI.GObject @implement IAnimationGear, IColorGear
---@field public showErrorSign boolean @Display an error sign if the loader fails to load the content. UIConfig.loaderErrorSign muse be set.
---@field public url string
---@field public icon string
---@field public align FairyGUI.AlignType
---@field public verticalAlign FairyGUI.VertAlignType
---@field public fill FairyGUI.FillType
---@field public shrinkOnly boolean
---@field public autoSize boolean
---@field public playing boolean
---@field public frame number
---@field public timeScale number
---@field public ignoreEngineTimeScale boolean
---@field public material Love2DEngine.Material
---@field public shader string
---@field public color Love2DEngine.Color
---@field public fillMethod FairyGUI.FillMethod
---@field public fillOrigin number
---@field public fillClockwise boolean
---@field public fillAmount number
---@field public image FairyGUI.Image
---@field public movieClip FairyGUI.MovieClip
---@field public component FairyGUI.GComponent
---@field public texture FairyGUI.NTexture
---@field public filter FairyGUI.IFilter
---@field public blendMode FairyGUI.BlendMode
---@field private _url string
---@field private _align FairyGUI.AlignType
---@field private _verticalAlign FairyGUI.VertAlignType
---@field private _autoSize boolean
---@field private _fill FairyGUI.FillType
---@field private _shrinkOnly boolean
---@field private _updatingLayout boolean
---@field private _contentItem FairyGUI.PackageItem
---@field private _contentWidth number
---@field private _contentHeight number
---@field private _contentSourceWidth number
---@field private _contentSourceHeight number
---@field private _content FairyGUI.MovieClip
---@field private _errorSign FairyGUI.GObject
---@field private _content2 FairyGUI.GComponent
local GLoader = Class.inheritsFrom('GLoader', nil, GObject, {IAnimationGear, IColorGear})

---@type FairyGUI.GObjectPool
GLoader.errorSignPool = nil

function GLoader:__ctor()
    GObject.__ctor(self)
end

function GLoader:CreateDisplayObject()

end

function GLoader:Dispose()
end

---@param time number
function GLoader:Advance(time)

end

function GLoader:LoadContent()

end

---@param itemURL string
function GLoader:LoadFromPackage(itemURL)

end

function GLoader:LoadExternal()

end

function GLoader:FreeExternal() end

---@param texture FairyGUI.NTexture
function GLoader:onExternalLoadSuccess(texture) end

function GLoader:onExternalLoadFailed()

end

function GLoader:SetErrorState()

end

function GLoader:ClearErrorState()

end

function GLoader:UpdateLayout()

end

function GLoader:ClearContent()

end

function GLoader:HandleSizeChanged()
end

function GLoader:Setup_BeforeAdd(buffer, beginPos)
end

--TODO: FairyGUI.GLoader

local __get = Class.init_get(GLoader)
local __set = Class.init_set(GLoader)

---@param self FairyGUI.GLoader
__get.url = function(self) end

---@param self FairyGUI.GLoader
---@param val string
__set.url = function(self, val) end

---@param self FairyGUI.GLoader
__get.icon = function(self) end

---@param self FairyGUI.GLoader
---@param val string
__set.icon = function(self, val) end

---@param self FairyGUI.GLoader
__get.align = function(self) end

---@param self FairyGUI.GLoader
---@param val FairyGUI.AlignType
__set.align = function(self, val) end

---@param self FairyGUI.GLoader
__get.verticalAlign = function(self) end

---@param self FairyGUI.GLoader
---@param val FairyGUI.VertAlignType
__set.verticalAlign = function(self, val) end

---@param self FairyGUI.GLoader
__get.fill = function(self) end

---@param self FairyGUI.GLoader
---@param val FairyGUI.FillType
__set.fill = function(self, val) end

---@param self FairyGUI.GLoader
__get.shrinkOnly = function(self) end

---@param self FairyGUI.GLoader
---@param val boolean
__set.shrinkOnly = function(self, val) end

---@param self FairyGUI.GLoader
__get.autoSize = function(self) end

---@param self FairyGUI.GLoader
---@param val boolean
__set.autoSize = function(self, val) end

---@param self FairyGUI.GLoader
__get.playing = function(self) end

---@param self FairyGUI.GLoader
---@param val boolean
__set.playing = function(self, val) end

---@param self FairyGUI.GLoader
__get.frame = function(self) end

---@param self FairyGUI.GLoader
---@param val number
__set.frame = function(self, val) end

---@param self FairyGUI.GLoader
__get.timeScale = function(self) end

---@param self FairyGUI.GLoader
---@param val number
__set.timeScale = function(self, val) end

---@param self FairyGUI.GLoader
__get.ignoreEngineTimeScale = function(self) end

---@param self FairyGUI.GLoader
---@param val boolean
__set.ignoreEngineTimeScale = function(self, val) end

---@param self FairyGUI.GLoader
__get.material = function(self) end

---@param self FairyGUI.GLoader
---@param val Love2DEngine.Material
__set.material = function(self, val) end

---@param self FairyGUI.GLoader
__get.shader = function(self) end

---@param self FairyGUI.GLoader
---@param val string
__set.shader = function(self, val) end

---@param self FairyGUI.GLoader
__get.color = function(self) end

---@param self FairyGUI.GLoader
---@param val Love2DEngine.Color
__set.color = function(self, val) end

---@param self FairyGUI.GLoader
__get.fillMethod = function(self) end

---@param self FairyGUI.GLoader
---@param val FairyGUI.FillMethod
__set.fillMethod = function(self, val) end

---@param self FairyGUI.GLoader
__get.fillOrigin = function(self) end

---@param self FairyGUI.GLoader
---@param val number
__set.fillOrigin = function(self, val) end

---@param self FairyGUI.GLoader
__get.fillClockwise = function(self) end

---@param self FairyGUI.GLoader
---@param val boolean
__set.fillClockwise = function(self, val) end

---@param self FairyGUI.GLoader
__get.fillAmount = function(self) end

---@param self FairyGUI.GLoader
---@param val number
__set.fillAmount = function(self, val) end

---@param self FairyGUI.GLoader
__get.image = function(self) end

---@param self FairyGUI.GLoader
__get.movieClip = function(self) end

---@param self FairyGUI.GLoader
__get.component = function(self) end

---@param self FairyGUI.GLoader
__get.texture = function(self) end

---@param self FairyGUI.GLoader
---@param val FairyGUI.NTexture
__set.texture = function(self, val) end

---@param self FairyGUI.GLoader
__get.filter = function(self) end

---@param self FairyGUI.GLoader
---@param val FairyGUI.IFilter
__set.filter = function(self, val) end

---@param self FairyGUI.GLoader
__get.blendMode = function(self) end

---@param self FairyGUI.GLoader
---@param val FairyGUI.BlendMode
__set.blendMode = function(self, val) end


FairyGUI.GLoader = GLoader
return GLoader