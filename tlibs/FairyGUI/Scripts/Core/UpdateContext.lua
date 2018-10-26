--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 11:12
--

local Class = require('libs.Class')

local Screen = Love2DEngine.Screen
local Rect = Love2DEngine.Rect
local Vector4 = Love2DEngine.Vector4
local EventCallback0 = FairyGUI.EventCallback0
local Stats = FairyGUI.Stats
local ToolSet = Utils.ToolSet

local  bit = require('bit')
local lshift, rshift = bit.lshift, bit.rshift

---@class FairyGUI.UpdateContext.ClipInfo:ClassType
---@field public rect Love2DEngine.Rect
---@field public clipBox Love2DEngine.Vector4
---@field public soft boolean
---@field public softness Love2DEngine.Vector4
---@field public clipId number
---@field public stencil boolean
---@field public reversedMask boolean
local ClipInfo = Class.inheritsFrom('ClipInfo')

function ClipInfo:__ctor()
    self.rect = Rect()
    self.clipBox = Vector4()
    self.soft = false
    self.softness = Vector4()
    self.clipId = 0
    self.stencil = false
    self.reversedMask = false
end


---@class FairyGUI.UpdateContext:ClassType
---@field public clipped boolean
---@field public clipInfo FairyGUI.UpdateContext.ClipInfo
---@field public renderingOrder number
---@field public batchingDepth number
---@field public rectMaskDepth number
---@field public stencilReferenceValue number
---@field public alpha number
---@field public grayed boolean
---@field public current FairyGUI.UpdateContext
---@field public frameId number
---@field public working boolean
---@field public OnBegin FairyGUI.EventCallback0
---@field public OnEnd FairyGUI.EventCallback0
---@field private _clipStack FairyGUI.UpdateContext.ClipInfo[]
---@field private _tmpBegin FairyGUI.EventCallback0
local UpdateContext = Class.inheritsFrom('UpdateContext')

function UpdateContext:__ctor(...)
    self._clipStack = {}
    self.frameId = 1
    self.ClipInfo = ClipInfo.new()

    self.OnBegin = EventCallback0.new()
    self.OnEnd = EventCallback0.new()
end

function UpdateContext:Begin()
    self.current = self

    self.frameId = self.frameId + 1
    if self.frameId == 0 then
        self.frameId = 1
    end
    self.renderingOrder = 0
    self.batchingDepth = 0
    self.rectMaskDepth = 0
    self.stencilReferenceValue = 0
    self.alpha = 1
    self.grayed = false

    self.clipped = false
    self._clipStack = {}

    Stats.ObjectCount = 0
    Stats.GraphicsCount = 0

    self._tmpBegin = self.OnBegin:Clone()
    self.OnBegin:Clear()

    --允许OnBegin里再次Add，这里没有做死锁检查
    while not self._tmpBegin.isEmpty do
        self._tmpBegin:Invoke()
        self._tmpBegin = self.OnBegin:Clone()
        self.OnBegin:Clear()
    end
    self.working = true
end

function UpdateContext:End()
    self.working = false

    if not self.OnEnd.isEmpty then
        self.OnEnd:Invoke()
    end

    self.OnEnd:Clear()
end

---@param clipId number
---@param clipRect Love2DEngine.Rect
---@param softness Love2DEngine.Vector4
---@param reversedMask boolean
function UpdateContext:EnterClipping(clipId, clipRect, softness, reversedMask)
    table.insert(self._clipStack, self.clipInfo)

    if clipRect == nil then
        if self.stencilReferenceValue == 0 then
            self.stencilReferenceValue = 1
        else
            self.stencilReferenceValue = lshift(self.stencilReferenceValue, 1)
        end
        self.clipInfo.clipId = clipId
        self.clipInfo.stencil= true
        self.clipInfo.reversedMask = reversedMask
        self.clipped = true
    else
        local rect = clipRect
        if self.rectMaskDepth > 0 then
            rect = ToolSet.Intersection(self.clipInfo.rect, rect)
        end

        self.rectMaskDepth = self.rectMaskDepth + 1
        self.clipInfo.stencil = false
        self.clipped = true

       --[[clipPos = xy * clipBox.zw + clipBox.xy
        利用这个公式，使clipPos变为当前顶点距离剪切区域中心的距离值，剪切区域的大小为2x2
        那么abs(clipPos)>1的都是在剪切区域外]]
        self.clipInfo.rect:Assign(rect)
        rect.x = rect.x + rect.width / 2
        rect.y = rect.y + rect.height / 2
        rect.width = rect.width / 2
        rect.height = rect.height / 2
        if rect.width == 0 or rect.height == 0 then
            self.clipInfo.clipBox = Vector4(-2, -2, 0, 0)
        else
            self.clipInfo.clipBox = Vector4(-rect.x / rect.width, -rect.y / rect.height,
                    1.0 / rect.width, 1.0 / rect.height)
        end
        self.clipInfo.clipId = clipId;
        self.clipInfo.soft = softness ~= nil;
        if self.clipInfo.soft then
            self.clipInfo.softness = softness
            local vx = self.clipInfo.rect.width * Screen.height * 0.25
            local vy = self.clipInfo.rect.height * Screen.height * 0.25

            if self.clipInfo.softness.x > 0 then
                self.clipInfo.softness.x = vx / self.clipInfo.softness.x
            else
                self.clipInfo.softness.x = 10000
            end

            if self.clipInfo.softness.y > 0 then
                self.clipInfo.softness.y = vy / self.clipInfo.softness.y
            else
                self.clipInfo.softness.y = 10000
            end

            if self.clipInfo.softness.z > 0 then
                self.clipInfo.softness.z = vx / self.clipInfo.softness.z
            else
                self.clipInfo.softness.z = 10000
            end

            if self.clipInfo.softness.w > 0 then
                self.clipInfo.softness.w = vy / self.clipInfo.softness.w
            else
                self.clipInfo.softness.w = 10000
            end
        end
    end
end

function UpdateContext:Leaveclipping()
    if self.clipInfo.stencil then
        self.stencilReferenceValue = rshift(self.stencilReferenceValue, 1)
    else
        self.rectMaskDepth = self.rectMaskDepth - 1
    end

    self.clipInfo = table.remove(self._clipStack)
    self.clipped = #self._clipStack > 0
end


UpdateContext.ClipInfo = ClipInfo
FairyGUI.UpdateContext = UpdateContext
return UpdateContext