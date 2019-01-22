--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2019/1/22 16:22
--

local Class = require('libs.Class')

local Window = FairyGUI.Window
local UIPackage = FairyGUI.UIPackage

---@class FairyGUI_Cases.Widown1:FairyGUI.Window
local Window1 = Class.inheritsFrom("Window1", nil, Window)

function Window1:OnInit()
    self.contentPane = UIPackage.CreateObject('Basics', "WindowA")
    self:Center()
end

function Window1:OnShown()
    ---@type FairyGUI.GList
    local list = self.contentPane:GetChild("n6");
    list:RemoveChildrenToPool()

    for i = 1, 6 do
        ---@type FairyGUI.GButton
        local item = list:AddItemFromPool()
        item.title = "" .. i
        item.icon = UIPackage.GetItemByURL("Basics", "r4")
    end
end

FairyGUI_Cases.Window1 = FairyGUI_Cases
return Window1