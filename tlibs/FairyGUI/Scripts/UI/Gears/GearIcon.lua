--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:36
--

local Class = require('libs.Class')

local GearBase = FairyGUI.GearBase

---@class FairyGUI.GearIcon:FairyGUI.GearBase
---@field private _storage table<string, string>
---@field private _default string
local GearIcon = Class.inheritsFrom('GearIcon', nil, GearBase)

function GearIcon:__ctor(owner)
    GearBase.__ctor(self, owner)
end

function GearIcon:Init()
    self._default = self._owner.icon
    self._storage = {}
end

function GearIcon:AddStatus(pageId, buffer)
    if pageId == nil then
        self._default = buffer:ReadS()
    else
        self._storage[pageId] = buffer:ReadS()
    end
end

function GearIcon:Apply()
    local _owner = self._owner
    local selPId = self._controller.selectedPageId

    _owner._gearLocked = true

    local cv = self._storage[selPId]
    if nil == cv then
        cv = self._default
    end

    _owner.icon = cv

    _owner._gearLocked = false
end

function GearIcon:UpdateState()
    self._storage[self._controller.selectedPageId] = self._owner.icon
end


FairyGUI.GearIcon = GearIcon
return GearIcon