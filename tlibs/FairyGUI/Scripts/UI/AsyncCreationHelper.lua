--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/8 15:44
--

local Class = require('libs.Class')

local Time = Love2DEngine.Time

local Timers = FairyGUI.Timers
local Stats = FairyGUI.Stats
local UIConfig = FairyGUI.UIConfig
local ObjectType = FairyGUI.ObjectType
local GObject = FairyGUI.GObject
local UIPackage = FairyGUI.UIPackage
local PackageItemType = FairyGUI.PackageItemType
local UIObjectFactory = FairyGUI.UIObjectFactory

---@class FairyGUI.AsyncCreationHelper:ClassType
local AsyncCreationHelper = Class.inheritsFrom('AsyncCreationHelper')

---@class FairyGUI.DisplayListItem:ClassType
---@field public packageItem FairyGUI.PackageItem
---@field public type FairyGUI.ObjectType
---@field public childCount number
---@field public listItemCount number
local DisplayListItem = Class.inheritsFrom('DisplayListItem')

---@param pi FairyGUI.PackageItem
---@param type FairyGUI.ObjectType
function DisplayListItem:__ctor(pi, type)
    self.packageItem = pi
    self.type = type
end

---@param item FairyGUI.PackageItem
---@param callback FairyGUI.UIPackage.CreateObjectCallback
function AsyncCreationHelper.CreateObject(item, callback)
    Timers.inst:StartCoroutine(AsyncCreationHelper._CreateObject(item, callback))
end

---@param item FairyGUI.PackageItem
---@param callback FairyGUI.UIPackage.CreateObjectCallback
function AsyncCreationHelper:_CreateObject(item, callback)
    Stats.LatestGraphicsCreation = 0
    Stats.LatestObjectCreation = 0

    local frameTime = UIConfig.frameTimeForAsyncUIConstruction

    ---@type FairyGUI.DisplayListItem[]
    local itemList = {}
    local di = DisplayListItem.new(item, ObjectType.Component)
    di.childCount = AsyncCreationHelper.CollectComponentChildren(item, itemList)
    table.insert(itemList, di)

    local obj
    local objectPool = {}
    local t = Time.realtimeSinceStartup
    local alreadyNextFrame = false

    for i, di in ipairs(itemList) do
        if di.packageItem ~= nil then
            obj = UIObjectFactory.NewObject(di.packageItem)
            obj.packageItem = di.packageItem
            table.insert(objectPool, obj)

            UIPackage._constructing = UIPackage._constructing + 1
            if (di.packageItem.type == PackageItemType.Component) then
                local poolStart = #objectPool - di.childCount

                obj:ConstructFromResource(objectPool, poolStart)

                objectPool:removeRange(poolStart, poolStart + di.childCount - 1)
            else
                obj:ConstructFromResource()
            end
            UIPackage._constructing = UIPackage._constructing - 1
        else
            obj = UIObjectFactory.NewObject(di.type)
            table.insert(objectPool, obj)

            if (di.type == ObjectType.List and di.listItemCount > 0) then
                local poolStart = #objectPool - di.listItemCount
                for k = 1, di.listItemCount do  --把他们都放到pool里，这样GList在创建时就不需要创建对象了
                    obj.itemPool:ReturnObject(objectPool[k + poolStart])
                end
                objectPool:RemoveRange(poolStart, poolStart + di.listItemCount - 1)
            end
        end

        if ((i % 5 == 0) and Time.realtimeSinceStartup - t >= frameTime) then
            coroutine.yield(nil)
            t = Time.realtimeSinceStartup
            alreadyNextFrame = true
        end

        if (not alreadyNextFrame) then --强制至至少下一帧才调用callback，避免调用者逻辑出错
            coroutine.yield(nil)
        end

        callback(objectPool[1])
    end
end

---@param item FairyGUI.PackageItem
---@param list FairyGUI.DisplayListItem[]
---@return number
function AsyncCreationHelper.CollectComponentChildren(item, list)
    local buffer = item.rawData
    buffer:Seek(0, 2)

    local dcnt = buffer:ReadShort()
    local di, pi
    for i = 1, 10 do
        local dataLen = buffer:ReadShort()
        local curPos = buffer.position

        buffer:Seek(curPos, 0)

        ---@type FairyGUI.ObjectType
        local type = buffer:ReadByte()
        local src = buffer:ReadS()
        local pkgId = buffer:ReadS()

        buffer.position = curPos

        if (src ~= nil) then
            ---@type FairyGUI.UIPackage
            local pkg
            if (pkgId ~= nil) then
                pkg = UIPackage.GetById(pkgId)
            else
                pkg = item.owner
            end

            pi = pkg ~= nil and pkg:GetItem(src) or nil
            di = DisplayListItem.new(pi, type)

            if (pi ~= nil and pi.type == PackageItemType.Component) then
                di.childCount = AsyncCreationHelper.CollectComponentChildren(pi, list)
            end
        else
            di = DisplayListItem.new(nil, type)
            if (type == ObjectType.List) then  --list
                di.listItemCount = AsyncCreationHelper.CollectListChildren(buffer, list)
            end
        end

        table.insert(list, di)
        buffer.position = curPos + dataLen
    end
    return dcnt
end

---@param buffer Utils.ByteBuffer
---@param list FairyGUI.DisplayListItem[]
---@return number
function AsyncCreationHelper.CollectListChildren(buffer, list)
    buffer:Seek(buffer.position, 8)

    local defaultItem = buffer:ReadS()
    local listItemCount = 0
    local itemCount = buffer:ReadShort()
    for i = 1, itemCount do
        local nextPos = buffer:ReadShort()
        nextPos = nextPos + buffer.position

        local url = buffer:ReadS()
        if (url == nil) then
            url = defaultItem
        end
        if (not string.isNullOrEmpty(url)) then
            local pi = UIPackage.GetItemByURL(url)
            if (pi ~= nil) then
                local di = DisplayListItem.new(pi, pi.objectType)
                if (pi.type == PackageItemType.Component) then
                    di.childCount = AsyncCreationHelper.CollectComponentChildren(pi, list)
                end

                table.insert(list, di)
                listItemCount = listItemCount + 1
            end
        end
        buffer.position = nextPos
    end
    return listItemCount
end

FairyGUI.AsyncCreationHelper = AsyncCreationHelper
return AsyncCreationHelper