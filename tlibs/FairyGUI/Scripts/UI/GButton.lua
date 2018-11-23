--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:27
--

local Class = require('libs.Class')

local Color = Love2DEngine.Color

local Timers = FairyGUI.Timers
local GComponent = FairyGUI.GComponent
local IColorGear = FairyGUI.IColorGear
local UIConfig = FairyGUI.UIConfig
local PageOption = FairyGUI.PageOption
local EventListener = FairyGUI.EventListener
local ButtonMode = FairyGUI.ButtonMode
local GTextField = FairyGUI.GTextField
local GLabel = FairyGUI.GLabel
local UIPackage = FairyGUI.UIPackage
local EventCallback0 = FairyGUI.EventCallback0
local EventCallback1 = FairyGUI.EventCallback1
local Window = FairyGUI.Window
local Stage = FairyGUI.Stage

---@class FairyGUI.GButton:FairyGUI.GComponent @implement IColorGear
---@field public pageOption FairyGUI.PageOption @The button will be in down status in these pages.
---@field public sound FairyGUI.NAudioClip @Play sound when button is clicked.
---@field public soundVolumeScale number @Volume of the click sound. (0-1)
---@field public changeStateOnClick boolean @For radio or checkbox. if false, the button will not change selected status on click. Default is true. 如果为true，对于单选和多选按钮，当玩家点击时，按钮会自动切换状态。设置为false，则不会。默认为true。
---@field public linkedPopup FairyGUI.GObject @Show a popup on click.可以为按钮设置一个关联的组件，当按钮被点击时，此组件被自动弹出。
---@field public onChanged FairyGUI.EventListener @Dispatched when the button status was changed. 如果为单选或多选按钮，当按钮的选中状态发生改变时，此事件触发。
---@field public icon string
---@field public title string
---@field public text string
---@field public selectedIcon string
---@field public selectedTitle string
---@field public titleColor Love2DEngine.Color
---@field public color Love2DEngine.Color
---@field public titleFontSize number
---@field public selected number
---@field public mode number
---@field public relatedController number @对应编辑器中的单选控制器。
---@field protected _titleObject FairyGUI.GObject
---@field protected _iconObject FairyGUI.GObject
---@field protected _relatedController FairyGUI.Controller
---@field private _mode FairyGUI.ButtonMode
---@field private _selected boolean
---@field private _title string
---@field private _icon string
---@field private _selectedTitle string
---@field private _selectedIcon string
---@field private _buttonController FairyGUI.Controller
---@field private _downEffect number
---@field private _downEffectValue number
---@field private _downScaled boolean
---@field private _down boolean
---@field private _over boolean
local GButton = Class.inheritsFrom('GButton', nil, GComponent, {IColorGear})

GButton.UP = "up"
GButton.DOWN = "down"
GButton.OVER = "over"
GButton.SELECTED_OVER = "selectedOver"
GButton.DISABLED = "disabled"
GButton.SELECTED_DISABLED = "selectedDisabled"

function GButton:__ctor()
    GComponent.__ctor(self)

    self.pageOption = PageOption.new()

    self.sound = UIConfig.buttonSound
    self.soundVolumeScale = UIConfig.buttonSoundVolumeScale
    self.changeStateOnClick = true
    self._downEffectValue = 0.8
    self._title = ''

    self.onChanged = EventListener.new(self, "onChanged")

    self.__rolloverDelegate = EventCallback0.new(self.__rollover, self)
    self.__rolloutDelegate = EventCallback0.new(self.__rollout, self)
    self.__touchBeginDelegate = EventCallback1.new(self.__touchBegin, self)
    self.__touchEndDelegate = EventCallback0.new(self.__touchEnd, self)
    self.__removedFromStageDelegate = EventCallback0.new(self.__removedFromStage, self)
    self.__clickDelegate = EventCallback0.new(self.__click, self)
end

---Simulates a click on this button
---模拟点击这个按钮。
---@param downEffect boolean @If the down effect will simulate too.
function GButton:FireClick(downEffect)
    if (downEffect and self._mode == ButtonMode.Common) then
        self:SetState(GButton.OVER)
        Timers.inst:Add(0.1, 1, function(param) self:SetState(GButton.DOWN) end)
        Timers.inst:Add(0.2, 1, function(param) self:SetState(GButton.UP) end)
    end
    self:__click()
end

---@return FairyGUI.GTextField
function GButton:GetTextField()
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

---@param val string
function GButton:SetState(val)
    if (self._buttonController ~= nil) then
        self._buttonController.selectedPage = val
    end

    if (self._downEffect == 1) then
        local cnt = self.numChildren
        if (val == GButton.DOWN or val == GButton.SELECTED_OVER or val == GButton.SELECTED_DISABLED) then
            local color = Color(self._downEffectValue, self._downEffectValue, self._downEffectValue)
            for i = 1, cnt do
                local obj = self:GetChildAt(i)
                if (obj:isa(IColorGear) and not obj:isa(GTextField)) then
                    obj.color = color
                end
            end
        else
            for i = 1, cnt do
                local obj = self:GetChildAt(i)
                if (obj:isa(IColorGear) and not obj:isa(GTextField)) then
                    obj.color = Color.white
                end
            end
        end
    elseif (self._downEffect == 2) then
        if (val == GButton.DOWN or val == GButton.SELECTED_OVER or val == GButton.SELECTED_DISABLED) then
            if (not self._downScaled) then
                self._downScaled = true
                self:SetScale(self.scaleX * self._downEffectValue, self.scaleY * self._downEffectValue)
            end
        else
            if (self._downScaled) then
                self._downScaled = false
                self:SetScale(self.scaleX / self._downEffectValue, self.scaleY / self._downEffectValue)
            end
        end
    end
end

function GButton:SetCurrentState()
    if (self.grayed and self._buttonController ~= nil and self._buttonController:HasPage(GButton.DISABLED)) then
        if (self._selected) then
            self:SetState(GButton.SELECTED_DISABLED)
        else
            self:SetState(GButton.DISABLED)
        end
    else
        if (self._selected) then
            self:SetState(self._over and GButton.SELECTED_OVER or GButton.DOWN)
        else
            self:SetState(self._over and GButton.OVER or GButton.UP)
        end
    end
end

function GButton:HandleControllerChanged(c)
    GComponent.HandleControllerChanged(self, c)

    if (self._relatedController == c) then
        self.selected = self.pageOption.id == c.selectedPageId
    end
end

function GButton:HandleGrayedChanged()
    if (self._buttonController ~= nil and self._buttonController:HasPage(GButton.DISABLED)) then
        if (self.grayed) then
            if (self._selected) then
                self:SetState(GButton.SELECTED_DISABLED)
            else
                self:SetState(GButton.DISABLED)
            end
        else
            if (self._selected) then
                self:SetState(GButton.DOWN)
            else
                self:SetState(GButton.UP)
            end
        end
    else
        GComponent.HandleGrayedChanged(self)
    end
end

function GButton:ConstructExtension(buffer)
    buffer:Seek(0, 6)

    self._mode = buffer:ReadByte()
    local str = buffer:ReadS()
    if (str ~= nil) then
        self.sound = UIPackage.GetItemAssetByURL(str)
    end
    self.soundVolumeScale = buffer:ReadFloat()
    self._downEffect = buffer:ReadByte()
    self._downEffectValue = buffer:ReadFloat()
    if (self._downEffect == 2) then
        self:SetPivot(0.5, 0.5, self.pivotAsAnchor)
    end

    self._buttonController = self:GetController("button")
    self._titleObject = self:GetChild("title")
    self._iconObject = self:GetChild("icon")
    if (self._titleObject ~= nil) then
        self._title = self._titleObject.text
    end
    if (self._iconObject ~= nil) then
        self._icon = self._iconObject.icon
    end

    if (self._mode == ButtonMode.Common) then
        self:SetState(GButton.UP)
    end

    self.displayObject.onRollOver:Add(self.__rolloverDelegate)
    self.displayObject.onRollOut:Add(self.__rolloutDelegate)
    self.displayObject.onTouchBegin:Add(self.__touchBeginDelegate)
    self.displayObject.onTouchEnd:Add(self.__touchEndDelegate)
    self.displayObject.onRemovedFromStage:Add(self.__removedFromStageDelegate)
    self.displayObject.onClick:Add(self.__clickDelegate)
end

function GButton:Setup_AfterAdd(buffer, beginPos)
    GComponent.Setup_AfterAdd(self, buffer, beginPos)

    if (not buffer:Seek(beginPos, 6)) then
        return
    end

    if (buffer:ReadByte() ~= self.packageItem.objectType) then
        return
    end

    local str = buffer:ReadS()
    if (str ~= nil) then
        self.title = str
    end
    str = buffer:ReadS()
    if (str ~= nil) then
        self.selectedTitle = str
    end
    str = buffer:ReadS()
    if (str ~= nil) then
        self.icon = str
    end
    str = buffer:ReadS()
    if (str ~= nil) then
        self.selectedIcon = str
    end
    if (buffer:ReadBool()) then
        self.titleColor = buffer:ReadColor()
    end
    local iv = buffer:ReadInt()
    if (iv ~= 0) then
        self.titleFontSize = iv
    end
    iv = buffer:ReadShort()
    if (iv >= 0) then
        self._relatedController = self.parent:GetControllerAt(iv)
    end
    self.pageOption.id = buffer:ReadS()

    str = buffer:ReadS()
    if (str ~= nil) then
        self.sound = UIPackage.GetItemAssetByURL(str)
    end
    if (buffer:ReadBool()) then
        self.soundVolumeScale = buffer:ReadFloat()
    end

    self.selected = buffer:ReadBool()
end

function GButton:__rollover()
    if (self._buttonController == nil or not self._buttonController:HasPage(GButton.OVER)) then
        return
    end

    self._over = true
    if (self._down) then
        return
    end

    if (self.grayed and self._buttonController:HasPage(GButton.DISABLED)) then
        return
    end

    self:SetState(self._selected and GButton.SELECTED_OVER or GButton.OVER)
end

function GButton:__rollout()
    if (self._buttonController == nil or not self._buttonController:HasPage(GButton.OVER)) then
        return
    end

    self._over = false
    if (self._down) then
        return
    end

    if (self.grayed and self._buttonController:HasPage(GButton.DISABLED)) then
        return
    end

    self:SetState(self._selected and GButton.DOWN or GButton.UP)
end

---@param context FairyGUI.EventContext
function GButton:__touchBegin(context)
    if (context.inputEvent.button ~= 0) then
        return
    end

    self._down = true
    context:CaptureTouch()

    if (self._mode == ButtonMode.Common) then
        if (self.grayed and self._buttonController ~= nil and self._buttonController:HasPage(GButton.DISABLED)) then
            self:SetState(GButton.SELECTED_DISABLED)
        else
            self:SetState(GButton.DOWN)
        end
    end

    if (self.linkedPopup ~= nil) then
        if self.linkedPopup:isa(Window) then
            self.linkedPopup:ToggleStatus()
        else
            self.root:TogglePopup(self.linkedPopup, self)
        end
    end
end

function GButton:__touchEnd()
    if (self._down) then
        self._down = false
        if (self._mode == ButtonMode.Common) then
            if (self.grayed and self._buttonController ~= nil and self._buttonController:HasPage(GButton.DISABLED)) then
                self:SetState(GButton.DISABLED)
            elseif (self._over) then
                self:SetState(GButton.OVER)
            else
                self:SetState(GButton.UP)
            end
        else
            if (not self._over
                    and self._buttonController ~= nil
                    and (self._buttonController.selectedPage == GButton.OVER or self._buttonController.selectedPage == GButton.SELECTED_OVER)) then
                self:SetCurrentState()
            end
        end
    end
end

function GButton:__removedFromStage()
    if self._over then
        self:__rollout()
    end
end

function GButton:__click()
    if (self.sound ~= nil and self.sound.nativeClip ~= nil) then
        Stage.inst:PlayOneShotSound(self.sound.nativeClip, self.soundVolumeScale)
    end

    if (self._mode == ButtonMode.Check) then
        if (self.changeStateOnClick) then
            self.selected = not self._selected
            self.onChanged:Call()
        end
    elseif (self._mode == ButtonMode.Radio) then
        if (self.changeStateOnClick and not self._selected) then
            self.selected = true
            self.onChanged:Call()
        end
    else
        if (self._relatedController ~= nil) then
            self._relatedController.selectedPageId = self.pageOption.id
        end
    end
end


local __get = Class.init_get(GButton)
local __set = Class.init_set(GButton)

---@param self FairyGUI.GButton
__get.icon = function(self) return self._icon end

---@param self FairyGUI.GButton
---@param val string
__set.icon = function(self, val)
    self._icon = val
    val = (self._selected and self._selectedIcon ~= nil) and self._selectedIcon or self._icon
    if (self._iconObject ~= nil) then
        self._iconObject.icon = val
    end
    self:UpdateGear(7)
end

---@param self FairyGUI.GButton
__get.title = function(self) return self._title end

---@param self FairyGUI.GButton
---@param val string
__set.title = function(self, val)
    self._title = val
    if (self._titleObject ~= nil) then
        self._titleObject.text = (self._selected and self._selectedTitle ~= nil) and self._selectedTitle or self._title
    end
    self:UpdateGear(6)
end

---@param self FairyGUI.GButton
__get.text = function(self) return self.title end

---@param self FairyGUI.GButton
---@param val string
__set.text = function(self, val) self.title = val end

---@param self FairyGUI.GButton
__get.selectedIcon = function(self) return self._selectedIcon end

---@param self FairyGUI.GButton
---@param val string
__set.selectedIcon = function(self, val)
    self._selectedIcon = val
    val = (self._selected and self._selectedIcon ~= nil) and self._selectedIcon or self._icon
    if (self._iconObject ~= nil) then
        self._iconObject.icon = val
    end
end

---@param self FairyGUI.GButton
__get.selectedTitle = function(self) return self._selectedTitle end

---@param self FairyGUI.GButton
---@param val string
__set.selectedTitle = function(self, val)
    self._selectedTitle = val
    if (self._titleObject ~= nil) then
        self._titleObject.text = (self._selected and self._selectedTitle ~= nil) and self._selectedTitle or self._title
    end
end

---@param self FairyGUI.GButton
__get.titleColor = function(self)
    local tf = self:GetTextField()
    if (tf ~= nil) then
        return tf.color
    else
        return Color.black
    end
end

---@param self FairyGUI.GButton
---@param val Love2DEngine.Color
__set.titleColor = function(self, val)
    local tf = self:GetTextField()
    if (tf ~= nil) then
        tf.color = val
        self:UpdateGear(4)
    end
end

---@param self FairyGUI.GButton
__get.color = function(self) return self.titleColor end

---@param self FairyGUI.GButton
---@param val Love2DEngine.Color
__set.color = function(self, val) self.titleColor = val end

---@param self FairyGUI.GButton
__get.titleFontSize = function(self)
    local tf = self:GetTextField()
    if (tf ~= nil) then
        return tf.textFormat.size
    else
        return 0
    end
end

---@param self FairyGUI.GButton
---@param val number
__set.titleFontSize = function(self, val)
    local tf = self:GetTextField()
    if (tf ~= nil) then
        ---@type FairyGUI.TextFormat
        local format = self._titleObject.textFormat
        format.size = val
        tf.textFormat = format
    end
end

---@param self FairyGUI.GButton
__get.selected = function(self) return self._selected end

---@param self FairyGUI.GButton
---@param val boolean
__set.selected = function(self, val)
    if (self._mode == ButtonMode.Common) then
        return
    end

    if (self._selected ~= val) then
        self._selected = val
        self:SetCurrentState()
        if (self._selectedTitle ~= nil and self._titleObject ~= nil) then
            self._titleObject.text = self._selected and self._selectedTitle or self._title
        end
        if (self._selectedIcon ~= nil) then
            local str = self._selected and self._selectedIcon or self._icon
            if (self._iconObject ~= nil) then
                self._iconObject.icon = str
            end
        end
        if (self._relatedController ~= nil
                and self.parent ~= nil
                and not self.parent._buildingDisplayList) then
            if (self._selected) then
                self._relatedController.selectedPageId = self.pageOption.id
                if (self._relatedController.autoRadioGroupDepth) then
                    self.parent:AdjustRadioGroupDepth(self, self._relatedController)
                end
            elseif (self._mode == ButtonMode.Check and self._relatedController.selectedPageId == self.pageOption.id) then
                self._relatedController.oppositePageId = self.pageOption.id
            end
        end
    end
end

---@param self FairyGUI.GButton
__get.mode = function(self) return self._mode end

---@param self FairyGUI.GButton
---@param val FairyGUI.ButtonMode
__set.mode = function(self, val)
    if (self._mode ~= val) then
        if (val == ButtonMode.Common) then
            self.selected = false
        end
        self._mode = val
    end
end

---@param self FairyGUI.GButton
__get.relatedController = function(self) return self._relatedController end

---@param self FairyGUI.GButton
---@param val FairyGUI.ButtonMode
__set.relatedController = function(self, val)
    if (val ~= self._relatedController) then
        self._relatedController = val
        self.pageOption.controller = val
        self.pageOption:Clear()
    end
end


FairyGUI.GButton = GButton
return GButton