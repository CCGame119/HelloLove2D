--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:35
--

local Class = require('libs.Class')

local GearBase = FairyGUI.GearBase

---@class FairyGUI.GearDisplay:FairyGUI.GearBase
---Gear is a connection between object and controller.
---@field public pages string[]
---@field public connected boolean
---@field private _visible number
---@field private _displayLockToken number
local GearDisplay = Class.inheritsFrom('GearDisplay', nil, GearBase)

function GearDisplay:__ctor(owner)
    GearBase.__ctor(self, owner)
    self._displayLockToken = 1
end

function GearDisplay:AddStatus(pageId, buffer)
end

function GearDisplay:Init()
    self.pages = nil
end

function GearDisplay:Apply()
    self._displayLockToken = self._displayLockToken + 1
    if self._displayLockToken == 0 then
        self._displayLockToken = 1
    end

    if self.pages == nil or #self.pages == 0 or
            self.pages:indexOf(self._controller.selectedPageId) ~= -1 then
        self._visible = 1
    else
        self._visible = 0
    end
end

function GearDisplay:UpdateState()
end

function GearDisplay:AddLock()
    self._visible = self._visible + 1
    return self._displayLockToken
end

---@param token number
function GearDisplay:ReleaseLock(token)
    if token == self._displayLockToken then
        self._visible = self._visible - 1
    end
end

local __get = Class.init_get(GearDisplay)

---@param self FairyGUI.GearDisplay
__get.connected = function(self) return self._controller == nil or self._visible > 0 end


FairyGUI.GearDisplay = GearDisplay
return GearDisplay