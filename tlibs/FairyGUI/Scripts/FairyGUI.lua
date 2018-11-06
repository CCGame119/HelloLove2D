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


---=======================Utils======================
require('Utils.Utils')

---======================Event======================
require('Event.IEventDispatcher')
require('Event.EventContext')
require('Event.EventListener')
require('Event.EventBridge')
require('Event.InputEvent')
require('Event.EventDispatcher')

---======================Core.HitTest======================
require('Core.HitTest.IHitTest')
require('Core.HitTest.HitTestContext')
require('Core.HitTest.PixelHitTest')
require('Core.HitTest.RectHitTest')
require('Core.HitTest.ColliderHitTest')
require('Core.HitTest.BoxColliderHitTest')
require('Core.HitTest.MeshColliderHitTest')

---======================UI======================
require('UI.EMRenderSupport')

---======================Core.HitTest======================
require('Core.BlendMode')
require('Core.DisplayOptions')
require('Core.Stats')
require('Core.UpdateContext')
require('Core.StageEngine')
require('Core.StageCamera')
require('Core.CaptureCamera')
require('Core.ShaderConfig')
require('Core.NMaterial')

---======================Tween======================
require('Tween.TweenValue')


return FairyGUI