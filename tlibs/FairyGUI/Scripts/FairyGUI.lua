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
require('UI.UIContentScaler')
require('UI.GObject')
require('UI.GComponent')
require('UI.GRoot')

---====================== Core.HitTest ======================
require('Core.CaptureCamera')


---++++++++++++++++++++++ Implementation Section ++++++++++++++++++++++
---=======================Utils======================
require('Utils.Utils')

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
require('Core.Text.TouchScreenKeyboard')

---======================Core======================
require('Core.BlendMode')
require('Core.DisplayOptions')
require('Core.ShaderConfig')
require('Core.Stats')
require('Core.MaterialManager')
require('Core.UpdateContext')
require('Core.NTexture')
require('Core.NGraphics')
require('Core.DisplayObject_Imp')
require('Core.Container_Imp')
require('Core.StageCamera')
require('Core.StageEngine')
require('Core.Stage')
require('Core.Image')

require('Core.Shape_Imp')

---======================UI======================
require('UI.FieldTypes')
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
require('UI.GGroup')
require('UI.Window')
require('UI.GGraph')
require('UI.GList')
require('UI.GLabel')
require('UI.GImage')

require('UI.GObject_Imp')
require('UI.GComponent_Imp')
require('UI.GRoot_Imp')
require('UI.UIContentScaler_Imp')
require('UI.UIObjectFactory_Imp')

---======================Core.HitTest======================
require('Core.BlendMode')
require('Core.DisplayOptions')
require('Core.Stats')
require('Core.UpdateContext')
require('Core.StageEngine')
require('Core.StageCamera')
require('Core.CaptureCamera_Imp')
require('Core.ShaderConfig')
require('Core.NMaterial')

---======================Tween======================
require('Tween.TweenValue')


return FairyGUI