--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/11 13:33
--

--region 辅助提示类型

---@class namespace:table @名称空间
---@class byte:number @字节类型
---@class enum:table<string,number> @枚举类型
---@class enums:table<string,string> @枚举类型
---@class char:string

---@class size:table
---@field public width number
---@field public height number
local size = { width = 0, height = 0}

---@class ClassType @ 类类型，用于辅助提示
---@field public __cls_name string @ 类名称
ClassType = {}
---构造函数
---@generic T:ClassType
---@return T
function ClassType.new(...) end
---构造类回调: 注意这个方法在当前类不会被调用，只会调用基
---类的实现，主要用于实现pool， 当前类实现，自己主动调用一下就可以了
function ClassType.__cls_ctor(cls) end
---构造回调
function ClassType:__ctor(...) end
---类
---@generic T:ClassType
---@return T
function ClassType:class() end
---基类
---@generic T:ClassType
---@return T
function ClassType:superClass() end
---类名
---@return string
function ClassType:clsName() end
---类型判断
---@return boolean
function ClassType:isa() end

--endregion