--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 19:41
--

local Class = require('libs.Class')

---@class FairyGUI.TreeNode:ClassType
---@field public data any
---@field public parent FairyGUI.TreeNode
---@field public tree FairyGUI.TreeView
---@field public cell FairyGUI.GComponent
---@field public level number
---@field public expanded boolean
---@field public isFolder boolean
---@field public text string
---@field public numChildren number
---@field private _children FairyGUI.TreeNode[]
---@field private _expanded boolean
local TreeNode = Class.inheritsFrom('TreeNode')

function TreeNode:__ctor(hasChild)
    if hasChild then
        self._children = {}
    end
end

---@param child FairyGUI.TreeNode
---@return FairyGUI.TreeNode
function TreeNode:AddChild(child)
    self:AddChildAt(child, #self._children)
    return child
end

---@param child FairyGUI.TreeNode
---@param index number
---@return FairyGUI.TreeNode
function TreeNode:AddChild(child, index)
    if child == nil then
        error('child is nil')
    end
    local numChildren = #self._children
    if index >= 0 and index <= numChildren + 1 then
        if child.parent == self then
            self:SetChildIndex(child, index)
        else
            if child.parent ~= nil then
                child.parent:RemoveChild(child)
            end
            table.insert(self._children, index, child)
            child.parent = self
            child.level = self.level + 1
            child:SetTree(self.tree)
            if self.cell ~= nil and self.cell.parent ~= nil and self._expanded then
                self.tree:AfterInsert(child)
            end
        end
        return child
    else
        error("Invalid child index")
    end
    return child
end

---@param child FairyGUI.TreeNode
---@return FairyGUI.TreeNode
function TreeNode:RemoveChild(child)
    local childIndex = self._children:indexOf(child)
    if -1 ~= childIndex then
        self:RemoveChildAt(childIndex)
    end
    return child
end

---@param index number
---@return FairyGUI.TreeNode
function TreeNode:RemoveChildAt(index)
    if index >= 1 and index <= self.numChildren then
        local child = self._children[index]
        table.remove(self._children, index)
        child.parent = nil
        if self.tree ~= nil then
            child:SetTree(nil)
            self.tree:AfterRemoved(child)
        end
        return child
    end
    error("Invalid child index")
end

---@param beginIndex number
---@param endIndex number
function TreeNode:RemoveChildren(beginIndex, endIndex)
    endIndex = endIndex or -1
    if endIndex < 1 or endIndex > self.numChildren then
        endIndex = self.numChildren
    end
    for i = beginIndex, endIndex do
        self:RemoveChildAt(beginIndex)
    end
end

---@param index number
---@return FairyGUI.TreeNode
function TreeNode:GetChildAt(index)
    if index >= 1 and index <= self.numChildren then
        return self._children[index]
    end
    error("Invalid child index")
end

---@param child FairyGUI.TreeNode
---@return number
function TreeNode:GetChildIndex(child)
    return self._children:indexOf(child)
end

---@return FairyGUI.TreeNode
function TreeNode:GetPrevSibling()
    if self.parent == nil then
        return nil
    end

    local i = self.parent._children:indexOf(self)
    if i <= 1 then
        return nil
    end

    return self.parent._children[i - 1]
end

---@return FairyGUI.TreeNode
function TreeNode:GetNextSibling()
    if self.parent == nil then
        return nil
    end

    local i = self.parent._children:indexOf(self)
    if i < 1 or i >= #(self.parent._children) then
        return nil
    end

    return self.parent._children[i + 1]
end

---@param child FairyGUI.TreeNode
---@param index number
function TreeNode:SetChildIndex(child, index)
    local oldIndex = self._children:indexOf(child)
    if oldIndex == -1 then
        error("Not a child of this container")
    end

    local cnt = #self._children
    if index < 0 then
        index = 0
    elseif index > cnt then
        index = cnt
    end

    if oldIndex == index then
        return
    end
    table.remove(self._children, oldIndex)
    table.insert(self._children, index, child)
    if self.cell ~= nil and self.cell.parent ~= nil and self._expanded then
        self.tree:AfterMoved(child)
    end
end

---@param child1 FairyGUI.TreeNode
---@param child2 FairyGUI.TreeNode
function TreeNode:SwapChildren(child1, child2)
    local index1, index2 = self._children:indexOf(child1), self._children:indexOf(child2)
    if index1 == -1 or index2 == -1 then
        error("Not a child of this container")
    end
    self:SwapChildrenAt(index1, index2)
end

---@param index1 number
---@param index2 number
function TreeNode:SwapChildrenAt(index1, index2)
    local child1, child2 = self._children[index1], self._children[index2]
    self:SetChildIndex(child1, index2)
    self:SetChildIndex(child2, index1)
end

---@param tree FairyGUI.TreeView
function TreeNode:SetTree(tree)
    self.tree = tree
    if nil ~= tree and tree.treeNodeWillExpand ~= nil and self._expanded then
        tree.treeNodeWillExpand(self, true)
    end

    if self._children ~= nil then
        for i = 1, #self._children do
            local node = self._children[i]
            node.level = self.level + 1
            node:SetTree(tree)
        end
    end
end


local __get = Class.init_get(TreeNode)
local __set = Class.init_set(TreeNode)

---@param self FairyGUI.TreeNode
__get.expanded = function(self) return self._expanded end
---@param self FairyGUI.TreeNode
---@param val boolean
__set.expanded = function(self, val)
    if self._children == nil then return end
    if self._expanded == val then return end
    self._expanded = val
    if self.tree == nil then return end

    if self._expanded then
        self.tree:AfterExpanded(self)
    else
        self.tree:AfterCollapsed(self)
    end
end

---@param self FairyGUI.TreeNode
__get.isFolder = function(self) return self._children ~= nil end

---@param self FairyGUI.TreeNode
__get.text = function(self)
    if self.cell ~= nil then
        return self.cell.text
    end
    return nil
end

---@param self FairyGUI.TreeNode
__get.numChildren = function(self) return self._children == nil and 0 or #self._children end


FairyGUI.TreeNode = TreeNode
return TreeNode