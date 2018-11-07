--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:38
--

local Class = require('libs.Class')

local GearBase = FairyGUI.GearBase

---@class FairyGUI.GearText:FairyGUI.GearBase
---@field private _storage table<string, string>
---@field private _default string
local GearText = Class.inheritsFrom('GearText', nil, GearBase)

---@param owner FairyGUI.GObject
function GearText:__ctor(owner)
    GearBase.__ctor(self, owner)
end

function GearText:Init()
    self._default = self._owner.text
    self._storage = {}
end

function GearText:AddStatus(pageId, buffer)
    if nil == pageId then
        self._default = buffer:ReadS()
    else
        self._storage[pageId] = buffer:ReadS()
    end
end

function GearText:Apply()
    self._owner._gearLocked = true

    local cv = self._storage[self._controller.selectedPageId]
    if cv == nil  then
        cv = self._default
    end

    self._owner.text = cv
    self._owner._gearLocked = false
end

function GearText:UpdateState()
    self._storage[self._controller.selectedPageId] = self._owner.text
end


FairyGUI.GearText = GearText
return GearText