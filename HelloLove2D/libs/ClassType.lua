--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/11 13:33
--

--region 辅助提示类型

---@class namespace:table @名称空间
---@class byte:number @字节类型
---@class enum:table<string,number> @枚举类型
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
---构造类回调
function ClassType.__cls_ctor(cls) end
---构造回调
function ClassType:__ctor(...) end
---类
function ClassType:class(...) end
---基类
function ClassType:superClass(...) end
---类型判断
function ClassType:isa(...) end

--endregion