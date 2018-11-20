--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/9 14:09
--

local Class = require('libs.Class')

---@class Love2DEngine.AssetType:enum @ 资源类型
local AssetType = {
    image = 1,
    sfx = 2,
    shader = 3,
    mesh = 4,
    text = 5,
    tex2d = 6,
}

---==============AssetItem=================
---@class Love2DEngine.AssetItem:ClassType
---@field uri string @资源uri
---@field type number @资源类型
---@field obj userdata @资源类型
---@field refCount number @引用计数
---@field refTime number @最后一次被引用时间
local AssetItem = Class.inheritsFrom('AssetItem')

function AssetItem:__ctor(uri, type)
    self.refCount = 0
    self.refTime = 0
    self.uri = uri
    self.type = type
    if AssetType.image == type then
        self.obj = love.graphics.newImage(uri)
    end
end

function AssetItem:retain()
    self.refCount = self.refCount + 1
    self.refTime = os.time()
    return self.obj
end

function AssetItem:release()
    self.refCount = self.refCount - 1
end

---==============Resources=================
---@class Love2DEngine.Resources:ClassType
local Resources = Class.inheritsFrom('Resources')

---@type table<string, Love2DEngine.AssetItem> 图片资源列表
local imgs = {}
Resources.imgs = imgs

---@param uri string
---@return image
function Resources.getImg(uri)
    local img = imgs[uri]
    if nil == img then
        img = AssetItem.new(uri, AssetType.image)
    end
    return img:retain()
end

---@param uri string
function Resources.returnImg(uri)
    local img = imgs[uri]
    if nil ~= img then
        img:release()
    end
end

---@param assetToUnload Love2DEngine.Object
function Resources.UnloadAsset(assetToUnload)
    --TODO: Resources.UnloadAsset
end

Love2DEngine.AssetType = AssetType
Love2DEngine.AssetItem = AssetItem
Love2DEngine.Resources = Resources
return Resources