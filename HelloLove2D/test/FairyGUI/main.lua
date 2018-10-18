--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/11 13:52
--
FairyGUI_Cases = {}

require('libs.Love2DEngine.Love2DEngine')
require('libs.utils.package_ex')
package.addSearchPath("/tlibs/FairyGUI/Scripts/?.lua")
require('FairyGUI')

local callback0 = FairyGUI.EventCallback0.new()

function FairyGUI_Cases.EventCallback0_case(func, obj)
    callback0:Add(func, obj)
end

FairyGUI_Cases.callback0 = callback0
return FairyGUI_Cases