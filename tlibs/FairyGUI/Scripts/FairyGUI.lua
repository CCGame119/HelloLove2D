--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 11:32
--

---@class FairyGUI:namespace
FairyGUI = {name='FairyGUI'}

---@class FairyGUI.EventModifiers
FairyGUI.EventModifiers = {
    None = 0,
    Shift = 1,
    Control = 2,
    Alt = 4,
    Command = 8,
    Numeric = 16, -- 0x00000010
    CapsLock = 32, -- 0x00000020
    FunctionKey = 64, -- 0x00000040
}

---++++++++++++++++++++++ Declaration Section ++++++++++++++++++++++
---====================== Event ======================
require('Event.EventDispatcher')

---======================Core======================
require('Core.DisplayObject')
require('Core.Container')
require('Core.Shape')

---====================== UI ======================
require('UI.FieldTypes')
require('UI.UIContentScaler')
require('UI.GObject')
require('UI.GComponent')
require('UI.GRoot')
require('UI.UIPackage')

---====================== Core.HitTest ======================
require('Core.CaptureCamera')


---++++++++++++++++++++++ Implementation Section ++++++++++++++++++++++
---=======================Utils======================
require('Utils.Utils')
require('Utils.ToolSet')
require('Utils.Timers')

---======================Event======================
require('Event.IEventDispatcher')
require('Event.EventContext')
require('Event.EventListener')
require('Event.EventBridge')
require('Event.InputEvent')

require('Event.EventDispatcher_Imp')

---======================Core.HitTest======================
require('Core.HitTest.IHitTest')
require('Core.HitTest.HitTestContext')
require('Core.HitTest.PixelHitTest')
require('Core.HitTest.RectHitTest')
require('Core.HitTest.ColliderHitTest')
require('Core.HitTest.BoxColliderHitTest')
require('Core.HitTest.MeshColliderHitTest')

---======================Core.Text======================
require('Core.Text.IKeyboard')
require('Core.Text.TouchScreenKeyboard')
require('Core.Text.BaseFont')
require('Core.Text.DynamicFont')
require('Core.Text.FontManager')
require('Core.Text.TextFormat')
require('Core.Text.TextField')
require('Core.Text.RichTextField')
require('Core.Text.InputTextField')

---======================Core======================
require('Core.BlendMode')
require('Core.DisplayOptions')
require('Core.ShaderConfig')
require('Core.NMaterial')
require('Core.Stats')
require('Core.UpdateContext')
require('Core.MaterialManager')
require('Core.NTexture')
require('Core.NGraphics')
require('Core.FillUtils')
require('Core.StageCamera')
require('Core.StageEngine')
require('Core.Stage')
require('Core.Image')
require('Core.MovieClip')

require('Core.Shape_Imp')
require('Core.CaptureCamera_Imp')
require('Core.DisplayObject_Imp')
require('Core.Container_Imp')

---======================UI Gears======================
require('UI.Gears.IColorGear')
require('UI.Gears.IAnimationGear')
require('UI.Gears.GearAnimation')
require('UI.Gears.GearBase')
require('UI.Gears.GearDisplay')
require('UI.Gears.GearXY')
require('UI.Gears.GearSize')
require('UI.Gears.GearText')
require('UI.Gears.GearLook')
require('UI.Gears.GearIcon')
require('UI.Gears.GearColor')

---======================UI======================
require('UI.GObjectPool')
require('UI.PageOption')
require('UI.EMRenderSupport')
require('UI.AsyncCreationHelper')
require('UI.TranslationHelper')
require('UI.UIObjectFactory')
require("UI.PackageItem")
require("UI.RelationItem")
require('UI.UIPackage')
require('UI.UIConfig')
require('UI.Margin')
require('UI.Relations')
require('UI.Controller')
require('UI.GGroup')
require('UI.GGraph')
require('UI.GLabel')
require('UI.GImage')
require('UI.GButton')
require('UI.GTextField')
require('UI.GTextInput')
require('UI.GComboBox')
require('UI.GLoader')
require('UI.GList')
require('UI.ScrollPane')
require('UI.Window')

require('UI.UIPackage_Imp')
require('UI.GObject_Imp')
require('UI.GComponent_Imp')
require('UI.GRoot_Imp')
require('UI.UIContentScaler_Imp')
require('UI.UIObjectFactory_Imp')

---======================Tween======================
require('Tween.TweenValue')


return FairyGUI