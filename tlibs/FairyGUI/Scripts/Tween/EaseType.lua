--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 19:37
--

---@class FairyGUI.EaseType:enum
local EaseType = {
    Linear = 0 ,
    SineIn = 1 ,
    SineOut = 2 ,
    SineInOut = 3 ,
    QuadIn = 4 ,
    QuadOut = 5 ,
    QuadInOut = 6 ,
    CubicIn = 7 ,
    CubicOut = 8 ,
    CubicInOut = 9 ,
    QuartIn = 10,
    QuartOut = 11,
    QuartInOut = 12,
    QuintIn = 13,
    QuintOut = 14,
    QuintInOut = 15,
    ExpoIn = 16,
    ExpoOut = 17,
    ExpoInOut = 18,
    CircIn = 19,
    CircOut = 20,
    CircInOut = 21,
    ElasticIn = 22,
    ElasticOut = 23,
    ElasticInOut = 24,
    BackIn = 25,
    BackOut = 26,
    BackInOut = 27,
    BounceIn = 28,
    BounceOut = 29,
    BounceInOut = 30,
    Custom = 31,
}

FairyGUI.EaseType = EaseType
return EaseType