--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 17:37
--

local Class = require('libs.Class')

local GObject = FairyGUI.GObject
local IColorGear = FairyGUI.IColorGear


---@class FairyGUI.GGraph:FairyGUI.GObject @implement IColorGear
---GGraph class.
---对应编辑器里的图形对象。图形有两个用途，一是用来显示简单的图形，例如矩形等；二是作为一个占位的用途，
---可以将本对象替换为其他对象，或者在它的前后添加其他对象，相当于一个位置和深度的占位；还可以直接将内容设置
---为原生对象。
---@field private _shape FairyGUI.Shape
local GGraph = Class.inheritsFrom('GGraph', nil, GObject, {IColorGear})

function GGraph:__ctor()
    GObject.__ctor(self)
end

--TODO: FairyGUI.GGraph

FairyGUI.GGraph = GGraph
return GGraph