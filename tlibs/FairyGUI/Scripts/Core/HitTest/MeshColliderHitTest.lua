--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 14:35
--

local Class = require('libs.Class')

local ColliderHitTest = FairyGUI.ColliderHitTest

---@class FairyGUI.MeshColliderHitTest:FairyGUI.ColliderHitTest
local MeshColliderHitTest = Class.inheritsFrom('MeshColliderHitTest', nil, ColliderHitTest)

--TODO: FairyGUI.MeshColliderHitTest

FairyGUI.MeshColliderHitTest = MeshColliderHitTest
return MeshColliderHitTest