--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 17:06
--

local Class = require('libs.Class')

local Object = Love2DEngine.Object

---@class Love2DEngine.AudioClip:Love2DEngine.Object
local AudioClip = Class.inheritsFrom('AudioClip', nil, Object)

--TODO: Love2DEngine.AudioClip

Love2DEngine.AudioClip = AudioClip
return AudioClip