--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 16:41
--

local Class = require('libs.Class')

local UIObjectFactory = FairyGUI.UIObjectFactory
local ObjectType = FairyGUI.ObjectType
local GRoot = FairyGUI.GRoot
local Stage = FairyGUI.Stage
local AlignType = FairyGUI.AlignType
local VertAlignType = FairyGUI.VertAlignType
local EventCallback1 = FairyGUI.EventCallback1
local GComponent = FairyGUI.GComponent


---@class FairyGUI.DragDropManager:ClassType
---Helper for drag and drop.
---这是一个提供特殊拖放功能的功能类。与GObject.draggable不同，拖动开始后，他使用一个替代的图标作为拖动对象。
---当玩家释放鼠标/手指，目标组件会发出一个onDrop事件。
---@field public inst FairyGUI.DragDropManager @static
---@field public dragAgent FairyGUI.GLoader @用于实际拖动的Loader对象。你可以根据实际情况设置loader的大小，对齐等。
---@field public dragging boolean @返回当前是否正在拖动。
---@field private _agent FairyGUI.GLoader
---@field private _sourceData any
---@field private _inst FairyGUI.DragDropManager @static
local DragDropManager = Class.inheritsFrom('DragDropManager')

function DragDropManager:__ctor()
    self.__dragEndDelegate = EventCallback1.new(self.__dragEnd, self)

    self._agent = UIObjectFactory.NewObject(ObjectType.Loader)
    self._agent.gameObjectName = "DragDropAgent"
    self._agent:SetHome(GRoot.inst)
    self._agent.touchable = false  --important
    self._agent.draggable = true
    self._agent:SetSize(100, 100)
    self._agent:SetPivot(0.5, 0.5, true)
    self._agent.align = AlignType.Center
    self._agent.verticalAlign = VertAlignType.Middle
    self._agent.sortingOrder = math.maxval
    self._agent.onDragEnd:Add(self.__dragEndDelegate)
end

---开始拖动。
---@param source FairyGUI.GObject
---@param icon string
---@param sourceData any
---@param touchPointID number @default -1
function DragDropManager:StartDrag(source, icon, sourceData, touchPointID)
    if (self._agent.parent ~= nil) then
        return
    end

    self._sourceData = sourceData
    self._agent.url = icon
    GRoot.inst:AddChild(self._agent)
    self._agent.xy = GRoot.inst:GlobalToLocal(Stage.inst:GetTouchPosition(touchPointID))
    self._agent:StartDrag(touchPointID)
end

---取消拖动。
function DragDropManager:Cancel()
    if (self._agent.parent ~= nil) then
        self._agent:StopDrag()
        GRoot.inst:RemoveChild(self._agent)
        self._sourceData = nil
    end
end

---@param evt FairyGUI.EventContext
function DragDropManager:__dragEnd(evt)
    if (self._agent.parent == nil) then   --cancelled
        return
    end

    GRoot.inst:RemoveChild(self._agent)

    local sourceData = self._sourceData
    self._sourceData = nil

    ---@type FairyGUI.GComponent
    local obj = GRoot.inst.touchTarget
    while (obj ~= nil) do
        if obj:isa(GComponent) then
            if (not obj.onDrop.isEmpty) then
                obj:RequestFocus()
                obj.onDrop:Call(sourceData)
                return
            end
        end

        obj = obj.parent
    end
end


local __get = Class.init_get(DragDropManager, false)
local __set = Class.init_set(DragDropManager, false)

---@param self FairyGUI.DragDropManager
__get.inst = function(self)
    if DragDropManager._inst == nil then
        DragDropManager._inst = DragDropManager.new()
    end
    return DragDropManager._inst
end

---@param self FairyGUI.DragDropManager
__get.dragAgent = function(self)
    return self._agent
end

---@param self FairyGUI.DragDropManager
__get.dragging = function(self)
    return self._agent.parent ~= nil
end


setmetatable(DragDropManager, DragDropManager)
FairyGUI.DragDropManager = DragDropManager
return DragDropManager