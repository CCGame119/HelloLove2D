--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/9 14:09
--

local Class = require('libs.Class')

local Debug = Love2DEngine.Debug
local AssetItem = Love2DEngine.AssetItem
local AssetType = Love2DEngine.AssetType
local Texture2D = Love2DEngine.Texture2D

---==============Resources=================
---@class Love2DEngine.Resources:ClassType
local Resources = Class.inheritsFrom('Resources')

---@type table<string, Love2DEngine.AssetItem> 图片资源列表
local AssetsPool = {}
Resources.AssetsPool = AssetsPool

---@param uri string
---@return Love2DEngine.AssetItem
function Resources.getImg(uri)
    local img = AssetsPool[uri]
    if nil == img then
        img = AssetItem.new(uri, AssetType.image)
    end
    return img:retain()
end

---@param uri string
function Resources.returnImg(uri)
    local img = AssetsPool[uri]
    if nil ~= img then
        img:release()
    end
end

---@param name string
---@param extension string
---@param type Love2DEngine.AssetType
---@return any
function Resources.Load(uri, type)
    uri = "Assets/" .. uri
    if AssetType.text == type then
        local file = love.filesystem.newFile(uri)
        local ok, err = file:open('r')
        if not ok then
            Debug.LogError(err)
            return nil
        end
        local data, size = file:read()
        file:close()
        return data, size
    elseif AssetType.tex2d == type then
        return Texture2D.new(Resources.getImg(uri))
    end
end

---@param assetToUnload Love2DEngine.Object
function Resources.UnloadAsset(assetToUnload)
    --TODO: Resources.UnloadAsset
end

Love2DEngine.Resources = Resources
return Resources