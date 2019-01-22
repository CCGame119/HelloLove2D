--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/30 19:43
--

local Class = require('libs.Class')
local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

local Application = Love2DEngine.Application
local SceneManager = Love2DEngine.SceneManager
local RuntimePlatform = Love2DEngine.RuntimePlatform
local Time = Love2DEngine.Time
local LayerMask = Love2DEngine.LayerMask
local GameObject = Love2DEngine.GameObject
local Object = Love2DEngine.Object
local Vector3 = Love2DEngine.Vector3
local Screen = Love2DEngine.Screen
local AudioSource = Love2DEngine.AudioSource
local RaycastHit = Love2DEngine.RaycastHit
local Input = Love2DEngine.Input
local TouchPhase = Love2DEngine.TouchPhase
local KeyCode = Love2DEngine.KeyCode
local EventType = Love2DEngine.EventType

local InputEvent = FairyGUI.InputEvent
local Container = FairyGUI.Container
local EventListener = FairyGUI.EventListener
local StageCamera = FairyGUI.StageCamera
local GRoot = FairyGUI.GRoot
local StageEngine = FairyGUI.StageEngine
local UIContentScaler = FairyGUI.UIContentScaler
local Timers = FairyGUI.Timers
local TimerCallback = FairyGUI.TimerCallback
local EventCallback1 = FairyGUI.EventCallback1
local HitTestContext = FairyGUI.HitTestContext
local DynamicFont = FairyGUI.DynamicFont
local ToolSet = FairyGUI.ToolSet
local UpdateContext = FairyGUI.UpdateContext

--region FairyGUI.TouchInfo 声明
---@class FairyGUI.TouchInfo:ClassType
---@field public x number 
---@field public y number 
---@field public touchId number 
---@field public clickCount number 
---@field public keyCode char
---@field public character char 
---@field public modifiers FairyGUI.EventModifiers
---@field public mouseWheelDelta number 
---@field public button number 
---@field public downX number 
---@field public downY number 
---@field public began boolean 
---@field public clickCancelled boolean 
---@field public lastClickTime number 
---@field public target FairyGUI.DisplayObject
---@field public downTargets FairyGUI.DisplayObject[]
---@field public lastRollOver FairyGUI.DisplayObject
---@field public touchMonitors FairyGUI.EventDispatcher
---@field public evt FairyGUI.InputEvent
local TouchInfo = Class.inheritsFrom('TouchInfo')
--endregion

--region FairyGUI.Stage 声明
---@class FairyGUI.Stage:FairyGUI.Container
---@field public inst FairyGUI.Stage @static
---@field public stageHeight number
---@field public stageWidth number
---@field public soundVolume number
---@field public onStageResized FairyGUI.EventListener
---@field public cachedTransform Love2DEngine.Transform
---@field public touchScreen boolean
---@field public keyboardInput boolean
---@field public isTouchOnUI boolean
---@field public touchTarget FairyGUI.DisplayObject
---@field public focused FairyGUI.DisplayObject
---@field public touchPosition Love2DEngine.Vector2
---@field public touchCount number
---@field public keyboard FairyGUI.IKeyboard
---@field private _touchTarget FairyGUI.DisplayObject
---@field private _focused FairyGUI.DisplayObject
---@field private _lastInput FairyGUI.InputTextField
---@field private _updateContext FairyGUI.UpdateContext
---@field private _rollOutChain FairyGUI.DisplayObject[]
---@field private _rollOverChain FairyGUI.DisplayObject[]
---@field private _touches FairyGUI.TouchInfo[]
---@field private _touchCount number
---@field private _touchPosition Love2DEngine.Vector2
---@field private _frameGotHitTarget number
---@field private _frameGotTouchPosition number
---@field private _customInput boolean
---@field private _customInputPos Love2DEngine.Vector2
---@field private _customInputButtonDown boolean
---@field private _focusRemovedDelegate FairyGUI.EventCallback1
---@field private _audio Love2DEngine.AudioSource
---@field private _toCollectTextures FairyGUI.NTexture[]
---@field private _keyboardInput boolean
local Stage = Class.inheritsFrom('Stage', nil, Container)
--endregion

--region FairyGUI.Stage 实现

Stage._touchScreen = false
---@type FairyGUI.IKeyboard
Stage._keyboard = nil
---@type FairyGUI.Stage
Stage._inst = nil

function Stage.Instantiate()
    if (Stage._inst == nil) then
        Stage._inst = Stage.new()
        GRoot._inst = GRoot.new()
        GRoot._inst:ApplyContentScaleFactor()
        Stage._inst:AddChild(GRoot._inst.displayObject)

        StageCamera.CheckMainCamera()
    end
end

function Stage:__ctor()
    Container.__ctor(self)
    self._inst = self
    self.soundVolume = 1

    self._updateContext = UpdateContext.new()
    self.stageWidth = Screen.width
    self.stageHeight = Screen.height
    self._frameGotHitTarget = -1

    self._touches = {}
    for i = 1, 5 do
        table.insert(self._touches, TouchInfo.new())
    end

    if Application.platform == RuntimePlatform.WindowsPlayer then
        self.touchScreen = false
    else
        self.touchScreen = true
    end
    self._rollOutChain = {}
    self._rollOverChain = {}

    self.onStageResized = EventListener.new(self, "onStageResized")

    local engine = GameObject.FindObjectOfType(StageEngine)
    if (engine ~= nil) then
        Object.Destroy(engine.gameObject)
    end

    self.gameObject.name = "Stage"
    self.gameObject.layer = LayerMask.NameToLayer(StageCamera.LayerName)
    self.gameObject:AddComponent(StageEngine)
    self.gameObject:AddComponent(UIContentScaler)
    self.gameObject:SetActive(true)
    Object.DontDestroyOnLoad(self.gameObject);

    self.cachedTransform.localScale = Vector3(StageCamera.UnitsPerPixel, StageCamera.UnitsPerPixel, StageCamera.UnitsPerPixel)

    self:EnableSound()

    self.RunTextureCollectorDelegate = TimerCallback.new(self.RunTextureCollector, self)
    Timers.inst:Add(5, 0, self.RunTextureCollectorDelegate);

    SceneManager.sceneLoaded:Add(self.SceneManager_sceneLoaded, self)

    self._focusRemovedDelegate = EventCallback1.new(self.OnFocusRemoved, self)
end

---@param scene Love2DEngine.Scene
---@param mode Love2DEngine.LoadSceneMode
function Stage:SceneManager_sceneLoaded(scene, mode)
    StageCamera.CheckMainCamera()
end

function Stage:Dispose()
    Container.Dispose(self)
    Timers.inst:Remove(FairyGUI.RunTextureCollector)
    SceneManager.sceneLoaded:Clear()
end

---@param context FairyGUI.EventContext
function Stage:OnFocusRemoved(context)
    if (context.sender == self._focused) then
        if self._focused:isa(FairyGUI.InputTextField) then
            self._lastInput = nil
        end
        self.focus = nil
    end
end

---@param touchId number
---@return Love2DEngine.Vector2
function Stage:GetTouchPosition(touchId)
    self.UpdateTouchPosition()

    if (touchId < 0) then
        return self._touchPosition
    end

    for j = 1, 5 do
        local touch = self._touches[j]
        if (touch.touchId == touchId) then
            return Vector2(touch.x, touch.y)
        end
    end

    return self._touchPosition
end

---@param result number[]
---@return number[]
function Stage:GetAllTouch(result)
    if (result == nil) then
        result = {}
    end
    local i = 1
    for j = 1, 5 do
        local touch = self._touches[j]
        if (touch.touchId ~= -1) then
            result[i] = touch.touchId; i = i + 1
            if (i >= result.Length) then
                break
            end
        end
    end
    return result
end

function Stage:ResetInputState()
    for j = 1, 5 do
        self._touches[j]:Reset()
    end

    if (not self.touchScreen) then
        self._touches[0].touchId = 0
    end

    self._touchCount = 0
end

---@param touchId number
function Stage:CancelClick(touchId)
    for j = 1, 5 do
        local touch = self._touches[j]
        if touch.touchId == touchId then
            touch.clickCancelled = true
        end
    end
end

function Stage:EnableSound()
    if (self._audio == nil) then
        self._audio = self.gameObject:AddComponent(AudioSource)
        self._audio.bypassEffects = true
    end
end

function Stage:DisableSound()
    if (self._audio == nil) then
        Object.Destroy(self._audio)
        self._audio = nil
    end
end

---@param clip Love2DEngine.AudioClip
---@param vol number
function Stage:PlayOneShotSound(clip, vol)
    vol = vol or 1
    if (self._audio ~= nil and self.soundVolume > 0) then
        self._audio:PlayOneShot(clip, self.volumeScale * self.soundVolume)
    end
end

---@param text string
---@param autocorrection boolean
---@param multiline boolean
---@param secure boolean
---@param alert boolean
---@param textPlaceholder string
---@param keyboardType number
---@param hideInput boolean
function Stage:OpenKeyboard(text, autocorrection, multiline, secure,
                            alert, textPlaceholder, keyboardType, hideInput)
    if (self._keyboard ~= nil) then
        self._keyboard:Open(text, autocorrection, multiline, secure, alert, textPlaceholder, keyboardType, hideInput)
    end
end

function Stage:CloseKeyboard()
    if self._keyboard ~= nil then
        self._keyboard:Close()
    end
end

---@param val string
function Stage:InputString(val)
    if self._lastInput ~= nil then
        self._lastInput:ReplaceSelection(val)
    end
end

---@overload fun(screenPos:Love2DEngine.Vector2, buttonDown:boolean)
---@overload fun(screenPos:Love2DEngine.Vector2, buttonDown:boolean, buttonUp:boolean)
---@overload fun(hit:Love2DEngine.RaycastHit, buttonDown:boolean)
---@param screenPos Love2DEngine.RaycastHit
---@param buttonDown boolean
---@param buttonUp boolean @default nil
function Stage:SetCustomInput(hit, buttonDown, buttonUp)
    if Class.isa(hit, RaycastHit) then
        local screenPos = HitTestContext.cachedMainCamera:WorldToScreenPoint(hit.point)
        HitTestContext.CacheRaycastHit(HitTestContext.cachedMainCamera, hit)
        self:SetCustomInput(screenPos, buttonDown, buttonUp)
        return
    end
    local screenPos = hit
    self._customInput = true
    if nil == buttonUp then
        self._customInputButtonDown = buttonDown
    elseif buttonDown then
        self._customInputButtonDown = true
    elseif buttonUp then
        self._customInputButtonDown = false
    end
    self._customInputPos = screenPos
    self._frameGotHitTarget = 0
end

function Stage:InternalUpdate()
    self:HandleEvents()

    self._updateContext:Begin()
    self:Update(self._updateContext)
    self._updateContext:End()

    if (DynamicFont.textRebuildFlag) then
        --字体贴图更改了，重新渲染一遍，防止本帧文字显示错误
        self._updateContext:Begin()
        self:Update(self._updateContext)
        self._updateContext:End()

        DynamicFont.textRebuildFlag = false
    end
end

function Stage:GetHitTarget()
    if (self._frameGotHitTarget == Time.frameCount) then
        return
    end

    self._frameGotHitTarget = Time.frameCount

    if (self._customInput) then
        local pos = self._customInputPos
        pos.y = stageHeight - pos.y

        local touch = self._touches[1]
        self._touchTarget = self:HitTest(pos, true)
        touch.target = self._touchTarget
    elseif (self.touchScreen) then
        self._touchTarget = nil
        for i = 1, Input.touchCount do
            local uTouch = Input.GetTouch(i)

            local pos = uTouch.position
            pos.y = self.stageHeight - pos.y

            local touch = nil
            local free = nil
            for j = 1, 5 do
                if (self._touches[j].touchId == uTouch.fingerId) then
                    touch = self._touches[j]
                    break
                end

                if (self._touches[j].touchId == -1) then
                    free = self._touches[j]
                end
            end
            if (touch == nil) then
                touch = free
                if (touch == nil or uTouch.phase ~= TouchPhase.Began) then
                    --continue
                else
                    touch.touchId = uTouch.fingerId
                end
            end

            if (uTouch.phase == TouchPhase.Stationary) then
                self._touchTarget = touch.target
            else
                self._touchTarget = self:HitTest(pos, true)
                touch.target = self._touchTarget
            end
        end
    else
        local pos = Input.mousePosition
        pos.y = self.stageHeight - pos.y

        local touch = self._touches[1]
        if (pos.x < 0 or pos.y < 0) then --outside of the window
            self._touchTarget = self
        else
            self._touchTarget = self:HitTest(pos, true)
        end
        touch.target = self._touchTarget
    end

    HitTestContext.ClearRaycastHitCache()
end

function Stage:HandleScreenSizeChanged()
    self.stageWidth = Screen.width
    self.stageHeight = Screen.height

    self.cachedTransform.localScale = Vector3(StageCamera.UnitsPerPixel, StageCamera.UnitsPerPixel, StageCamera.UnitsPerPixel)

    local scaler = self.gameObject:GetComponent(UIContentScaler)
    scaler:ApplyChange()
    GRoot.inst:ApplyContentScaleFactor()

    self.onStageResized.Call()
end

---@param evt Love2DEngine.Event
function Stage:HandleGUIEvents(evt)
    if (evt.rawType == EventType.KeyDown) then
        local touch = self._touches[1]
        touch.keyCode = evt.keyCode
        touch.modifiers = evt.modifiers
        touch.character = evt.character
        InputEvent.shiftDown = band(evt.modifiers, EventModifiers.Shift) ~= 0

        touch:UpdateEvent()
        local f = this.focus
        if (f ~= nil) then
            f.onKeyDown:BubbleCall(touch.evt)
        else
            self.onKeyDown:Call(touch.evt)
        end
    elseif (evt.rawType == EventType.KeyUp) then
        local touch = self._touches[1]
        touch.modifiers = evt.modifiers
    elseif (evt.type == EventType.ScrollWheel) then
        if (self._touchTarget ~= nil) then
            local touch = self._touches[1]
            touch.mouseWheelDelta = evt.delta.y
            touch:UpdateEvent()
            self._touchTarget.onMouseWheel:BubbleCall(touch.evt)
            touch.mouseWheelDelta = 0
        end
    end
end

function Stage:HandleEvents()
    self:GetHitTarget()

    if (Input.GetKeyUp(KeyCode.LeftShift) or Input.GetKeyUp(KeyCode.RightShift)) then
        InputEvent.shiftDown = false
    elseif (Input.GetKeyDown(KeyCode.LeftShift) or Input.GetKeyDown(KeyCode.RightShift)) then
        InputEvent.shiftDown = true
    end

    self:UpdateTouchPosition()

    if (self._customInput) then
        self:HandleCustomInput()
        self._customInput = false
    elseif (self.touchScreen) then
        self:HandleTouchEvents()
    else
        self:HandleMouseEvents()
    end

    if self._focused:isa(FairyGUI.InputTextField) then
        self:HandleTextInput()
    end
end

function Stage:UpdateTouchPosition()
    if (self._frameGotTouchPosition ~= Time.frameCount) then
        self._frameGotTouchPosition = Time.frameCount
        if (self._customInput) then
            self._touchPosition = self._customInputPos
            self._touchPosition.y = self.stageHeight - self._touchPosition.y
        elseif self.touchScreen then
            for i = 1, Input.touchCount do
                local uTouch = Input:GetTouch(i)
                self._touchPosition = uTouch.position
                self._touchPosition.y = self.stageHeight - self._touchPosition.y
            end
        else
            local pos = Input.mousePosition
            if (pos.x >= 0 and pos.y >= 0) then --编辑器环境下坐标有时是负
                pos.y = self.stageHeight - pos.y
                self._touchPosition = pos
            end
        end
    end
end

function Stage:HandleTextInput()
    local textField = self._focused
    if not textField.editable then
        return
    end

    if self.keyboardInput then
        if (textField.keyboardInput and self._keyboard ~= nil) then
            local s = self._keyboard:GetInput()
            if (s ~= nil) then
                if (self._keyboard.supportsCaret) then
                    textField:ReplaceSelection(s)
                else
                    textField:ReplaceText(s)
                end
            end

            if (self._keyboard.done) then
                self.focus = nil
            end
        end
    else
        textField:CheckComposition()
    end
end

function Stage:HandleCustomInput()
    local pos = self._customInputPos
    pos.y = stageHeight - pos.y
    local touch = self._touches[1]

    if (touch.x ~= pos.x or touch.y ~= pos.y) then
        touch.x = pos.x
        touch.y = pos.y
        touch:Move()
    end

    if (touch.lastRollOver ~= touch.target) then
        self:HandleRollOver(touch)
    end

    if (self._customInputButtonDown) then
        if (not touch.began) then
            self._touchCount = 1
            touch:Begin()
            touch.button = 0
            self.focus = touch.target

            touch:UpdateEvent()
            touch.target.onTouchBegin:BubbleCall(touch.evt)
        end
    elseif (touch.began) then
        self._touchCount = 0
        touch:End()

        local clickTarget = touch:ClickTest()
        if (clickTarget ~= nil) then
            touch:UpdateEvent()
            clickTarget.onClick:BubbleCall(touch.evt)
        end

        touch.button = -1
    end
end

function Stage:HandleMouseEvents()
    local touch = self._touches[1]
    if (touch.x ~= self._touchPosition.x or touch.y ~= self._touchPosition.y) then
        touch.x = self._touchPosition.x
        touch.y = self._touchPosition.y
        touch:Move()
    end

    if (touch.lastRollOver ~= touch.target) then
        self:HandleRollOver(touch)
    end

    if (Input.GetMouseButtonDown(1) or Input.GetMouseButtonDown(2) or Input.GetMouseButtonDown(3)) then
        if (not touch.began) then
            self._touchCount = 1
            touch:Begin()
            touch.button = Input.GetMouseButtonDown(3) and 2 or (Input.GetMouseButtonDown(2) and 1 or 0)
            self.focus = touch.target

            touch:UpdateEvent()
            touch.target.onTouchBegin:BubbleCall(touch.evt)
        end
    end
    if (Input.GetMouseButtonUp(1) or Input.GetMouseButtonUp(2) or Input.GetMouseButtonUp(3)) then
        if (touch.began) then
            self._touchCount = 0
            touch:End()

            local clickTarget = touch:ClickTest()
            if (clickTarget ~= nil) then
                touch:UpdateEvent()

                if (Input.GetMouseButtonUp(2) or Input.GetMouseButtonUp(3)) then
                    clickTarget.onRightClick:BubbleCall(touch.evt)
                else
                    clickTarget.onClick:BubbleCall(touch.evt)
                end
            end

            touch.button = -1
        end
    end
end

function Stage:HandleTouchEvents()
    local tc = Input.touchCount
    for i = 1, tc do
        local uTouch = Input:GetTouch(i)

        if (uTouch.phase == TouchPhase.Stationary) then
            --continue
        else
            local pos = uTouch.position
            pos.y = self.stageHeight - pos.y

            local touch = nil
            for j = 1, 5 do
                if (self._touches[j].touchId == uTouch.fingerId) then
                    touch = self._touches[j]
                    break
                end
            end
            if (touch == nil) then
                --continue
            else
                if (touch.x ~= pos.x or touch.y ~= pos.y) then
                    touch.x = pos.x
                    touch.y = pos.y
                    if touch.began then
                        touch:Move()
                    end
                end

                if (touch.lastRollOver ~= touch.target) then
                    self:HandleRollOver(touch)
                end

                if (uTouch.phase == TouchPhase.Began) then
                    if not touch.began then
                        self._touchCount = self._touchCount + 1
                        touch:Begin()
                        touch.button = 0
                        self.focus = touch.target

                        touch:UpdateEvent()
                        touch.target.onTouchBegin:BubbleCall(touch.evt)
                    end
                elseif (uTouch.phase == TouchPhase.Canceled or uTouch.phase == TouchPhase.Ended) then
                    if touch.began then
                        self._touchCount = self._touchCount - 1
                        touch:End()

                        if (uTouch.phase ~= TouchPhase.Canceled) then
                            local clickTarget = touch:ClickTest()
                            if (clickTarget ~= nil) then
                                touch.clickCount = uTouch.tapCount
                                touch:UpdateEvent()
                                clickTarget.onClick:BubbleCall(touch.evt)
                            end
                        end

                        touch.target = nil
                        self:HandleRollOver(touch)

                        touch.touchId = -1
                    end
                end
            end
        end
    end
end

---@param touch FairyGUI.TouchInfo
function Stage:HandleRollOver(touch)
    local element = touch.lastRollOver
    while (element ~= nil) do
        table.insert(self._rollOutChain, element)
        element = element.parent
    end

    touch.lastRollOver = touch.target

    element = touch.target
    local i
    while (element ~= nil) do
        i = self._rollOutChain:indexOf(element)
        if (i ~= -1) then
            self._rollOutChain:removeRange(i)
            break
        end
        table.insert(self._rollOverChain, element)

        element = element.parent
    end

    local cnt = #self._rollOutChain
    if (cnt > 0) then
        for i = 1, cnt do
            element = self._rollOutChain[i]
            if (element.stage ~= nil) then
                element.onRollOut:Call()
            end
            self._rollOutChain = {}
        end
    end

    cnt = #self._rollOverChain
    if (cnt > 0) then
        for i = 1, cnt do
            element = self._rollOverChain[i]
            if (element.stage ~= nil) then
                element.onRollOver:Call()
            end
        end
        self._rollOverChain = {}
    end
end

---@param target FairyGUI.Container
function Stage:ApplyPanelOrder(target)
    local sortingOrder = target._panelOrder
    local numChildren = self.numChildren
    local idx = 1
    local j
    local curIndex = -1
    for i=idx, numChildren do
        idx = i
        local obj = self:GetChildAt(i)
        if (obj == target) then
            curIndex = i
            --continue
        else
            local continue = false
            if (obj == GRoot.inst.displayObject) then
                j = 1000
            elseif obj:isa(Container) then
                j = obj._panelOrder
            else
                continue = true
            end
            if not continue and (sortingOrder <= j) then
                if (curIndex ~= -1) then
                    self:AddChildAt(target, i - 1)
                else
                    self:AddChildAt(target, i)
                end
                break
            end
        end
    end
    if (idx == numChildren) then
        self:AddChild(target)
    end
end

---@type FairyGUI.DisplayObject[]
Stage.sTempList1 = nil
---@type number[]
Stage.sTempList2 = nil

---@param panelSortingOrder number
function Stage:SortWorldSpacePanelsByZOrder(panelSortingOrder)
    if (Stage.sTempList1 == nil) then
        Stage.sTempList1 = {}
        Stage.sTempList2 = {}
    end

    local numChildren = self.numChildren
    for i = 1, numChildren do
        ---@type FairyGUI.Container
        local obj = self:GetChildAt(i)
        if (obj == nil or obj.renderMode ~= RenderMode.WorldSpace or obj._panelOrder ~= panelSortingOrder) then
            --continue
        else
            --借用一下tmpBounds
            obj._internal_bounds[1] = obj.cachedTransform.position.z
            obj._internal_bounds[2] = i
            table.insert(Stage.sTempList1, obj)
            table.insert(Stage.sTempList2, i)
        end
    end

    table.sort(Stage.sTempList1, Stage.CompareZ)

    self:ChangeChildrenOrder(Stage.sTempList2, Stage.sTempList1)

    Stage.sTempList1 = {}
    Stage.sTempList2 = {}
end

---@param c1 FairyGUI.DisplayObject
---@param c2 FairyGUI.DisplayObject
---@return number
function Stage.CompareZ(c1, c2)
    local ret = c2._internal_bounds[1] -  c1.self._internal_bounds[1]
    if ret == 0 then
        return c2._internal_bounds[2] -  c1.self._internal_bounds[2]
    end
    return ret
end

---@param texture FairyGUI.NTexture
function Stage:MonitorTexture(texture)
    if (self._toCollectTextures:indexOf(texture) == -1) then
        table.insert(self._toCollectTextures, texture)
    end
end

---@param param any
function Stage:RunTextureCollector(param)
    local cnt = #self._toCollectTextures
    local curTime = Time.time
    local i = 1
    while (i <= cnt) do
        local texture = self._toCollectTextures[i]
        if (texture.disposed) then
            table.remove(self._toCollectTextures, i)
            cnt = cnt - 1
        elseif (curTime - texture.lastActive > 5) then
            texture:Dispose()
            table.remove(self._toCollectTextures, i)
            cnt = cnt - 1
        else
            i = i + 1
        end
    end
end

---@param touchId number
---@param target FairyGUI.EventDispatcher
function Stage:AddTouchMonitor(touchId, target)
    local touch = nil
    for j = 1, 5 do
        touch = self._touches[j]
        if (touchId == -1 and touch.touchId ~= -1
                or touchId ~= -1 and touch.touchId == touchId) then
            break
        end
    end
    if (touch.touchMonitors:indexOf(target) == -1) then
        table.insert(touch.touchMonitors, target)
    end
end

---@param target FairyGUI.EventDispatcher
function Stage:RemoveTouchMonitor(touchId, target)
    for j = 1, 5 do
        local touch = self._touches[j]
        local i = touch.touchMonitors:indexOf(target)
        if i ~= -1 then
            table.remove(touch.touchMonitors, i)
        end
    end
end

---@param name string
function Stage:CreatePoolManager(name)
    local go = GameObject:get("[" + name + "]")
    go:SetActive(false)

    local t = go.transform;
    ToolSet.SetParent(t, self.cachedTransform)

    return t
end

local __get = Class.init_get(Stage, false)
local __set = Class.init_set(Stage, false)

---@param self FairyGUI.Stage
__get.inst = function(self)
    if self._inst == nil then
        self:Instantiate()
    end
    return self._inst
end

--[[
如果是true，表示触摸输入，将使用Input.GetTouch接口读取触摸屏输入。
如果是false，表示使用鼠标输入，将使用Input.GetMouseButtonXXX接口读取鼠标输入。
一般来说，不需要设置，底层会自动根据系统环境设置正确的值。
]]
---@param self FairyGUI.Stage
__get.touchScreen = function(self)
    return self._touchScreen
end

---@param self FairyGUI.Stage
---@param val boolean
__set.touchScreen = function(self, val)
    self._touchScreen = val
    if val then
        self._keyboard = FairyGUI.TouchScreenKeyboard.new()
        self.keyboardInput = true
    else
        self._keyboard = nil
        self.keyboardInput = false
        Stage.inst:ResetInputState()
    end
end

--[[
如果是true，表示使用屏幕上弹出的键盘输入文字。常见于移动设备。
如果是false，表示是接受按键消息输入文字。常见于PC。
一般来说，不需要设置，底层会自动根据系统环境设置正确的值。
]]
---@param self FairyGUI.Stage
__get.keyboardInput = function(self)
    return self._keyboardInput
end

---@param self FairyGUI.Stage
---@param val boolean
__set.keyboardInput = function(self, val)
    self._keyboardInput = val
end

---@param self FairyGUI.Stage
__get.isTouchOnUI = function(self)
    return Stage._inst ~= nil and Stage._inst.touchTarget ~= nil
end

---@param self FairyGUI.Stage
__get.touchTarget = function(self)
    if (self._frameGotHitTarget ~= Time.frameCount) then
        self:GetHitTarget()
    end

    if (self._touchTarget == self) then
        return nil
    end
    return self._touchTarget
end

__get.focus = function(self)
    if (self._focused ~= nil and self._focused.isDisposed) then
        self._focused = nil
    end
    return self._focused
end

---@param self FairyGUI.Stage
---@param val FairyGUI.DisplayObject
__set.focus = function(self, val)
    if (self._focused == value) then
        return
    end

    local oldFocus = self._focused
    self._focused = value
    if (self._focused == self) then
        self._focused = nil
    end

    if (oldFocus ~= nil) then
        if oldFocus:isa(InputTextField) then
            oldFocus.onFocusOut:Call()
        end
        oldFocus.onRemovedFromStage:RemoveCapture(self._focusRemovedDelegate)
    end

    if (self._focused ~= nil) then
        if self._focused:isa(InputTextField) then
            self._lastInput = self._focused
            self._lastInput.onFocusIn:Call()
        end

        self._focused.onRemovedFromStage:AddCapture(self._focusRemovedDelegate)
    end
end

__get.touchPosition = function(self)
    self:UpdateTouchPosition()
    return self._touchPosition
end

__get.touchCount = function(self)
    return self._touchCount
end

__get.keyboard = function(self)
    return self._keyboard
end

__set.keyboard = function(self, val)
    self._keyboard = val
end

setmetatable(Stage, Stage)
--endregion

--region FairyGUI.TouchInfo 定义
---@type FairyGUI.EventBridge[]
TouchInfo.sHelperChain = {}

function TouchInfo:__ctor()
    self.evt = InputEvent.new()
    self.downTargets = {}
    self.touchMonitors = {}
    self:Reset()
end

function TouchInfo:Reset()
    self.touchId = -1
    self.x = 0
    self.y = 0
    self.clickCount = 0
    self.button = -1
    self.keyCode = ''
    self.character = '\0'
    self.modifiers = 0
    self.mouseWheelDelta = 0
    self.lastClickTime = 0
    self.began = false
    self.target = nil
    self.downTargets = {}
    self.lastRollOver = nil
    self.clickCancelled = false
    self.touchMonitors = {}
end

function TouchInfo:UpdateEvent()
    self.evt.touchId = self.touchId
    self.evt.x = self.x
    self.evt.y = self.y
    self.evt.clickCount = self.clickCount
    self.evt.keyCode = self.keyCode
    self.evt.character = self.character
    self.evt.modifiers = self.modifiers
    self.evt.mouseWheelDelta = self.mouseWheelDelta
    self.evt.button = self.button
end

function TouchInfo:Begin()
    self.began = true
    self.clickCancelled = false
    self.downX = x
    self.downY = y

    self.downTargets = {}
    if self.target ~= nil then
        table.insert(self.downTargets, self.target)
        local obj = self.target.parent
        while obj ~= nil do
            table.insert(self.downTargets, obj)
            obj = obj.parent
        end
    end
end

function TouchInfo:Move()
    self:UpdateEvent()

    local len = #self.touchMonitors
    if len > 0 then
        for i = 1, len do
            local e = self.touchMonitors[i]
            if e ~= nil then
                if e:isa(FairyGUI.DisplayObject) and e.stage == nil then
                    -- continue
                elseif e:isa(FairyGUI.GObject) and not e.onStage then
                    -- continue
                else
                    e:GetChainBridges("onTouchMove", TouchInfo.sHelperChain, false)
                end
            end
        end

        Stage.inst:BubbleEvent("onTouchMove", self.evt, TouchInfo.sHelperChain)
        TouchInfo.sHelperChain = {}
    else
        Stage.inst.onTouchMove:Call(self.evt)
    end
end

function TouchInfo:End()
    self.began = false

    self:UpdateEvent()

    local len = #self.touchMonitors
    if (len > 0) then
        for i = 1, len do
            local e = self.touchMonitors[i]
            if (e ~= nil) then
                e:GetChainBridges("onTouchEnd", TouchInfo.sHelperChain, false)
            end
        end
        self.target:BubbleEvent("onTouchEnd", self.evt, TouchInfo.sHelperChain)

        self.touchMonitors = {}
        TouchInfo.sHelperChain = {}
    else
        self.target.onTouchEnd:BubbleCall(self.evt)
    end

    if (Time.realtimeSinceStartup - self.lastClickTime < 0.35) then
        if (self.clickCount == 2) then
            self.clickCount = 1
        else
            self.clickCount = self.clickCount + 1
        end
    else
        self.clickCount = 1
    end
    self.lastClickTime = Time.realtimeSinceStartup
end

function TouchInfo:ClickTest()
    if (#self.downTargets == 0
            or self.clickCancelled
            or math.abs(x - downX) > 50 or math.abs(y - downY) > 50) then
        return nil
    end

    local obj = self.downTargets[0]
    if (obj.stage ~= nil) then --依然派发到原来的downTarget，虽然可能它已经偏离当前位置，主要是为了正确处理点击缩放的效果
        return obj
    end

    obj = self.target
    while (obj ~= nil) do
        local i = self.downTargets:indexOf(obj)
        if (i ~= -1 and obj.stage ~= nil) then
            return obj
        end
        obj = obj.parent
    end

    self.downTargets = {}

    return obj
end
--endregion


FairyGUI.Stage = Stage
FairyGUI.TouchInfo = TouchInfo
return Stage