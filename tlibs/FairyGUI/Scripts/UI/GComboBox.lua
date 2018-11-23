--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:53
--

local Class = require('libs.Class')

local GComponent = FairyGUI.GComponent
local UIConfig = FairyGUI.UIConfig
local EventListener = FairyGUI.EventListener
local PopupDirection = FairyGUI.PopupDirection

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
end

---@return FairyGUI.GTextField
function GComboBox:GetTextField() end

---@param value string
function GComboBox:SetState(value) end

function GComboBox:SetCurrentState() end

function GComboBox:HandleGrayedChanged()
end

function GComboBox:HandleControllerChanged(c)
end

function GComboBox:UpdateSelectionController() end

function GComboBox:Dispose()
end

function GComboBox:ConstructExtension(buffer)
end

function GComboBox:Setup_AfterAdd(buffer, beginPos)
end

function GComboBox:UpdateDropdownList() end

function GComboBox:ShowDropdown() end

function GComboBox:RenderDropdownList() end

---@param obj any
function GComboBox:__popupWinClosed(obj) end

---@param context FairyGUI.EventContext
function GComboBox:__clickItem(context) end

function GComboBox:__rollover() end
function GComboBox:__rollout() end

---@param context FairyGUI.EventContext
function GComboBox:__touchBegin(context) end

---@param context FairyGUI.EventContext
function GComboBox:__touchEnd(context) end


--TODO: FairyGUI.GComboBox

FairyGUI.GComboBox = GComboBox
return GComboBox