--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/17 15:38
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

local LuaBehavior = Love2DEngine.LuaBehaviour
local Color = Love2DEngine.Color
local Color32 = Love2DEngine.Color32

local ScrollBarDisplayType = FairyGUI.ScrollBarDisplayType
local UIPackage = FairyGUI.UIPackage

---@class FairyGUI.UIConfig.SoundLoader:Delegate @fun(url):FairyGUI.NAudioClip
local SoundLoader = Delegate.newDelegate('SoundLoader')

---@class FairyGUI.UIConfig:Love2DEngine.LuaBehaviour
local UIConfig = Class.inheritsFrom('UIConfig', nil, LuaBehavior)

--- Dynamic Font Support.
--- 4.x: Put the xxx.ttf into /Resources or /Resources/Fonts, and set defaultFont="xxx".
--- 5.x: set defaultFont to system font name(or names joint with comma). e.g. defaultFont="Microsoft YaHei, SimHei"
---@type string
UIConfig.defaultFont = ""

--- When using chinese fonts on desktop, I found that the display effect is not very clear. So I wrote shaders to light up their outline.
--- If you dont use chinese fonts, or dont like the new effect, just set to false here.
--- The switch is meaningless on mobile platforms.
---@type boolean
UIConfig.renderingTextBrighterOnDesktop = true

--- Resource using in Window.ShowModalWait for locking the window.
---@type string
UIConfig.windowModalWaiting = nil

--- Resource using in GRoot.ShowModalWait for locking the screen.
---@type string
UIConfig.globalModalWaiting = nil

--- When a modal window is in front, the background becomes dark.
---@type Love2DEngine.Color
UIConfig.modalLayerColor = Color(0, 0, 0, 0.4)

--- Default button click sound.
---@type FairyGUI.NAudioClip
UIConfig.buttonSound = nil

--- Default button click sound volume.
---@type number
UIConfig.buttonSoundVolumeScale = 1

--- Resource url of horizontal scrollbar
---@type string
UIConfig.horizontalScrollBar = nil

--- Resource url of vertical scrollbar
---@type string
UIConfig.verticalScrollBar = nil

--- Scrolling step in pixels
--- 当调用ScrollPane.scrollUp/Down/Left/Right时，或者点击滚动条的上下箭头时，滑动的距离。
--- 鼠标滚轮触发一次滚动的距离设定为defaultScrollStep*2
---@type number
UIConfig.defaultScrollStep = 25
---[Obsolete("UIConfig.defaultScrollSpeed is deprecated. Use defaultScrollStep instead.")]
---@type number
UIConfig.defaultScrollSpeed = 25

--- Deceleration ratio of scrollpane when its in touch dragging.
--- 当手指拖动并释放滚动区域后，内容会滑动一定距离后停下，这个速率就是减速的速率。
--- 越接近1，减速越慢，意味着滑动的时间和距离更长。
--- 这个是全局设置，也可以通过ScrollPane.decelerationRate进行个性设置。
---@type number
UIConfig.defaultScrollDecelerationRate = 0.967
---[Obsolete("UIConfig.defaultTouchScrollSpeedRatio is deprecated. Use defaultScrollDecelerationRate instead.")]
---@type number
UIConfig.defaultTouchScrollSpeedRatio = 1

--- Scrollbar display mode. Recommended 'Auto' for mobile and 'Visible' for web.
---@type FairyGUI.ScrollBarDisplayType
UIConfig.defaultScrollBarDisplay = ScrollBarDisplayType.Default

--- Allow dragging anywhere in container to scroll.
---@type boolean
UIConfig.defaultScrollTouchEffect = true

--- The "rebound" effect in the scolling container.
--- </summary>
---@type boolean
UIConfig.defaultScrollBounceEffect = true

--- Resources url of PopupMenu.
---@type string
UIConfig.popupMenu = nil

--- Resource url of menu seperator.
---@type string
UIConfig.popupMenu_seperator = nil

--- In case of failure of loading content for GLoader, use this sign to indicate an error.
---@type string
UIConfig.loaderErrorSign = nil

--- Resource url of tooltips.
---@type string
UIConfig.tooltipsWin = nil

--- The number of visible items in ComboBox.
---@type number
UIConfig.defaultComboBoxVisibleItemCount = 10

--- Pixel offsets of finger to trigger scrolling
---@type number
UIConfig.touchScrollSensitivity = 20

--- Pixel offsets of finger to trigger dragging
---@type number
UIConfig.touchDragSensitivity = 10

--- Pixel offsets of mouse pointer to trigger dragging.
---@type number
UIConfig.clickDragSensitivity = 2

--- Allow softness on top or left side for scrollpane.
---@type boolean
UIConfig.allowSoftnessOnTopOrLeftSide = true

--- When click the window, brings to front automatically.
---@type boolean
UIConfig.bringWindowToFrontOnClick = true

---
---@type number
UIConfig.inputCaretSize = 1

---
---@type Love2DEngine.Color
UIConfig.inputHighlightColor = Color32(255, 223, 141, 128)

---
---@type number
UIConfig.frameTimeForAsyncUIConstruction = 0.002

--- if RenderTexture using in paiting mode has depth support.
---@type boolean
UIConfig.depthSupportForPaintingMode = false

---@class FairyGUI.UIConfig.ConfigKey:enum
local ConfigKey =  {
    DefaultFont = 0,
    ButtonSound = 1,
    ButtonSoundVolumeScale = 2,
    HorizontalScrollBar = 3,
    VerticalScrollBar = 4,
    DefaultScrollStep = 5,
    DefaultScrollBarDisplay = 6,
    DefaultScrollTouchEffect = 7,
    DefaultScrollBounceEffect = 8,
    TouchScrollSensitivity = 9,
    WindowModalWaiting = 10,
    GlobalModalWaiting = 11,
    PopupMenu = 12,
    PopupMenu_seperator = 13,
    LoaderErrorSign = 14,
    TooltipsWin = 15,
    DefaultComboBoxVisibleItemCount = 16,
    TouchDragSensitivity = 17,
    ClickDragSensitivity = 18,
    ModalLayerColor = 19,
    RenderingTextBrighterOnDesktop = 20,
    AllowSoftnessOnTopOrLeftSide = 21,
    InputCaretSize = 22,
    InputHighlightColor = 23,
    RightToLeftText = 24,

    PleaseSelect = 100,
}

---@class FairyGUI.UIConfig.ConfigValue:ClassType
---@field public valid boolean
---@field public s string
---@field public i number
---@field public f number
---@field public b boolean
---@field public c Love2DEngine.Color
local ConfigValue = Class.inheritsFrom('ConfigValue')

function ConfigValue:Reset()
    self.valid = false
    self.s = nil
    self.i = 0
    self.f = 0
    self.b = false
    self.c = Color.black
end

---@type FairyGUI.UIConfig.ConfigValue[]
UIConfig.Items = {}
---@type string[]
UIConfig.PreloadPackages = {}

function UIConfig:Awake()
    for _, packagePath in ipairs(UIConfig.PreloadPackages) do
        UIPackage.AddPackage(packagePath)
    end
end

function UIConfig:Load()
    for i, value in ipairs(UIConfig.Items) do
        if (not value.valid) then
            --continue
        else
            local cfgKey = i + 1
            if cfgKey== ConfigKey.ButtonSound then
                UIConfig.buttonSound = UIPackage.GetItemAssetByURL(value.s)
            elseif cfgKey== ConfigKey.ButtonSoundVolumeScale then
                UIConfig.buttonSoundVolumeScale = value.f
            elseif cfgKey== ConfigKey.ClickDragSensitivity then
                UIConfig.clickDragSensitivity = value.i
            elseif cfgKey== ConfigKey.DefaultComboBoxVisibleItemCount then
                UIConfig.defaultComboBoxVisibleItemCount = value.i
            elseif cfgKey== ConfigKey.DefaultFont then
                UIConfig.defaultFont = value.s
            elseif cfgKey== ConfigKey.DefaultScrollBarDisplay then
                UIConfig.defaultScrollBarDisplay = value.i
            elseif cfgKey== ConfigKey.DefaultScrollBounceEffect then
                UIConfig.defaultScrollBounceEffect = value.b
            elseif cfgKey== ConfigKey.DefaultScrollStep then
                UIConfig.defaultScrollStep = value.i
            elseif cfgKey== ConfigKey.DefaultScrollTouchEffect then
                UIConfig.defaultScrollTouchEffect = value.b
            elseif cfgKey== ConfigKey.GlobalModalWaiting then
                UIConfig.globalModalWaiting = value.s
            elseif cfgKey== ConfigKey.HorizontalScrollBar then
                UIConfig.horizontalScrollBar = value.s
            elseif cfgKey== ConfigKey.LoaderErrorSign then
                UIConfig.loaderErrorSign = value.s
            elseif cfgKey== ConfigKey.ModalLayerColor then
                UIConfig.modalLayerColor = value.c
            elseif cfgKey== ConfigKey.PopupMenu then
                UIConfig.popupMenu = value.s
            elseif cfgKey== ConfigKey.PopupMenu_seperator then
                UIConfig.popupMenu_seperator = value.s
            elseif cfgKey== ConfigKey.RenderingTextBrighterOnDesktop then
                UIConfig.renderingTextBrighterOnDesktop = value.b
            elseif cfgKey== ConfigKey.TooltipsWin then
                UIConfig.tooltipsWin = value.s
            elseif cfgKey== ConfigKey.TouchDragSensitivity then
                UIConfig.touchDragSensitivity = value.i
            elseif cfgKey== ConfigKey.TouchScrollSensitivity then
                UIConfig.touchScrollSensitivity = value.i
            elseif cfgKey== ConfigKey.VerticalScrollBar then
                UIConfig.verticalScrollBar = value.s
            elseif cfgKey== ConfigKey.WindowModalWaiting then
                UIConfig.windowModalWaiting = value.s
            elseif cfgKey== ConfigKey.AllowSoftnessOnTopOrLeftSide then
                UIConfig.allowSoftnessOnTopOrLeftSide = value.b
            elseif cfgKey== ConfigKey.InputCaretSize then
                UIConfig.inputCaretSize = value.i
            elseif cfgKey== ConfigKey.InputHighlightColor then
                UIConfig.inputHighlightColor = value.c
            end
        end
    end
end

function UIConfig.ClearResourceRefs()
    UIConfig.defaultFont = ""
    UIConfig.buttonSound = nil
    UIConfig.globalModalWaiting = nil
    UIConfig.horizontalScrollBar = nil
    UIConfig.loaderErrorSign = nil
    UIConfig.popupMenu = nil
    UIConfig.popupMenu_seperator = nil
    UIConfig.tooltipsWin = nil
    UIConfig.verticalScrollBar = nil
    UIConfig.windowModalWaiting = nil
end

function UIConfig.ApplyModifiedProperties() end

---@type FairyGUI.UIConfig.SoundLoader
UIConfig.soundLoader = nil

FairyGUI.UIConfig = UIConfig
return UIConfig