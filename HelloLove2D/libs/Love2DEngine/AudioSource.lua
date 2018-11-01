--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/1 12:19
--

local Class = require('libs.Class')

local Behaviour = Love2DEngine.Behaviour

---@class Love2DEngine.AudioSource:Love2DEngine.Behaviour
local AudioSource = Class.inheritsFrom('AudioSource', nil, Behaviour)

--TODO: Love2DEngine.AudioSource

Love2DEngine.AudioSource = AudioSource
return AudioSource