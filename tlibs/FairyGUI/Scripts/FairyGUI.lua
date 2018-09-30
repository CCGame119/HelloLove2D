--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 11:32
--

---@class FairyGUI
FairyGUI = {name='FairyGUI'}

FairyGUI.EventModifiers = {
    None = 0,
    Shift = 1,
    Control = 2,
    Alt = 4,
    Command = 8,
    Numeric = 16, // 0x00000010
    CapsLock = 32, // 0x00000020
    FunctionKey = 64, // 0x00000040
}

return FairyGUI