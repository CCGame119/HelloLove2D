--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/31 11:15
--

local Class = require('libs.Class')

---@class FairyGUI.IKeyBoard:ClassType
---@field public done boolean
---@field public supportsCaret boolean @是否支持在光标处输入。如果为true，GetInput返回的是在当前光标处需要插入的文本，如果为false，GetInput返回的是整个文本。
local IKeyboard = Class.inheritsFrom('IKeyboard')

---用户输入的文本。
---@return string
function IKeyBoard:GetInput() end

---打开键盘
---@param text string
---@param autocorrection boolean
---@param multiline boolean
---@param secure boolean
---@param alert boolean
---@param textPlaceholder string
---@param keyboardType number
---@param hideInput boolean
function IKeyBoard:Open(text, autocorrection, multiline, secure, alert, textPlaceholder, keyboardType, hideInput) end

---关闭键盘
function IKeyBoard:Close() end


FairyGUI.IKeyBoard = IKeyBoard
return IKeyBoard