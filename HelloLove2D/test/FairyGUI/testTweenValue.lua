--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 15:05
--

local TweenValue = FairyGUI.TweenValue

local val = TweenValue.new()
function FairyGUI_Cases.TweenValue_calse()
    for i = 1, 4 do
        val[i] = i*i
        print(val[i])
    end
end