--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:38
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local IAnimationGear = FairyGUI.IAnimationGear
local IColorGear = FairyGUI.IColorGear

---@class FairyGUI.GMovieClip:FairyGUI.GObject @implement IAnimationGear, IColorGear
local GMovieClip = Class.inheritsFrom('GMovieClip', nil, GObject)

--TODO: FairyGUI.GMovieClip

FairyGUI.GMovieClip = GMovieClip
return GMovieClip