--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:32
--

local Class = require('libs.Class')

local GearBase = FairyGUI.GearBase

---@class FairyGUI.GearAnimationValue:ClassType
---@field public playing boolean
---@field public frame number
local GearAnimationValue = Class.inheritsFrom('GearAnimationValue')

---@param playing boolean
---@param frame number
function GearAnimationValue:__ctor(playing, frame)
    self.playing = playing
    self.frame = frame
end

---@class FairyGUI.GearAnimation:FairyGUI.GearBase
---@field private _storage table<string, FairyGUI.GearAnimationValue>
---@field private _default FairyGUI.GearAnimationValue
local GearAnimation = Class.inheritsFrom('GearAnimation', nil, GearBase)

function GearAnimation:__ctor(owner)
    GearBase.__ctor(self, owner)
end

function GearAnimation:Init()
    self._default = GearAnimationValue.new(self._owner.playing, self._owner.frame)
    self._storage = {}
end

function GearAnimation:AddStatus(pageId, buffer)
    local gv
    if (pageId == nil) then
        gv = self._default
    else
        gv = GearAnimationValue.new(false, 0)
        self._storage[pageId] = gv
    end

    gv.playing = buffer:ReadBool()
    gv.frame = buffer:ReadInt()
end

function GearAnimation:Apply()
    self._owner._gearLocked = true

    local selPId = self._controller.selectedPageId
    local gv = self._storage[selPId]
    if nil == gv then
        gv = self._default
    end

    ---@type FairyGUI.IAnimationGear
    local mc = self._owner
    mc.frame = gv.frame
    mc.playing = gv.playing

    self._owner._gearLocked = false
end

function GearAnimation:UpdateState()
    local selPId = self._controller.selectedPageId
    ---@type FairyGUI.IAnimationGear
    local mc = self._owner
    local gv = self._storage[selPId]
    if nil == gv then
        self._storage[selPId] = GearAnimationValue.new(mc.playing, mc.frame)
    else
        gv.playing = mc.playing
        gv.frame = mc.frame
    end
end


FairyGUI.GearAnimationValue = GearAnimationValue
FairyGUI.GearAnimation = GearAnimation
return GearAnimation