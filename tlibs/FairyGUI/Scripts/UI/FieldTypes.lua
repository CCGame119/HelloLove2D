--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 14:30
--

---@class FairyGUI.PackageItemType:enum
local PackageItemType = {
    Image = 0,
    MovieClip = 1,
    Sound = 2,
    Component = 3,
    Atlas = 4,
    Font = 5,
    Swf = 6,
    Misc = 7,
    Unknown = 8
}
---@class FairyGUI.ObjectType:enum
local ObjectType = {
    Image = 0,
    MovieClip = 1,
    Swf = 2,
    Graph = 3,
    Loader = 4,
    Group = 5,
    Text = 6,
    RichText = 7,
    InputText = 8,
    Component = 9,
    List = 10,
    Label = 11,
    Button = 12,
    ComboBox = 13,
    ProgressBar = 14,
    Slider = 15,
    ScrollBar = 16
}
---@class FairyGUI.AlignType:enum
local AlignType = {
    Left = 0,
    Center = 1,
    Right = 2
}
---@class FairyGUI.VertAlignType:enum
local VertAlignType = {
    Top = 0,
    Middle = 1,
    Bottom = 2
}
---@class FairyGUI.OverflowType:enum
local OverflowType = {
    Visible = 0,
    Hidden = 1,
    Scroll = 2
}
---@class FairyGUI.FillType:enum
local FillType = {
    None = 0,
    Scale = 1,
    ScaleMatchHeight = 2,
    ScaleMatchWidth = 3,
    ScaleFree = 4,
    ScaleNoBorder = 5
}
---@class FairyGUI.AutoSizeType:enum
local AutoSizeType = {
    None = 0,
    Both = 1,
    Height = 2,
    Shrink = 3
}
---@class FairyGUI.ScrollType:enum
local ScrollType = {
    Horizontal = 0,
    Vertical = 1,
    Both = 2
}
---@class FairyGUI.ScrollBarDisplayType:enum
local ScrollBarDisplayType = {
    Default = 0,
    Visible = 1,
    Auto = 2,
    Hidden = 3
}
---@class FairyGUI.RelationType:enum
local RelationType = {
    Left_Left = 0,
    Left_Center = 1,
    Left_Right = 2,
    Center_Center = 3,
    Right_Left = 4,
    Right_Center = 5,
    Right_Right = 6,

    Top_Top = 7,
    Top_Middle = 8,
    Top_Bottom = 9,
    Middle_Middle = 10,
    Bottom_Top = 11,
    Bottom_Middle = 12,
    Bottom_Bottom = 13,

    Width = 14,
    Height = 15,

    LeftExt_Left = 16,
    LeftExt_Right = 17,
    RightExt_Left = 18,
    RightExt_Right = 19,
    TopExt_Top = 20,
    TopExt_Bottom = 21,
    BottomExt_Top = 22,
    BottomExt_Bottom = 23,

    Size = 24
}
---@class FairyGUI.ListLayoutType:enum
local ListLayoutType = {
    SingleColumn = 0,
    SingleRow = 1,
    FlowHorizontal = 2,
    FlowVertical = 3,
    Pagination = 4
}
---@class FairyGUI.ListSelectionMode:enum
local ListSelectionMode = {
    Single = 0,
    Multiple = 1,
    Multiple_SingleClick = 2,
    None = 3
}
---@class FairyGUI.ProgressTitleType:enum
local ProgressTitleType = {
    Percent = 0,
    ValueAndMax = 1,
    Value = 2,
    Max = 3
}
---@class FairyGUI.ButtonMode:enum
local ButtonMode = {
    Common = 0,
    Check = 1,
    Radio = 2
}
---@class FairyGUI.TransitionActionType:enum
local TransitionActionType = {
    XY = 0,
    Size = 1,
    Scale = 2,
    Pivot = 3,
    Alpha = 4,
    Rotation = 5,
    Color = 6,
    Animation = 7,
    Visible = 8,
    Sound = 9,
    Transition = 10,
    Shake = 11,
    ColorFilter = 12,
    Skew = 13,
    Text = 14,
    Icon = 15,
    Unknown = 16
}
---@class FairyGUI.GroupLayoutType:enum
local GroupLayoutType = {
    None = 0,
    Horizontal = 1,
    Vertical = 2
}
---@class FairyGUI.ChildrenRenderOrder:enum
local ChildrenRenderOrder = {
    Ascent = 0,
    Descent = 1,
    Arch = 2,
}
---@class FairyGUI.PopupDirection:enum
local PopupDirection = {
    Auto = 0,
    Up = 1,
    Down = 2
}

FairyGUI.PackageItemType = PackageItemType
FairyGUI.ObjectType = ObjectType
FairyGUI.AlignType = AlignType
FairyGUI.VertAlignType = VertAlignType
FairyGUI.OverflowType = OverflowType
FairyGUI.FillType = FillType
FairyGUI.AutoSizeType = AutoSizeType
FairyGUI.ScrollType = ScrollType
FairyGUI.ScrollBarDisplayType = ScrollBarDisplayType
FairyGUI.RelationType = RelationType
FairyGUI.ListLayoutType = ListLayoutType
FairyGUI.ListSelectionMode = ListSelectionMode
FairyGUI.ProgressTitleType = ProgressTitleType
FairyGUI.ButtonMode = ButtonMode
FairyGUI.TransitionActionType = TransitionActionType
FairyGUI.GroupLayoutType = GroupLayoutType
FairyGUI.ChildrenRenderOrder = ChildrenRenderOrder
FairyGUI.PopupDirection = PopupDirection