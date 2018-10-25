--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:31
--

local Class = require('libs.Class')

local GLoader = FairyGUI.GLoader
local RichTextField = FairyGUI.RichTextField
local UIObjectFactory = FairyGUI.UIObjectFactory
local FillType = FairyGUI.FillType
local ObjectType = FairyGUI.ObjectType
local DisplayObject = FairyGUI.DisplayObject
local NTexture = FairyGUI.NTexture
local UIPackage = FairyGUI.UIPackage
local HtmlElement = Utils.HtmlElement
local IHtmlObject = Utils.IHtmlObject

---@class Utils.HtmlImage:Utils.IHtmlObject
---@field public loader FairyGUI.GLoader
---@field private _owner FairyGUI.RichTextField
---@field private _element Utils.HtmlElement
---@field private _externalTexture boolean
local HtmlImage = Class.inheritsFrom('HtmlImage', nil, IHtmlObject)

function HtmlImage:__ctor()
    self.loader = UIObjectFactory.NewObject(ObjectType.Loader)
    self.loader.gameObjectName = "HtmlImage"
    self.loader.fill = FillType.ScaleFree
    self.loader.touchable = false
end

---@param owner FairyGUI.RichTextField
---@param element Utils.HtmlElement
function HtmlImage:Create(owner, element)
    self._owner = owner
    self._element = element

    local sourceWidth = 0
    local sourceHeight = 0
    local texture = owner.htmlPageContext:GetImageTexture(self)
    if texture ~= nil then
        sourceWidth = texture.width
        sourceHeight = texture.height

        self.loader.texture = texture
        self._externalTexture = true
    else
        local src = element:GetString("src")
        if src ~= nil then
            local pi = UIPackage.GetItemByURL(src)
            if pi ~= nil then
                sourceWidth = pi.width
                sourceHeight = pi.height
            end
        end

        self.loader.url = src
        self._externalTexture = false
    end

    local width = element:GetInt("width", sourceWidth)
    local height = element:GetInt("height", sourceHeight)

    if width == 0 then
        width = 5
    end
    if height == 0 then
        height = 10
    end
    self.loader:SetSize(width, height)
end

---@param x number
---@param y number
function HtmlImage:SetPosition(x, y)
    self.loader:SetXY(x, y)
end

function HtmlImage:Add()
    self._owner:AddChild(self.loader.displayObject)
end

function HtmlImage:Remove()
    if self.loader.displayObject.parent ~= nil then
        self._owner:RemoveChild(self.loader.displayObject)
    end
end

function HtmlImage:Release()
    self.loader:RemoveEventListeners()
    if self._externalTexture then
        self._owner.htmlPageContext:FreeImageTexture(self, self.loader.texture)
        self._externalTexture = false
    end

    self.loader.url = nil
    self._owner = nil
    self._element = nil
end

function HtmlImage:Dispose()
    if self._externalTexture then
        self._owner.htmlPageContext:FreeImageTexture(self, self.loader.texture)
    end
    self.loader:Dispose()
end

local __get = Class.init_get(HtmlImage)

---@param self Utils.HtmlImage
__get.displayObject = function(self) return self.loader.displayObject end

---@param self Utils.HtmlImage
__get._element = function(self) return self._element end

---@param self Utils.HtmlImage
__get.width = function(self) return self.loader.width end

---@param self Utils.HtmlImage
__get.height = function(self) return self.loader.height end


Utils.HtmlImage = HtmlImage
return HtmlImage