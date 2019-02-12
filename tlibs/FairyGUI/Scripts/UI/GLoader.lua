--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/25 10:29
--

local Class = require('libs.Class')

local Vector2 = Love2DEngine.Vector2
local Resources = Love2DEngine.Resources
local AssetType = Love2DEngine.AssetType
local Texture2D = Love2DEngine.Texture2D
local Rect = Love2DEngine.Rect

local GObject = FairyGUI.GObject
local IColorGear = FairyGUI.IColorGear
local IAnimationGear = FairyGUI.IAnimationGear
local FillMethod = FairyGUI.FillMethod
local FillType = FairyGUI.FillType
local AlignType = FairyGUI.AlignType
local GObjectPool = FairyGUI.GObjectPool
local UIConfig = FairyGUI.UIConfig
local UIPackage = FairyGUI.UIPackage
local Stage = FairyGUI.Stage
local NTexture = FairyGUI.NTexture
local PackageItemType = FairyGUI.PackageItemType
local GComponent = FairyGUI.GComponent
local MovieClip = FairyGUI.MovieClip
local Container = FairyGUI.Container
local VertAlignType = FairyGUI.VertAlignType


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
local GLoader = Class.inheritsFrom('GLoader', {
    _autoSize = false, _fill = FillType.None,
    _shrinkOnly = false, _updatingLayout = false,
    _contentWidth = 0, _contentHeight = 0,
    _contentSourceWidth = 0, _contentSourceHeight = 0,
}, GObject, {IAnimationGear, IColorGear})

---@type FairyGUI.GObjectPool
GLoader.errorSignPool = nil

function GLoader:__ctor()
    GObject.__ctor(self)

    self._url = ''
    self._align = AlignType.Left
    self._verticalAlign = VertAlignType.Top
    self.showErrorSign = true
end

function GLoader:CreateDisplayObject()
    self.displayObject = Container.new("GLoader")
    self.displayObject.gOwner = self
    self._content = MovieClip.new()
    self.displayObject:AddChild(self._content)
    self.displayObject.opaque = true
end

function GLoader:Dispose()
    if (self._content.texture ~= nil) then
        if (self._contentItem == nil) then
            self:FreeExternal(self.image.texture)
        end
    end
    if (self._errorSign ~= nil) then
        self._errorSign:Dispose()
    end
    if (self._content2 ~= nil) then
        self._content2:Dispose()
    end
    self._content:Dispose()

    GObject.Dispose(self)
end

---@param time number
function GLoader:Advance(time)
    self._content:Advance(time)
end

function GLoader:LoadContent()
    self:ClearContent()

    if (string.isNullOrEmpty(self._url)) then
        return
    end

    if string.startsWith(self._url, UIPackage.URL_PREFIX) then
        self:LoadFromPackage(self._url)
    else
        self:LoadExternal()
    end
end

---@param itemURL string
function GLoader:LoadFromPackage(itemURL)
    self._contentItem = UIPackage.GetItemByURL(itemURL)
    local _contentItem = self._contentItem
    local _content = self._content

    if (_contentItem ~= nil) then
        _contentItem:Load()

        if (_contentItem.type == PackageItemType.Image) then
            _content.texture = _contentItem.texture
            _content.scale9Grid = _contentItem.scale9Grid
            _content.scaleByTile = _contentItem.scaleByTile
            _content.tileGridIndice = _contentItem.tileGridIndice

            self._contentSourceWidth = _contentItem.width
            self._contentSourceHeight = _contentItem.height
            self:UpdateLayout()
        elseif (_contentItem.type == PackageItemType.MovieClip) then
            self._contentSourceWidth = _contentItem.width
            self._contentSourceHeight = _contentItem.height

            _content.interval = _contentItem.interval
            _content.swing = _contentItem.swing
            _content.repeatDelay = _contentItem.repeatDelay
            _content:SetData(_contentItem.texture, _contentItem.frames, Rect(0, 0, self._contentSourceWidth, self._contentSourceHeight))

            self:UpdateLayout()
        elseif (_contentItem.type == PackageItemType.Component) then
            self._contentSourceWidth = _contentItem.width
            self._contentSourceHeight = _contentItem.height

            local obj = UIPackage.CreateObjectFromURL(itemURL)
            if (obj == nil) then
                self:SetErrorState()
            elseif (not obj:isa(GComponent)) then
                obj:Dispose()
                self:SetErrorState()
            else
                self._content2 = obj
                self.displayObject:AddChild(self._content2.displayObject)
                self:UpdateLayout()
            end
        else
            if (self._autoSize) then
                self:SetSize(_contentItem.width, _contentItem.height)
            end

            self:SetErrorState()
        end
    else
        self:SetErrorState()
    end
end

function GLoader:LoadExternal()
    local tex = Resources.Load(self.url, AssetType.tex2d)
    if (tex ~= nil) then
        self:onExternalLoadSuccess(NTexture.new(tex))
    else
        self:onExternalLoadFailed()
    end
end

function GLoader:FreeExternal() end

---@param texture FairyGUI.NTexture
function GLoader:onExternalLoadSuccess(texture)
    self._content.texture = texture
    self._contentSourceWidth = texture.width
    self._contentSourceHeight = texture.height
    self._content.scale9Grid = nil
    self._content.scaleByTile = false
    self:UpdateLayout()
end

function GLoader:onExternalLoadFailed()
    self:SetErrorState()
end

function GLoader:SetErrorState()
    if (not self.showErrorSign) then
        return
    end

    if (self._errorSign == nil) then
        if (UIConfig.loaderErrorSign ~= nil) then
            if (self.errorSignPool == nil) then
                self.errorSignPool = GObjectPool.new(Stage.inst:CreatePoolManager("LoaderErrorSignPool"))
            end

            self._errorSign = self.errorSignPool:GetObject(UIConfig.loaderErrorSign)
        else
            return
        end
    end

    if (self._errorSign ~= nil) then
        self._errorSign:SetSize(self.width, self.height)
        self.displayObject:AddChild(self._errorSign.displayObject)
    end
end

function GLoader:ClearErrorState()
    if (self._errorSign ~= nil) then
        self.displayObject:RemoveChild(self._errorSign.displayObject)
        self.errorSignPool:ReturnObject(self._errorSign)
        self._errorSign = nil
    end
end

function GLoader:UpdateLayout()
    if (self._content2 == nil and self._content.texture == nil and self._content.frameCount == 0) then
        if (self._autoSize) then
            self._updatingLayout = true
            self:SetSize(50, 30)
            self._updatingLayout = false
        end
        return
    end

    self._contentWidth = self._contentSourceWidth
    self._contentHeight = self._contentSourceHeight

    if (self._autoSize) then
        self._updatingLayout = true
        if (self._contentWidth == 0) then
            self._contentWidth = 50
        end
        if (self._contentHeight == 0) then
            self._contentHeight = 30
        end
        self:SetSize(self._contentWidth, self._contentHeight)
        self._updatingLayout = false

        if (self._width == self._contentWidth and self._height == self._contentHeight) then
            if (self._content2 ~= nil) then
                self._content2:SetXY(0, 0)
                self._content2:SetScale(1, 1)
            else
                self._content:SetXY(0, 0)
                self._content:SetScale(1, 1)
                if (self._content.texture ~= nil) then
                    self._content:SetNativeSize()
                end
            end
            return
        end
        -- 如果不相等，可能是由于大小限制造成的，要后续处理
    end

    local sx, sy = 1, 1
    if (self._fill ~= FillType.None) then
        sx = self.width / self._contentSourceWidth
        sy = self.height / self._contentSourceHeight

        if (sx ~= 1 or sy ~= 1) then
            if (self._fill == FillType.ScaleMatchHeight) then
                sx = sy
            elseif (self._fill == FillType.ScaleMatchWidth) then
                sy = sx
            elseif (self._fill == FillType.Scale) then
                if (sx > sy) then
                    sx = sy
                else
                    sy = sx
                end
            elseif (self._fill == FillType.ScaleNoBorder) then
                if (sx > sy) then
                    sy = sx
                else
                    sx = sy
                end
            end

            if (self._shrinkOnly) then
                if (sx > 1) then
                    sx = 1
                end
                if (sy > 1) then
                    sy = 1
                end
            end

            self._contentWidth = math.floor(self._contentSourceWidth * sx)
            self._contentHeight = math.floor(self._contentSourceHeight * sy)
        end
    end

    if (self._content2 ~= nil) then
        self._content2:SetScale(sx, sy)
    elseif (self._content.texture ~= nil) then
        self._content:SetScale(1, 1)
        self._content.size = Vector2(self._contentWidth, self._contentHeight)
    else
        self._content:SetScale(sx, sy)
    end

    local nx
    local ny
    if (self._align == AlignType.Center) then
        nx = math.floor((self.width - self._contentWidth) / 2)
    elseif (self._align == AlignType.Right) then
        nx = math.floor(self.width - self._contentWidth)
    else
        nx = 0
    end
    if (self._verticalAlign == VertAlignType.Middle) then
        ny = math.floor((self.height - self._contentHeight) / 2)
    elseif (self._verticalAlign == VertAlignType.Bottom) then
        ny = math.floor(self.height - self._contentHeight)
    else
        ny = 0
    end
    if (self._content2 ~= nil) then
        self._content2:SetXY(nx, ny)
    else
        self._content:SetXY(nx, ny)
    end
end

function GLoader:ClearContent()
    self:ClearErrorState()

    if (self._content.texture ~= nil) then
        if (self._contentItem == nil) then
            self:FreeExternal(self.image.texture)
            self._content.texture = nil
        end
    end

    self._content:Clear()
    if (self._content2 ~= nil) then
        self._content2:Dispose()
        self._content2 = nil
    end
    self._contentItem = nil
end

function GLoader:HandleSizeChanged()
    GObject.HandleSizeChanged(self)

    if not self._updatingLayout then
        self:UpdateLayout()
    end
end

function GLoader:Setup_BeforeAdd(buffer, beginPos)
    GObject.Setup_BeforeAdd(self, buffer, beginPos)

    local _content = self._content

    buffer:Seek(beginPos, 5)

    self._url = buffer:ReadS()
    self._align = buffer:ReadByte()
    self._verticalAlign = buffer:ReadByte()
    self._fill = buffer:ReadByte()
    self._shrinkOnly = buffer:ReadBool()
    self._autoSize = buffer:ReadBool()
    self.showErrorSign = buffer:ReadBool()
    _content.playing = buffer:ReadBool()
    _content.frame = buffer:ReadInt()

    if (buffer:ReadBool()) then
        _content.color = buffer:ReadColor()
    end
    _content.fillMethod = buffer:ReadByte()
    if (_content.fillMethod ~= FillMethod.None) then
        _content.fillOrigin = buffer:ReadByte()
        _content.fillClockwise = buffer:ReadBool()
        _content.fillAmount = buffer:ReadFloat()
    end

    if (not string.isNullOrEmpty(self._url)) then
        self:LoadContent()
    end
end


local __get = Class.init_get(GLoader)
local __set = Class.init_set(GLoader)

---@param self FairyGUI.GLoader
__get.url = function(self) return self._url end

---@param self FairyGUI.GLoader
---@param val string
__set.url = function(self, val)
    if (self._url == val) then
        return
    end

    self._url = val
    self:LoadContent()
    self:UpdateGear(7)
end

---@param self FairyGUI.GLoader
__get.icon = function(self) return self._url end

---@param self FairyGUI.GLoader
---@param val string
__set.icon = function(self, val)
    self._url = val
end

---@param self FairyGUI.GLoader
__get.align = function(self) return self._align end

---@param self FairyGUI.GLoader
---@param val FairyGUI.AlignType
__set.align = function(self, val)
    if self._align ~= val then
        self._align = val
        self:UpdateLayout()
    end
end

---@param self FairyGUI.GLoader
__get.verticalAlign = function(self) return self._verticalAlign end

---@param self FairyGUI.GLoader
---@param val FairyGUI.VertAlignType
__set.verticalAlign = function(self, val)
    if self._verticalAlign ~= val then
        self._verticalAlign = val
        self:UpdateLayout()
    end
end

---@param self FairyGUI.GLoader
__get.fill = function(self) return self._fill end

---@param self FairyGUI.GLoader
---@param val FairyGUI.FillType
__set.fill = function(self, val)
    if self._fill ~= val then
        self._fill = val
        self:UpdateLayout()
    end
end

---@param self FairyGUI.GLoader
__get.shrinkOnly = function(self) return self._shrinkOnly end

---@param self FairyGUI.GLoader
---@param val boolean
__set.shrinkOnly = function(self, val)
    if self._shrinkOnly ~= val then
        self._shrinkOnly = val
        self:UpdateLayout()
    end
end

---@param self FairyGUI.GLoader
__get.autoSize = function(self) return self._autoSize end

---@param self FairyGUI.GLoader
---@param val boolean
__set.autoSize = function(self, val)
    if self._autoSize ~= val then
        self._autoSize = val
        self:UpdateLayout()
    end
end

---@param self FairyGUI.GLoader
__get.playing = function(self) return self._content.playing end

---@param self FairyGUI.GLoader
---@param val boolean
__set.playing = function(self, val)
    self._content.playing = val
    self:UpdateGear(5)
end

---@param self FairyGUI.GLoader
__get.frame = function(self) return self._content.frame end

---@param self FairyGUI.GLoader
---@param val number
__set.frame = function(self, val)
    self._content.frame = val
    self:UpdateGear(5)
end

---@param self FairyGUI.GLoader
__get.timeScale = function(self) return self._content.timeScale end

---@param self FairyGUI.GLoader
---@param val number
__set.timeScale = function(self, val)
    self._content.timeScale = val
end

---@param self FairyGUI.GLoader
__get.ignoreEngineTimeScale = function(self) return self._content.ignoreEngineTimeScale end

---@param self FairyGUI.GLoader
---@param val boolean
__set.ignoreEngineTimeScale = function(self, val)
    self._content.ignoreEngineTimeScale = val
end

---@param self FairyGUI.GLoader
__get.material = function(self) return self._content.material end

---@param self FairyGUI.GLoader
---@param val Love2DEngine.Material
__set.material = function(self, val)
    self._content.material = val
end

---@param self FairyGUI.GLoader
__get.shader = function(self) return self._content.shader end

---@param self FairyGUI.GLoader
---@param val string
__set.shader = function(self, val) self._content.shader = val end

---@param self FairyGUI.GLoader
__get.color = function(self) return self._content.color end

---@param self FairyGUI.GLoader
---@param val Love2DEngine.Color
__set.color = function(self, val)
    self._content.color = val
    self:UpdateGear(4)
end

---@param self FairyGUI.GLoader
__get.fillMethod = function(self) return self._content.fillMethod end

---@param self FairyGUI.GLoader
---@param val FairyGUI.FillMethod
__set.fillMethod = function(self, val) self._content.fillMethod = val end

---@param self FairyGUI.GLoader
__get.fillOrigin = function(self) return self.fillOrigin end

---@param self FairyGUI.GLoader
---@param val number
__set.fillOrigin = function(self, val) self._content.fillOrigin = val end

---@param self FairyGUI.GLoader
__get.fillClockwise = function(self) return self._content.fillClockwise end

---@param self FairyGUI.GLoader
---@param val boolean
__set.fillClockwise = function(self, val) self._content.fillClockwise = val end

---@param self FairyGUI.GLoader
__get.fillAmount = function(self) return self._content.fillAmount end

---@param self FairyGUI.GLoader
---@param val number
__set.fillAmount = function(self, val) self._content.fillAmount = val end

---@param self FairyGUI.GLoader
__get.image = function(self) return self._content end

---@param self FairyGUI.GLoader
__get.movieClip = function(self) return self._content end

---@param self FairyGUI.GLoader
__get.component = function(self) return self._content2 end

---@param self FairyGUI.GLoader
__get.texture = function(self) return self._content.texture end

---@param self FairyGUI.GLoader
---@param val FairyGUI.NTexture
__set.texture = function(self, val)
    self.url = nil

    self._content.texture = val
    if (val ~= nil) then
        self._contentSourceWidth = val.width
        self._contentSourceHeight = val.height
    else
        self._contentSourceWidth = 0
        self._contentHeight = 0
    end

    self:UpdateLayout()
end

---@param self FairyGUI.GLoader
__get.filter = function(self) return self._content.filter end

---@param self FairyGUI.GLoader
---@param val FairyGUI.IFilter
__set.filter = function(self, val) self._content.filter = val end

---@param self FairyGUI.GLoader
__get.blendMode = function(self) return self._content.blendMode end

---@param self FairyGUI.GLoader
---@param val FairyGUI.BlendMode
__set.blendMode = function(self, val) self._content.blendMode = val end

FairyGUI.GLoader = GLoader
return GLoader