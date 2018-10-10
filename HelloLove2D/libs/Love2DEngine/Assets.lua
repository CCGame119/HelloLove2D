--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/9 14:09
--

local Class = require('libs.Class')

---@class Love2DEngine.AssetType @ 资源类型
local AssetType = {
    image = 1,
    sfx = 2,
    shader = 3,
    mesh = 4,
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

---==============Assets=================
---@class Love2DEngine.Assets:ClassType
local Assets = Class.inheritsFrom('Assets')

---@type table<string, Love2DEngine.AssetItem> 图片资源列表
local imgs = {}
Assets.imgs = imgs

---@param uri string
---@return image
function Assets.getImg(uri)
    local img = imgs[uri]
    if nil == img then
        img = AssetItem.new(uri, AssetType.image)
    end
    return img:retain()
end

---@param uri string
function Assets.returnImg(uri)
    local img = imgs[uri]
    if nil ~= img then
        img:release()
    end
end

Love2DEngine.AssetType = AssetType
Love2DEngine.AssetItem = AssetItem
Love2DEngine.Assets = Assets
return Assets