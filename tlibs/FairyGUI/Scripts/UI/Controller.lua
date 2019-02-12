--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:39
--

local Class = require('libs.Class')

local EventDispatcher = FairyGUI.EventDispatcher
local EventListener = FairyGUI.EventListener
local ControllerAction = FairyGUI.ControllerAction

---@class FairyGUI.Controller:FairyGUI.EventDispatcher
---控制器类。控制器的创建和设计需通过编辑器完成，不建议使用代码创建。
---最常用的方法是通过selectedIndex获得或改变控制器的活动页面。如果要获得控制器页面改变的通知，使用onChanged事件。
---@field public name string @Name of the controller. 控制器名称。
---@field public onChanged FairyGUI.EventListener @When controller page changed. 当控制器活动页面改变时，此事件被触发。
---@field public parent FairyGUI.GComponent @internal
---@field public autoRadioGroupDepth boolean @internal
---@field public changing boolean @internal
---@field public selectedPageId string
---@field public selectedIndex number @Current page index. 获得或设置当前活动页面索引。
---@field public selectedPage string @Current page name. 获得当前活动页面名称
---@field public previousPage string @Previous page name. 获得上次活动页面名称。
---@field public pageCount number @Page count of this controller. 获得页面数量。
---@field public selectedPageId string
---@field public oppositePageId string
---@field public previousPageId string
---@field private _selectedIndex number
---@field private _previousIndex number
---@field private _pageIds string[]
---@field private _pageNames string[]
---@field private _actions FairyGUI.ControllerAction[]
local Controller = Class.inheritsFrom('Controller', nil, EventDispatcher)

Controller._nextPageId = 0

function Controller:__ctor()
    self._pageIds = {}
    self._pageNames = {}
    self._selectedIndex = 0
    self._previousIndex = 0

    self.onChanged = EventListener.new(self, "onChanged")
end

function Controller:Dispose()
    self:RemoveEventListeners()
end

---Set current page index, no onChanged event.
---通过索引设置当前活动页面，和selectedIndex的区别在于，这个方法不会触发onChanged事件。
---@param value number @Page index
function Controller:SetSelectedIndex(value)
    if (self._selectedIndex ~= value) then
        if (value > #self._pageIds) then
            error('IndexOutOfRangeException: ' .. value)
        end

        self.changing = true
        self._previousIndex = self._selectedIndex
        self._selectedIndex = value
        self.parent:ApplyController(self)
        self.changing = false
    end
end

---Set current page by name, no onChanged event.
---通过页面名称设置当前活动页面，和selectedPage的区别在于，这个方法不会触发onChanged事件。
---@param value string @Page name
function Controller:SetSelectedPage(value)
    local i = self._pageNames:indexOf(value)
    if (i == -1) then
        i = 1
    end
    self:SetSelectedIndex(i)
end

---Get page name by an index.
---通过页面索引获得页面名称。
---@param index number @Page index
function Controller:GetPageName(index)
    return self._pageNames[index]
end

---Get page id by name
---通过页面名称获得页面索引。
---@param aName string @Page name
function Controller:GetPageIdByName(aName)
    local i = self._pageNames:indexOf(aName)
    if i ~= -1 then
        return self._pageIds[i]
    end
    return nil
end

---Add a new page to this controller.
---@param name string @Page name
function Controller:AddPage(name)
    if name == nil then
        name = ''
    end
    self:AddPageAt(name, #self._pageIds + 1)
end

---Add a new page to this controller at a certain index.
---@param name string @Page name
---@param index number @Insert position
function Controller:AddPageAt(name, index)
    local nid = '_' .. self._nextPageId
    self._nextPageId = self._nextPageId + 1
    table.insert(self._pageIds, index, nid)
    table.insert(self._pageNames, index, name)
end

---Remove a page.
---@param name string @Page name
function Controller:RemovePage(name)
    local i = self._pageNames:indexOf(name)
    if i ~= -1 then
        self:RemovePageAt(i)
    end
end

---Remove all pages
function Controller:ClearPages()
    self._pageIds = {}
    self._pageNames = {}
    if self._selectedIndex ~= 0 then
        self._selectedIndex = 0
    else
        self.parent:ApplyController(self)
    end
end

---Check if the controller has a page.
---@param aName string @Page name
function Controller:HasPage(aName)
    return self._pageNames:indexOf(aName) ~= -1
end

function Controller:GetPageIndexById(aId)
    return self._pageIds:indexOf(aId)
end

function Controller:GetPageNameById(aId)
    local i = self._pageIds:indexOf(aId)
    if i ~= -1 then
        return self._pageNames[i]
    end
    return nil
end

function Controller:GetPageId(index)
    return self._pageIds[index]
end


---Removes a page at a certain index.
---@param index number
function Controller:RemovePageAt(index)
    table.remove(self._pageIds, index)
    table.remove(self._pageNames, index)
    if self._selectedIndex > #self._pageIds then
        self._selectedIndex = self._selectedIndex - 1
    else
        self.parent:ApplyController(self)
    end
end

function Controller:RunActions()
    if self._actions ~= nil then
        for i, v in ipairs(self._actions) do
            v:Run(self, self.previousPageId, self.selectedPageId)
        end
    end
end

---@param buffer Utils.ByteBuffer
function Controller:Setup(buffer)
    local beginPos = buffer.position
    buffer:Seek(beginPos, 0)

    self.name = buffer:ReadS()
    self.autoRadioGroupDepth = buffer:ReadBool()

    buffer:Seek(beginPos, 1)

    local cnt = buffer:ReadShort()
    for i = 1, cnt do
        table.insert(self._pageIds, buffer:ReadS())
        table.insert(self._pageNames, buffer:ReadS())
    end

    buffer:Seek(beginPos, 2)

    cnt = buffer:ReadShort()
    if (cnt > 0) then
        if (self._actions == nil) then
            self._actions = {}
        end

        for i = 1, cnt do
            local nextPos = buffer:ReadShort()
            nextPos = nextPos + buffer.position

            ---@type FairyGUI.ControllerAction
            local action = ControllerAction.CreateAction(buffer:ReadByte())
            action:Setup(buffer)
            table.insert(self._actions, action)

            buffer.position = nextPos
        end
    end

    if (self.parent ~= nil and #self._pageIds > 0) then
        self._selectedIndex = 1
    else
        self._selectedIndex = 0
    end
end


local __get = Class.init_get(Controller)
local __set = Class.init_set(Controller)

---@param self FairyGUI.Controller
__get.selectedIndex = function(self) return self._selectedIndex end

---@param self FairyGUI.Controller
---@param val number
__set.selectedIndex = function(self, val)
    if val ~= self._selectedIndex then
        if val > #self._pageIds then
            error('IndexOutOfRangeException: ' .. val)
        end

        self.changing = true

        self._previousIndex = self._selectedIndex
        self._selectedIndex = val
        self.parent:ApplyController(self)

        self.onChanged:Call()

        self.changing = false
    end
end

---@param self FairyGUI.Controller
__get.selectedPage = function(self)
    return self._pageNames[self._selectedIndex]
end

---@param self FairyGUI.Controller
---@param val string
__set.selectedPage = function(self, val)
    local i = table.indexOf(self._pageNames, val)
    if i == -1 then
        i = 1
    end
    self._selectedIndex = i
end

---@param self FairyGUI.Controller
__get.previousPage = function(self)
    return self._pageNames[self._previousIndex]
end

---@param self FairyGUI.Controller
__get.pageCount = function(self)
    return #self._pageIds
end

---@param self FairyGUI.Controller
__get.selectedPageId = function(self)
    if self._selectedIndex == 0 then
        return nil
    end
    return self._pageIds[self._selectedIndex]
end

---@param self FairyGUI.Controller
---@param val string
__set.selectedPageId = function(self, val)
    local i = self._pageIds:indexOf(val)
    if i ~= -1 then
        self.selectedIndex = i
    end
end

---@param self FairyGUI.Controller
---@param val string
__set.oppositePageId = function(self, val)
    local i = self._pageIds:indexOf(val)
    if i > 1 then
        self.selectedIndex = 1
    elseif #self._pageIds > 1 then
        self.selectedIndex = 2
    end
end

---@param self FairyGUI.Controller
__get.previousPageId = function(self)
    if self._previousIndex == 0 then
        return nil
    end
    return self._pageIds[self._previousIndex]
end


FairyGUI.Controller = Controller
return Controller