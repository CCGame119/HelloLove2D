--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2019/1/29 17:04
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
---@field public uri string @资源uri
---@field public type number @资源类型
---@field public obj userdata @资源类型
---@field public refCount number @引用计数
---@field public refTime number @最后一次被引用时间
---@field public img love.image
---@field public width number @图片宽度
---@field public height number @图片高度
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
    return self
end

function AssetItem:release()
    self.refCount = self.refCount - 1
end

local __get = Class.init_get(AssetItem)

---@param self Love2DEngine.AssetItem
__get.img = function(self)
    return self.obj
end

---@param self Love2DEngine.AssetItem
__get.width = function(self)
    return self.obj:getWidth()
end

---@param self Love2DEngine.AssetItem
__get.height = function(self)
    return self.obj:getHeight()
end

---@param self Love2DEngine.AssetItem
__get.format = function(self)
    return self.obj:getFormat()
end

Love2DEngine.AssetType = AssetType
Love2DEngine.AssetItem = AssetItem
return AssetItem