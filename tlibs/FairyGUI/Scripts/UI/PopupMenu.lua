--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:48
--

local Class = require('libs.Class')

local Debug = Love2DEngine.Debug

local UIPackage = FairyGUI.UIPackage
local RelationType = FairyGUI.RelationType
local EventCallback0 = FairyGUI.EventCallback0
local EventCallback1 = FairyGUI.EventCallback1
local UIConfig = FairyGUI.UIConfig
local GRoot = FairyGUI.GRoot

---@class FairyGUI.PopupMenu:ClassType
---@field public itemCount number
---@field public contentPane FairyGUI.GComponent
---@field public list FairyGUI.GList
---@field protected _contentPane FairyGUI.GComponent
---@field protected _list FairyGUI.GList
local PopupMenu = Class.inheritsFrom('PopupMenu')

---@param resourceURL string
function PopupMenu:__ctor(resourceURL)
    self.__clickItemDelegate = EventCallback0.new(self.__clickItem, self)
    self.__addedToStageDelegate = EventCallback1.new(self.__addedToStage, self)

    self:Create(resourceURL)
end

---@param resourceURL string
function PopupMenu:Create(resourceURL)
    if (resourceURL == nil) then
        resourceURL = UIConfig.popupMenu
        if (resourceURL == nil) then
            Debug.LogError("FairyGUI: UIConfig.popupMenu not defined")
            return
        end
    end

    self._contentPane = UIPackage.CreateObjectFromURL(resourceURL).asCom
    self._contentPane.onAddedToStage:Add(self.__addedToStageDelegate)

    self._list = self._contentPane:GetChild("list").asList
    self._list:RemoveChildrenToPool()

    self._list:AddRelation(self._contentPane, RelationType.Width)
    self._list:RemoveRelation(self._contentPane, RelationType.Height)
    self._contentPane:AddRelation(self._list, RelationType.Height)

    self._list.onClickItem:Add(self.__clickItemDelegate)
end

---@overload fun(caption:string, callback:FairyGUI.EventCallback1)
---@param caption string
---@param callback FairyGUI.EventCallback0
function PopupMenu:AddItem(caption, callback)
    local item = self._list:AddItemFromPool().asButton
    item.title = caption
    item.data = callback
    item.grayed = false
    local c = item:GetController("checked")
    if (c ~= nil) then
        c.selectedIndex = 0
    end

    return item
end

---@overload fun(caption:string, index:number, callback:FairyGUI.EventCallback1)
---@param caption string
---@param index number
---@param callback FairyGUI.EventCallback0
function PopupMenu:AddItemAt(caption, index, callback)
    local obj = self._list:GetFromPool(self._list.defaultItem)
    self._list:AddChildAt(obj, index)

    ---@type FairyGUI.GButton
    local item = obj
    item.title = caption
    item.data = callback
    item.grayed = false
    local c = item.GetController("checked")
    if (c ~= nil) then
        c.selectedIndex = 0
    end

    return item
end

function PopupMenu:AddSeperator()
    if (UIConfig.popupMenu_seperator == nil) then
        Debug.LogError("FairyGUI: UIConfig.popupMenu_seperator not defined")
        return
    end

    self._list:AddItemFromPool(UIConfig.popupMenu_seperator)
end

---@param index number
---@return string
function PopupMenu:GetItemName(index)
    local item = self._list:GetChildAt(index).asButton
    return item.name
end

---@param name string
---@param caption string
function PopupMenu:SetItemText(name, caption)
    local item = self._list:GetChild(name).asButton
    item.title = caption
end

---@param name string
---@param visible boolean
function PopupMenu:SetItemVisible(name, visible)
    local item = self._list:GetChild(name).asButton
    if item.visible ~= visible then
        item.visible = visible
        self._list:SetBoundsChangedFlag()
    end
end

---@param name string
---@param grayed boolean
function PopupMenu:SetItemGrayed(name, grayed)
    local item = self._list:GetChild(name).asButton
    item.grayed = grayed
end

---@param name string
---@param checkable boolean
function PopupMenu:SetItemCheckable(name, checkable)
    local item = self._list:GetChild(name).asButton
    local c = item:GetController("checked")
    if c ~= nil then
        if checkable then
            if c.selectedIndex == 0 then
                c.selectedIndex = 1
            end
        else
            c.selectedIndex = 0
        end
    end
end

---@param name string
---@param check boolean
function PopupMenu:SetItemChecked(name, check)
    local item = self._list:GetChild(name).asButton
    local c = item:GetController("checked")
    if c ~= nil then
        c.selectedIndex = check and 2 or 1
    end
end

---@param name string
---@return boolean
function PopupMenu:isItemChecked(name)
    local item = self._list:GetChild(name).asButton
    local c = item:GetController("checked")
    if c ~= nil then
        return c.selectedIndex == 2
    end
    return false
end

---@param name string
---@return boolean
function PopupMenu:RemoveItem(name)
    local item = self._list:GetChild(name).asCom
    if item ~= nil then
        local index = self._list:GetChildIndex(item)
        self._list:RemoveChildToPoolAt(index)
        return true
    end
    return false
end

function PopupMenu:ClearItems()
    self._list:RemoveChildrenToPool()
end

function PopupMenu:Dispose()
    self._contentPane:Dispose()
end

---@overload fun()
---@param target FairyGUI.GObject
---@param downward any
function PopupMenu:Show(target, downward)
    local r = target ~= nil and target.root or GRoot.inst
    r:ShowPopup(self.contentPane, target:isa(GRoot) and nil or target, downward)
end

function PopupMenu:__clickItem(context)
    local item = context.data.asButton
    if (item == nil) then
        return
    end

    if (item.grayed) then
        self._list.selectedIndex = -1
        return
    end

    local c = item:GetController("checked")
    if (c ~= nil and c.selectedIndex ~= 0) then
        if (c.selectedIndex == 1) then
            c.selectedIndex = 2
        else
            c.selectedIndex = 1
        end
    end

    local r = self._contentPane.parent
    r:HidePopup(self.contentPane)
    if item.data:isa(EventCallback0) then
        item.data()
    elseif item.data:isa(EventCallback1) then
        item.data(context)
    end
end

function PopupMenu:__addedToStage()
    self._list.selectedIndex = -1
    self._list:ResizeToFit(math.maxval, 10)
end


local __get = Class.init_get(PopupMenu)
local __set = Class.init_set(PopupMenu)

---@param self FairyGUI.PopupMenu
__get.itemCount = function(self) return #self._list.numChildren end

---@param self FairyGUI.PopupMenu
__get.contentPane = function(self) return self._contentPane end

---@param self FairyGUI.PopupMenu
__get.list = function(self) return self._list end


FairyGUI.PopupMenu = PopupMenu
return PopupMenu