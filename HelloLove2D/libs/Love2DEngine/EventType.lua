--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/11/5 11:39
--

---@class Love2DEngine.EventType:enum
local EventType = {
    MouseDown = 0,
    MouseUp = 1,
    MouseMove = 2,
    MouseDrag = 3,
    KeyDown = 4,
    KeyUp = 5,
    ScrollWheel = 6,
    Repaint = 7,
    Layout = 8,
    DragUpdated = 9,
    DragPerform = 10, -- 0x0000000A
    Ignore = 11, -- 0x0000000B
    Used = 12, -- 0x0000000C
    ValidateCommand = 13, -- 0x0000000D
    ExecuteCommand = 14, -- 0x0000000E
    DragExited = 15, -- 0x0000000F
    ContextClick = 16, -- 0x00000010
    MouseEnterWindow = 20, -- 0x00000014
    MouseLeaveWindow = 21, -- 0x00000015
}

Love2DEngine.EventType = EventType
return EventType