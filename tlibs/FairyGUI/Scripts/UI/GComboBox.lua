--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:53
--

local Class = require('libs.Class')

local Color = Love2DEngine.Color
local Debug = Love2DEngine.Debug

local GComponent = FairyGUI.GComponent
local UIConfig = FairyGUI.UIConfig
local EventListener = FairyGUI.EventListener
local PopupDirection = FairyGUI.PopupDirection
local GTextField = FairyGUI.GTextField
local GLabel = FairyGUI.GLabel
local GButton = FairyGUI.GButton
local RelationType = FairyGUI.RelationType
local UIPackage = FairyGUI.UIPackage
local EventCallback0 = FairyGUI.EventCallback0
local EventCallback1 = FairyGUI.EventCallback1
local ListSelectionMode = FairyGUI.ListSelectionMode
local GRoot = FairyGUI.GRoot
local InputTextField = FairyGUI.InputTextField

---@class FairyGUI.GComboBox:FairyGUI.GComponent
---@field public visibleItemCount number @Visible item count of the drop down list.
---@field public onChanged FairyGUI.EventListener @Dispatched when selection was changed.
---@field public dropdown FairyGUI.GComponent @
---@field public icon string
---@field public title string
---@field public text string
---@field public titleColor Love2DEngine.Color
---@field public titleFontSize number
---@field public items string[]
---@field public icons string[]
---@field public values string[]
---@field public selectedIndex number
---@field public selectionController FairyGUI.Controller
---@field public value string
---@field public popupDirection FairyGUI.PopupDirection
---@field protected _titleObject FairyGUI.GObject
---@field protected _iconObject FairyGUI.GObject
---@field protected _list FairyGUI.GList
---@field protected _items string[]
---@field protected _icons string[]
---@field protected _values string[]
---@field protected _popupDirection FairyGUI.PopupDirection
---@field protected _selectionController FairyGUI.Controller
---@field private _itemsUpdated boolean
---@field private _selectedIndex number
---@field private _buttonController FairyGUI.Controller
---@field private _down boolean
---@field private _over boolean
local GComboBox = Class.inheritsFrom('GComboBox', nil, GComponent)

function GComboBox:__ctor()
    GComponent.__ctor(self)

    self.visibleItemCount = UIConfig.defaultComboBoxVisibleItemCount
    self._itemsUpdated = true
    self._selectedIndex = -1
    self._items = {}
    self._values = {}
    self._popupDirection = PopupDirection.Auto

    self.onChanged = EventListener.new(self, "onChanged")

    self.__rolloverDelegate = EventCallback0.new(self.__rollover, self)
    self.__rolloutDelegate = EventCallback0.new(self.__rollout, self)
    self.__touchBeginDelegate = EventCallback1.new(self.__touchBegin, self)
    self.__touchEndDelegate = EventCallback1.new(self.__touchEnd, self)
    self.__clickItemDelegate = EventCallback1.new(self.__clickItem, self)
    self.__popupWinClosedDelegate = EventCallback1.new(self.__popupWinClosed, self)
end

---@return FairyGUI.GTextField
function GComboBox:GetTextField()
    if self._titleObject:isa(GTextField) then
        return self._titleObject
    elseif self._titleObject:isa(GLabel) then
        return self._titleObject:GetTextField()
    elseif self._titleObject:isa(GButton) then
        return self._titleObject:GetTextField()
    else
        return nil
    end
end

---@param value string
function GComboBox:SetState(value)
    if (self._buttonController ~= nil) then
        self._buttonController.selectedPage = value
    end
end

function GComboBox:SetCurrentState()
    if (self.grayed and self._buttonController ~= nil and self._buttonController:HasPage(GButton.DISABLED)) then
        self:SetState(GButton.DISABLED)
    elseif (self.dropdown ~= nil and self.dropdown.parent ~= nil) then
        self:SetState(GButton.DOWN)
    else
        self:SetState(self._over and GButton.OVER or GButton.UP)
    end
end

function GComboBox:HandleGrayedChanged()
    if (self._buttonController ~= nil and self._buttonController:HasPage(GButton.DISABLED)) then
        if (self.grayed) then
            self:SetState(GButton.DISABLED)
        else
            self:SetState(GButton.UP)
        end
    else
        GComponent.HandleGrayedChanged(self)
    end
end

function GComboBox:HandleControllerChanged(c)
    GComponent.HandleControllerChanged(self, c)

    if self._selectionController == c then
        self.selectedIndex = c.selectedIndex
    end
end

function GComboBox:UpdateSelectionController()
    if (self._selectionController ~= nil and not self._selectionController.changing
            and self._selectedIndex < self._selectionController.pageCount) then
        local c = self._selectionController
        self._selectionController = nil
        c.selectedIndex = self._selectedIndex
        self._selectionController = c
    end
end

function GComboBox:Dispose()
    if (self.dropdown ~= nil) then
        self.dropdown:Dispose()
        self.dropdown = nil
    end
    self._selectionController = nil

    GComponent.Dispose(self)
end

function GComboBox:ConstructExtension(buffer)
    buffer:Seek(0, 6)

    self._buttonController = self:GetController("button")
    self._titleObject = self:GetChild("title")
    self._iconObject = self:GetChild("icon")

    local str = buffer:ReadS()
    if (str ~= nil) then
        self.dropdown = UIPackage.CreateObjectFromURL(str)
        if (self.dropdown == nil) then
            Debug.LogWarn("FairyGUI: " .. self.resourceURL .. " should be a component.")
            return
        end

        self._list = self.dropdown:GetChild("list")
        if (self._list == nil) then
            Debug.LogWarn("FairyGUI: " .. self.resourceURL .. ": should container a list component named list.")
            return
        end
        self._list.onClickItem:Add(self.__clickItemDelegate)

        self._list:AddRelation(self.dropdown, RelationType.Width)
        self._list:RemoveRelation(self.dropdown, RelationType.Height)

        self.dropdown:AddRelation(self._list, RelationType.Height)
        self.dropdown:RemoveRelation(self._list, RelationType.Width)

        self.dropdown:SetHome(self)
    end

    self.displayObject.onRollOver:Add(self.__rolloverDelegate)
    self.displayObject.onRollOut:Add(self.__rolloutDelegate)
    self.displayObject.onTouchBegin:Add(self.__touchBeginDelegate)
    self.displayObject.onTouchEnd:Add(self.__touchEndDelegate)
end

function GComboBox:Setup_AfterAdd(buffer, beginPos)
    GComponent.Setup_AfterAdd(self, buffer, beginPos)

    if (not buffer:Seek(beginPos, 6)) then
        return
    end

    if (buffer:ReadByte() ~= self.packageItem.objectType) then
        return
    end

    local str
    local itemCount = buffer:ReadShort()
    self._items = {}
    self._values = {}
    for i = 1, itemCount do
        local nextPos = buffer:ReadShort()
        nextPos = nextPos + buffer.position

        self._items[i] = buffer:ReadS()
        self._values[i] = buffer:ReadS()
        str = buffer:ReadS()
        if (str ~= nil) then
            if (self._icons == nil) then
                self._icons = {}
            end
            self._icons[i] = str
        end

        buffer.position = nextPos
    end

    str = buffer:ReadS()
    if (str ~= nil) then
        self.text = str
        self._selectedIndex = self._items:indexOf(str)
    elseif (#self._items > 0) then
        self._selectedIndex = 1
        self.text = self._items[1]
    else
        self._selectedIndex = -1
    end

    str = buffer:ReadS()
    if (str ~= nil) then
        self.icon = str
    end

    if (buffer:ReadBool()) then
        self.titleColor = buffer:ReadColor()
    end
    local iv = buffer:ReadInt()
    if (iv > 0) then
        self.visibleItemCount = iv
    end
    self._popupDirection = buffer:ReadByte()

    iv = buffer:ReadShort()
    if (iv >= 0) then
        self._selectionController = self.parent:GetControllerAt(iv + 1)
    end
end

function GComboBox:UpdateDropdownList()
    if self._itemsUpdated then
        self._itemsUpdated = false
        self:RenderDropdownList()
        self._list:ResizeToFit(self.visibleItemCount)
    end
end

function GComboBox:ShowDropdown()
    self:UpdateDropdownList()
    if (self._list.selectionMode == ListSelectionMode.Single) then
        self._list.selectedIndex = -1
    end
    self.dropdown.width = self.width

    local downward = nil
    if (self._popupDirection == PopupDirection.Down) then
        downward = true
    elseif (self._popupDirection == PopupDirection.Up) then
        downward = false
    end

    self.root:TogglePopup(self.dropdown, self, downward)
    if (self.dropdown.parent ~= nil) then
        self.dropdown.displayObject.onRemovedFromStage:Add(self.__popupWinClosedDelegate)
        self:SetState(GButton.DOWN)
    end
end

function GComboBox:RenderDropdownList()
    self._list:RemoveChildrenToPool()
    local cnt = #self._items
    for i = 1, cnt do
        local item = self._list:AddItemFromPool()
        item.text = self._items[i]
        item.icon = (self._icons ~= nil and i <= #self._icons) and self._icons[i] or nil
        item.name = i <= #self._values and self._values[i] or ''
    end
end

---@param obj any
function GComboBox:__popupWinClosed(obj)
    self.dropdown.displayObject.onRemovedFromStage:Remove(self.__popupWinClosedDelegate)
    self:SetCurrentState()
end

---@param context FairyGUI.EventContext
function GComboBox:__clickItem(context)
    if self.dropdown.parent:isa(GRoot) then
        self.dropdown.parent:HidePopup(self.dropdown)
    end
    self._selectedIndex = math.minval
    self.selectedIndex = self._list:GetChildIndex(context.data)

    self.onChanged:Call()
end

function GComboBox:__rollover()
    self._over = true
    if (self._down or self.dropdown ~= nil and self.dropdown.parent ~= nil) then
        return
    end

    self:SetCurrentState()
end

function GComboBox:__rollout()
    self._over = false
    if (self._down or self.dropdown ~= nil and self.dropdown.parent ~= nil) then
        return
    end

    self:SetCurrentState()
end

---@param context FairyGUI.EventContext
function GComboBox:__touchBegin(context)
    if context.initiator:isa(InputTextField) then
        return
    end

    self._down = true

    if (self.dropdown ~= nil) then
        self:ShowDropdown()
    end

    context:CaptureTouch()
end

---@param context FairyGUI.EventContext
function GComboBox:__touchEnd(context)
    if (self._down) then
        self._down = false
        if (self.dropdown ~= nil and self.dropdown.parent ~= nil) then
            self:SetCurrentState()
        end
    end
end


local __get = Class.init_get(GComboBox)
local __set = Class.init_set(GComboBox)

---@param self FairyGUI.GComboBox
__get.icon = function(self)
    if self._iconObject ~= nil then
        return self._iconObject.icon
    end
    return nil
end

---@param self FairyGUI.GComboBox
---@param val string
__set.icon = function(self, val)
    if self._iconObject ~= nil then
        self._iconObject.icon = val
    end

    self:UpdateGear(7)
end


---@param self FairyGUI.GComboBox
__get.title = function(self)
    if self._titleObject ~= nil then
        return self._titleObject.text
    end
    return nil
end

---@param self FairyGUI.GComboBox
---@param val string
__set.title = function(self, val)
    if self._titleObject ~= nil then
        self._titleObject.text = val
    end

    self:UpdateGear(6)
end


---@param self FairyGUI.GComboBox
__get.text = function(self) return self.title end

---@param self FairyGUI.GComboBox
---@param val string
__set.text = function(self, val) self.title = val end


---@param self FairyGUI.GComboBox
__get.titleColor = function(self)
    local tf = self:GetTextField()
    if nil ~= tf then
        return tf.color
    end
    return Color.black
end

---@param self FairyGUI.GComboBox
---@param val Love2DEngine.Color
__set.titleColor = function(self, val)
    local tf = self:GetTextField()
    if nil ~= tf then
        tf.color:Assign(val)
    end
end

---@param self FairyGUI.GComboBox
__get.titleFontSize = function(self)
    local tf = self:GetTextField()
    if nil ~= tf then
        return tf.textFormat.size
    end
    return 0
end

---@param self FairyGUI.GComboBox
---@param val number
__set.titleFontSize = function(self, val)
    local tf = self:GetTextField()
    if nil ~= tf then
        local format = self._titleObject.textFormat
        format.size = val
        tf.textFormat = format
    end
end


---@param self FairyGUI.GComboBox
__get.items = function(self) return self._items end

---@param self FairyGUI.GComboBox
---@param val string[]
__set.items = function(self, val)
    self._items = {}
    if (val ~= nil) then
        table.copy_l(val, self._items)
    end
    local cnt = #self._items
    if (cnt > 0) then
        if (self._selectedIndex > cnt) then
            self._selectedIndex = cnt
        elseif (self._selectedIndex == -1) then
            self._selectedIndex = 1
        end
        self.text = self._items[self._selectedIndex]
        if (self._icons ~= nil and self._selectedIndex < #self._icons) then
            self.icon = self._icons[self._selectedIndex]
        end
    else
        self.text = ''
        if (self._icons ~= nil) then
            self.icon = nil
        end
        self._selectedIndex = -1
    end
    self._itemsUpdated = true
end


---@param self FairyGUI.GComboBox
__get.icons = function(self) return self._icons end

---@param self FairyGUI.GComboBox
---@param val string[]
__set.icons = function(self, val)
    self._icons = {}
    table.copy_l(val, self._icons)
    if (self._icons ~= nil and self._selectedIndex ~= -1 and self._selectedIndex <= #self._icons) then
        self.icon = self._icons[self._selectedIndex]
    end
end


---@param self FairyGUI.GComboBox
__get.values = function(self) return self._values end

---@param self FairyGUI.GComboBox
---@param val string[]
__set.values = function(self, val)
    self._values = {}
    if (val ~= nil) then
        table.copy_l(val, self._values)
    end
end


---@param self FairyGUI.GComboBox
__get.selectedIndex = function(self) return self._selectedIndex end

---@param self FairyGUI.GComboBox
---@param val number
__set.selectedIndex = function(self, val)
    if (self._selectedIndex == val) then
        return
    end

    self._selectedIndex = val
    if (self._selectedIndex >= 1 and self._selectedIndex <= #self._items) then
        self.text = self._items[self._selectedIndex]
        if (self._icons ~= nil and self._selectedIndex <= #self._icons) then
            self.icon = self._icons[self._selectedIndex]
        end
    else
        self.text = ''
        if (self._icons ~= nil) then
            self.icon = nil
        end
    end

    self:UpdateSelectionController()
end


---@param self FairyGUI.GComboBox
__get.selectionController = function(self) return self._selectionController end

---@param self FairyGUI.GComboBox
---@param val FairyGUI.Controller
__set.selectionController = function(self, val) self._selectionController = val end


---@param self FairyGUI.GComboBox
__get.value = function(self)
    if (self._selectedIndex >= 1 and self._selectedIndex <= #self._values) then
        return self._values[self._selectedIndex]
    else
        return nil
    end
end

---@param self FairyGUI.GComboBox
---@param val string
__set.value = function(self, val)
    self.selectedIndex = self._values:indexOf(val)
end


---@param self FairyGUI.GComboBox
__get.popupDirection = function(self) return self._popupDirection end

---@param self FairyGUI.GComboBox
---@param val FairyGUI.PopupDirection
__set.popupDirection = function(self, val) self._popupDirection = val end


FairyGUI.GComboBox = GComboBox
return GComboBox