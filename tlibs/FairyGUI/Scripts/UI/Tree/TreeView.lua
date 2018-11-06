--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 19:40
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

local EventDispatcher = FairyGUI.EventDispatcher
local EventCallback1 = FairyGUI.EventCallback1
local EventListener = FairyGUI.EventListener
local TreeNode = FairyGUI.TreeNode

---@class FairyGUI.TreeNodeCreateCellDelegate:Delegate @fun(node:FairyGUI.TreeNode):FairyGUI.GComponent
local TreeNodeCreateCellDelegate = Delegate.newDelegate('TreeNodeCreateCellDelegate')
---@class FairyGUI.TreeNodeRenderDelegate:Delegate @fun(node:FairyGUI.TreeNode)
local TreeNodeRenderDelegate = Delegate.newDelegate('TreeNodeRenderDelegate')
---@class FairyGUI.TreeNodeWillExpandDelegate:Delegate @fun(node:FairyGUI.TreeNode, expand:boolean)
local TreeNodeWillExpandDelegate = Delegate.newDelegate('TreeNodeWillExpandDelegate')

---@class FairyGUI.TreeView:FairyGUI.EventDispatcher
---@field public list FairyGUI.GList @TreeView使用的List对象
---@field public root FairyGUI.TreeNode @TreeView的顶层节点，这是个虚拟节点，也就是他不会显示出来。
---@field public indent number @TreeView每级的缩进，单位像素。
---@field public treeNodeCreateCell FairyGUI.TreeNodeCreateCellDelegate @当TreeNode需要创建对象的显示对象时回调
---@field public treeNodeRender FairyGUI.TreeNodeRenderDelegate @当TreeNode需要更新时回调
---@field public treeNodeWillExpand FairyGUI.TreeNodeWillExpandDelegate @当TreeNode即将展开或者收缩时回调。可以在回调中动态增加子节点。
---@field public onClickNode FairyGUI.EventListener @点击任意TreeNode时触发
---@field public onRightClickNode FairyGUI.EventListener @右键点击任意TreeNode时触发
local TreeView = Class.inheritsFrom('TreeView', nil, EventDispatcher)

---@param list FairyGUI.GList
function TreeView:__ctor(list)
    self.__clickExpandButtonDelegate = EventCallback1.new(self.__clickExpandButton, self)
    self.__clickItemDelegate = EventCallback1.new(self.__clickItem, self)

    self.list = list
    list.onClickItem:Add(self.__clickItemDelegate)
    list.onRightClickItem:Add(self.__clickItemDelegate)
    list:RemoveChildrenToPool()

    self.root = TreeNode.new(true)
    self.root:SetTree(self)
    self.root.cell = list
    self.root.expanded = true

    self.indent = 30

    self.onClickNode = EventListener.new(self, "onClickNode")
    self.onRightClickNode = EventListener.new(self, "onRightClickNode")
end

---@return FairyGUI.TreeNode
function TreeView:GetSelectedNode()
    if (self.list.selectedIndex ~= -1) then
        return self.list:GetChildAt(self.list.selectedIndex).data
    else
        return nil
    end
end

---@return FairyGUI.TreeNode[]
function TreeView:GetSelection()
    local sels = self.list:GetSelection()
    local cnt = #sels
    ---@type FairyGUI.TreeNode[]
    local ret = {}
    for i = 1, cnt do
        ---@type FairyGUI.TreeNode
        local node = self.list:GetChildAt(sels[i]).data
        table.insert(ret, node)
    end

    return ret
end

---@param node FairyGUI.TreeNode
---@param scrollItToView boolean
function TreeView:AddSelection(node, scrollItToView)
    scrollItToView = scrollItToView or false
    local parentNode = node.parent
    while (parentNode ~= nil and parentNode ~= root) do
        parentNode.expanded = true
        parentNode = parentNode.parent
    end
    self.list:AddSelection(self.list:GetChildIndex(node.cell), scrollItToView)
end

---@param node FairyGUI.TreeNode
function TreeView:RemoveSelection(node)
    self.list:RemoveSelection(self.list:GetChildIndex(node.cell))
end

function TreeView:ClearSelection()
    self.list:ClearSelection()
end

---@param node FairyGUI.TreeNode
---@return number
function TreeView:GetNodeIndex( node)
    return self.list:GetChildIndex(node.cell)
end

---@param node FairyGUI.TreeNode
function TreeView:UpdateNode(node)
    if (node.cell == nil) then
        return
    end

    if (self.treeNodeRender ~= nil) then
        self:treeNodeRender(node)
    end
end

---@param node FairyGUI.TreeNode[]
function TreeView:UpdateNodes(nodes)
    local cnt = #nodes
    for i = 1, cnt do
        local node = nodes[i]
        if (node.cell == nil) then
            return
        end

        if (self.treeNodeRender ~= nil) then
            self:treeNodeRender(node)
        end
    end
end

---@param folderNode FairyGUI.TreeNode
function TreeView:ExpandAll(folderNode)
    folderNode.expanded = true
    local cnt = folderNode.numChildren
    for i = 1, cnt do
        local node = folderNode:GetChildAt(i)
        if (node.isFolder) then
            self:ExpandAll(node)
        end
    end
end

---@param folderNode FairyGUI.TreeNode
function TreeView:CollapseAll(folderNode)
    if (folderNode ~= self.root) then
        folderNode.expanded = false
    end

    local cnt = folderNode.numChildren
    for i = 1, cnt do
        local node = folderNode:GetChildAt(i)
        if (node.isFolder) then
            self:CollapseAll(node)
        end
    end
end

---@param node FairyGUI.TreeNode
function TreeView:CreateCell(node)
    if (self.treeNodeCreateCell ~= nil) then
        node.cell = self:treeNodeCreateCell(node)
    else
        node.cell = self.list.itemPool:GetObject(self.list.defaultItem)
    end
    if (node.cell == nil) then
        error("Unable to create tree cell")
    end
    node.cell.data = node

    local indentObj = node.cell:GetChild("indent")
    if (indentObj ~= nil) then
        indentObj.width = (node.level - 1) * indent
    end

    ---@type FairyGUI.GButton
    local expandButton = node.cell:GetChild("expandButton")
    if (expandButton ~= nil) then
        if (node.isFolder) then
            expandButton.visible = true
            expandButton.onClick:Add(self.__clickExpandButtonDelegate)
            expandButton.data = node
            expandButton.selected = node.expanded
        else
            expandButton.visible = false
        end
    end

    if (self.treeNodeRender ~= nil) then
        self:treeNodeRender(node)
    end
end

---@param node FairyGUI.TreeNode
function TreeView:AfterInserted(node)
    self:CreateCell(node)

    local index = self:GetInsertIndexForNode(node)
    self.list:AddChildAt(node.cell, index)
    if (self.treeNodeRender ~= nil) then
        self:treeNodeRender(node)
    end
    if (node.isFolder and node.expanded) then
        self:CheckChildren(node, index)
    end
end

---@param node FairyGUI.TreeNode
---@return number
function TreeView:GetInsertIndexForNode(node)
    local prevNode = node:GetPrevSibling()
    if (prevNode == nil) then
        prevNode = node.parent
    end
    local insertIndex = self.list:GetChildIndex(prevNode.cell) + 1
    local myLevel = node.level
    local cnt = self.list.numChildren
    for i = insertIndex, cnt do
        ---@type FairyGUI.TreeNode
        local testNode = self.list:GetChildAt(i).data
        if (testNode.level <= myLevel) then
            break
        end
        insertIndex = insertIndex + 1
    end

    return insertIndex
end

---@param node FairyGUI.TreeNode
function TreeView:AfterRemoved(node)
    self:RemoveNode(node)
end

---@param node FairyGUI.TreeNode
function TreeView:AfterExpanded(node)
    if (node ~= self.root and self.treeNodeWillExpand ~= nil) then
        self:treeNodeWillExpand(node, true)
    end

    if (node.cell == nil) then
        return
    end

    if (node ~= self.root) then
        if (self.treeNodeRender ~= nil) then
            self:treeNodeRender(node)
        end
        ---@type FairyGUI.GButton
        local expandButton = node.cell:GetChild("expandButton")
        if (expandButton ~= nil) then
            expandButton.selected = true
        end
    end

    if (node.cell.parent ~= nil) then
        self:CheckChildren(node, self.list:GetChildIndex(node.cell))
    end
end

---@param node FairyGUI.TreeNode
function TreeView:AfterCollapsed(node)
    if (node ~= self.root and self.treeNodeWillExpand ~= nil) then
        self:treeNodeWillExpand(node, false)
    end

    if (node.cell == nil) then
        return
    end

    if (node ~= self.root) then
        if (self.treeNodeRender ~= nil) then
            self:treeNodeRender(node)
        end

        ---@type FairyGUI.GButton
        local expandButton = node.cell:GetChild("expandButton")
        if (expandButton ~= nil) then
            expandButton.selected = false
        end
    end

    if (node.cell.parent ~= nil) then
        self:HideFolderNode(node)
    end
end

---@param node FairyGUI.TreeNode
function TreeView:AfterMoved(node)
    if not node.isFolder then
        self.list:RemoveChild(node.cell)
    else
        self:HideFolderNode(node)
    end

    local index = self:GetInsertIndexForNode(node)
    self.list:AddChildAt(node.cell, index)

    if (node.isFolder and node.expanded) then
        self:CheckChildren(node, index)
    end
end

---@param folderNode FairyGUI.TreeNode
---@param index number
---@return number
function TreeView:CheckChildren(folderNode, index)
    local cnt = folderNode.numChildren
    for i = 1, cnt do
        index = index + 1
        local node = folderNode:GetChildAt(i)
        if (node.cell == nil) then
            self:CreateCell(node)
        end

        if (node.cell.parent == nil) then
            self.list:AddChildAt(node.cell, index)
        end
        if (node.isFolder and node.expanded) then
            index = self:CheckChildren(node, index)
        end
    end

    return index
end

---@param folderNode FairyGUI.TreeNode
function TreeView:HideFolderNode(folderNode)
    local cnt = folderNode.numChildren
    for i = 1, cnt do
        local node = folderNode:GetChildAt(i)
        if (node.cell ~= nil) then
            if(node.cell.parent ~= nil) then
                self.list:RemoveChild(node.cell)
            end
            self.list.itemPool:ReturnObject(node.cell)
            node.cell.data = nil
            node.cell = nil
        end
        if (node.isFolder and node.expanded) then
            self:HideFolderNode(node)
        end
    end
end

---@param node FairyGUI.TreeNode
function TreeView:RemoveNode(node)
    if (node.cell ~= nil) then
        if (node.cell.parent ~= nil) then
            self.list:RemoveChild(node.cell)
        end
        self.list.itemPool:ReturnObject(node.cell)
        node.cell.data = nil
        node.cell = nil
    end

    if (node.isFolder) then
        local cnt = node.numChildren
        for i = 1, cnt do
            local node2 = node:GetChildAt(i)
            self:RemoveNode(node2)
        end
    end
end

---@param context FairyGUI.EventContext
function TreeView:__clickExpandButton(context)
    context.StopPropagation()

    local expandButton = context.sender
    ---@type FairyGUI.TreeNode
    local node = expandButton.parent.data
    if (self.list.scrollPane ~= nil) then
        local posY = self.list.scrollPane.posY
        if (expandButton.selected) then
            node.expanded = true
        else
            node.expanded = false
        end
        self.list.scrollPane.posY = posY
        self.list.scrollPane:ScrollToView(node.cell)
    else
        if (expandButton.selected) then
            node.expanded = true
        else
            node.expanded = false
        end
    end
end

---@param context FairyGUI.EventContext
function TreeView:__clickItem(context)
    local posY = 0
    if (self.list.scrollPane ~= nil) then
        posY = self.list.scrollPane.posY
    end

    ---@type FairyGUI.TreeNode
    local node = context.data.data
    if (context.type == self.list.onRightClickItem.type) then
        self.onRightClickNode:Call(node)
    else
        self.onClickNode:Call(node)
    end

    if (self.list.scrollPane ~= nil) then
        self.list.scrollPane.posY = posY
        self.list.scrollPane:ScrollToView(node.cell)
    end
end


FairyGUI.TreeNodeCreateCellDelegate = TreeNodeCreateCellDelegate
FairyGUI.TreeNodeRenderDelegate = TreeNodeRenderDelegate
FairyGUI.TreeNodeWillExpandDelegate = TreeNodeWillExpandDelegate
FairyGUI.TreeView = TreeView
return TreeView