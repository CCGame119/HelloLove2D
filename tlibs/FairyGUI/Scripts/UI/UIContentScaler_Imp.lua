--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2019/1/24 18:13
--

local LuaBehaviour = Love2DEngine.LuaBehaviour
local Screen = Love2DEngine.Screen

local StageCamera = FairyGUI.StageCamera
local Stage = FairyGUI.Stage
local GRoot = FairyGUI.GRoot

---@class FairyGUI.UIContentScaler:Love2DEngine.LuaBehaviour
---@field public scaleMode FairyGUI.UIContentScaler.ScaleMode @
---@field public screenMatchMode FairyGUI.UIContentScaler.ScreenMatchMode @
---@field public designResolutionX number @
---@field public designResolutionY number @
---@field public fallbackScreenDPI number @
---@field public defaultSpriteDPI number @
---@field public constantScaleFactor number @
---@field public ignoreOrientation boolean @当false时，计算比例时会考虑designResolutionX/Y的设置是针对横屏还是竖屏。否则不考虑。
---@field private _changed boolean
local UIContentScaler = FairyGUI.UIContentScaler

--region UIContentScaler 类成员
UIContentScaler.scaleFactor = 1
--endregion

function UIContentScaler:OnEnable()
    --播放模式下都是通过Stage自带的UIContentScaler实现调整的，所以这里只是把参数传过去
    local scaler = Stage.inst.gameObject:GetComponent(UIContentScaler)
    if (scaler ~= self) then
        scaler.scaleMode = self.scaleMode
        if (self.scaleMode == ScaleMode.ScaleWithScreenSize) then
            scaler.designResolutionX = self.designResolutionX
            scaler.designResolutionY = self.designResolutionY
            scaler.screenMatchMode = self.screenMatchMode
            scaler.ignoreOrientation = self.ignoreOrientation
        elseif (self.scaleMode == ScaleMode.ConstantPhysicalSize) then
            scaler.fallbackScreenDPI = self.fallbackScreenDPI
            scaler.defaultSpriteDPI = self.defaultSpriteDPI
        else
            scaler.constantScaleFactor = self.constantScaleFactor
        end
        scaler:ApplyChange()
        GRoot.inst:ApplyContentScaleFactor()
    end
end

function UIContentScaler:Update()
    if (self._changed) then
        self._changed = false
        self:ApplyChange()
    end
end

function UIContentScaler:OnDestroy()
    self.scaleFactor = 1
end

function UIContentScaler:ApplyModifiedProperties()
    self._changed = true
end

function UIContentScaler:ApplyChange()
    if (self.scaleMode == ScaleMode.ScaleWithScreenSize) then
        if (self.designResolutionX == 0 or self.designResolutionY == 0) then
            return
        end

        local dx = self.designResolutionX
        local dy = self.designResolutionY
        if (not self.ignoreOrientation and (Screen.width > Screen.height and dx < dy or Screen.width < Screen.height and dx > dy)) then
            -- scale should not change when orientation change
            local tmp = dx
            dx = dy
            dy = tmp
        end

        if (self.screenMatchMode == ScreenMatchMode.MatchWidthOrHeight) then
            local s1 = Screen.width / dx
            local s2 = Screen.height / dy
            UIContentScaler.scaleFactor = math.min(s1, s2)
        elseif (self.screenMatchMode == ScreenMatchMode.MatchWidth) then
            UIContentScaler.scaleFactor = Screen.width / dx
        else
            UIContentScaler.scaleFactor = Screen.height / dy
        end
    elseif (self.scaleMode == ScaleMode.ConstantPhysicalSize) then
        local dpi = Screen.dpi
        if (dpi == 0) then
            dpi = self.fallbackScreenDPI
        end
        if (dpi == 0) then
            dpi = 96
        end
        UIContentScaler.scaleFactor = dpi / (self.defaultSpriteDPI == 0 and 96 or self.defaultSpriteDPI)
    else
        UIContentScaler.scaleFactor = self.constantScaleFactor
    end

    if (UIContentScaler.scaleFactor > 10) then
        UIContentScaler.scaleFactor = 10
    end
    StageCamera.screenSizeVer = StageCamera.screenSizeVer + 1
end