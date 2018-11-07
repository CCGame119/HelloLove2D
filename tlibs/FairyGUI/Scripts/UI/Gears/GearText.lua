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

--TODO: FairyGUI.GearText

FairyGUI.GearText = GearText
return GearText