--[[
// Author: Daniele Giardini - http://www.demigiant.com
// Created: 2014/07/19 14:11
//
// License Copyright (c) Daniele Giardini.
// This work is subject to the terms at http://dotween.demigiant.com/license.php
//
// =============================================================
// Contains Daniele Giardini's C# port of the easing equations created by Robert Penner
// (all easing equations except for Flash, InFlash, OutFlash, InOutFlash,
// which use some parts of Robert Penner's equations but were created by Daniele Giardini)
// http://robertpenner.com/easing, see license below:
// =============================================================
//
// TERMS OF USE - EASING EQUATIONS
//
// Open source under the BSD License.
//
// Copyright ? 2001 Robert Penner
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// - Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// - Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// - Neither the name of the author nor the names of contributors may be used to endorse
// or promote products derived from this software without specific prior written permission.
// - THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 19:39
--

local Class = require('libs.Class')

local EaseType = FairyGUI.EaseType

---@class FairyGUI.EaseManager:ClassType
---@field private _PiOver2 number
---@field private _TwoPi number
local EaseManager = Class.inheritsFrom('EaseManager')

EaseManager._PiOver2 = math.pi * 0.5
EaseManager._TwoPi = math.pi * 2



function EaseManager.Evaluate(easeType, time, duration, overshootOrAmplitude, period)
    if easeType == EaseType.Linear then
        return time / duration
    elseif easeType == EaseType.SineIn then
        return -math.cos(time / duration * EaseManager._PiOver2) + 1
    elseif easeType == EaseType.SineOut then
        return math.sin(time / duration * EaseManager._PiOver2)
    elseif easeType == EaseType.SineInOut then
        return -0.5 * (math.cos(math.pi * time / duration) - 1)
    elseif easeType == EaseType.QuadIn then
        time = time / duration
        return time * time
    elseif easeType == EaseType.QuadOut then
        time = time / duration
        return -time * (time - 2)
    elseif easeType == EaseType.QuadInOut then
        time = time / duration * 0.5
        if time < 1 then
            return 0.5 * time * time
        end
        time = time - 1
        return -0.5 * (time * (time - 2) - 1)
    elseif easeType == EaseType.CubicIn then
        time = time / duration
        return time * time * time
    elseif easeType == EaseType.CubicOut then
        time = time / duration - 1
        return (time * time * time + 1)
    elseif easeType == EaseType.CubicInOut then
        time = time / duration * 0.5
        if time < 1 then
            return 0.5 * time * time * time
        end
        time = time - 2
        return 0.5 * (time * time * time + 2)
    elseif easeType == EaseType.QuartIn then
        time = time / duration
        return time * time * time * time
    elseif easeType == EaseType.QuartOut then
        time = time / duration
        return -((time - 1) * time * time * time - 1)
    elseif easeType == EaseType.QuartInOut then
        time = time / duration * 0.5
        if time < 1 then
            return 0.5 * time * time * time * time
        end
        time = time - 2
        return -0.5 * (time * time * time * time - 2)
    elseif easeType == EaseType.QuintIn then
        time = time / duration
        return time * time * time * time * time
    elseif easeType == EaseType.QuintOut then
        time = time / duration
        return ((time - 1) * time * time * time * time + 1)
    elseif easeType == EaseType.QuintInOut then
        time = time / duration * 0.5
        if time < 1 then
            return 0.5 * time * time * time * time * time
        end
        time = time - 2
        return 0.5 * (time * time * time * time * time + 2)
    elseif easeType == EaseType.ExpoIn then
        return time == 0 and 0 or math.pow(2, 10 * (time / duration - 1))
    elseif easeType == EaseType.ExpoOut then
        if time == duration then return 1 end
        return (-math.pow(2, -10 * time / duration) + 1)
    elseif easeType == EaseType.ExpoInOut then
        if time == 0 then return 0 end
        if time == duration then return 1 end
        time = time / duration * 0.5
        if time < 1 then
            return 0.5 * math.pow(2, 10 * (time - 1))
        end
        time = time - 1
        return 0.5 * (-math.pow(2, -10 * time) + 2)
    elseif easeType == EaseType.CircIn then
        time = time / duration
        return -(math.sqrt(1 - time * time) - 1)
    elseif easeType == EaseType.CircOut then
        time = time / duration - 1
        return math.sqrt(1 - time * time)
    elseif easeType == EaseType.CircInOut then
        time = time / duration * 0.5
        if time < 1 then
            return -0.5 * (math.sqrt(1 - time * time) - 1)
        end
        time = time - 2
        return 0.5 * (math.sqrt(1 - time * time) + 1)
    elseif easeType == EaseType.ElasticIn then
        local s0
        if time == 0 then return 0 end
        time = time / duration
        if time == 1 then return 1 end
        if period == 0 then period = duration * 0.3 end
        if overshootOrAmplitude < 1 then
            overshootOrAmplitude = 1
            s0 = period / 4
        else
            s0 = period / EaseManager._TwoPi * math.asin(1 / overshootOrAmplitude)
        end
        time = time - 1
        return -(overshootOrAmplitude * math.pow(2, 10 * time) * math.sin((time * duration - s0) * EaseManager._TwoPi / period))
    elseif easeType == EaseType.ElasticOut then
        local s1
        if time == 0 then return 0 end
        time = time / duration
        if time == 1 then return 1 end
        if period == 0 then period = duration * 0.3 end
        if overshootOrAmplitude < 1 then
            overshootOrAmplitude = 1
            s1 = period / 4
        else
            s1 = period / EaseManager._TwoPi * math.asin(1 / overshootOrAmplitude)
        end
        return (overshootOrAmplitude * math.pow(2, -10 * time) * math.sin((time * duration - s1) * EaseManager._TwoPi / period) + 1)
    elseif easeType == EaseType.ElasticInOut then
        local s
        if time == 0 then return 0 end
        time = time / duration * 0.5
        if time == 2 then return 1 end
        if period == 0 then period = duration * (0.3 * 1.5) end
        if overshootOrAmplitude < 1 then
            overshootOrAmplitude = 1
            s = period / 4
        else
            s = period / EaseManager._TwoPi * math.asin(1 / overshootOrAmplitude)
        end
        if time < 1 then
            time = time - 1
            return -0.5 * (overshootOrAmplitude * math.pow(2, 10 * time) * math.sin((time * duration - s) * EaseManager._TwoPi / period))
        end
        time = time - 1
        return overshootOrAmplitude * math.pow(2, -10 *  time) * math.sin((time * duration - s) * EaseManager._TwoPi / period) * 0.5 + 1
    elseif easeType == EaseType.BackIn then
        time = time / duration
        return time * time * ((overshootOrAmplitude + 1) * time - overshootOrAmplitude)
    elseif easeType == EaseType.BackOut then
        time = time / duration
        return ((time - 1) * time * ((overshootOrAmplitude + 1) * time + overshootOrAmplitude) + 1)
    elseif easeType == EaseType.BackInOut then
        time = time / duration * 0.5
        if time < 1 then
            overshootOrAmplitude = overshootOrAmplitude * 1.5
            return 0.5 * (time * time * ((overshootOrAmplitude  + 1) * time - overshootOrAmplitude))
        end
        time = time - 2
        overshootOrAmplitude = overshootOrAmplitude * 1.5
        return 0.5 * (time * time * ((overshootOrAmplitude + 1) * time + overshootOrAmplitude) + 2)
    elseif easeType == EaseType.BounceIn then
        return Bounce.EaseIn(time, duration)
    elseif easeType == EaseType.BounceOut then
        return Bounce.EaseOut(time, duration)
    elseif easeType == EaseType.BounceInOut then
        return Bounce.EaseInOut(time, duration)
    else
        time = time / duration
        return -time * (time - 2)
    end
end

local Bounce = Class.inheritsFrom('Bounce')

---@param time number
---@param duration number
---@return number
function Bounce.EaseIn(time, duration)
    return 1 - Bounce.EaseOut(duration - time, duration)
end

---@param time number
---@param duration number
---@return number
function Bounce.EaseOut(time, duration)
    time = time / duration
    if time < (1 / 2.75) then
        return (7.5625 * time * time)
    end
    if time < (2 / 2.75) then
        time = time - (1.5 / 2.75)
        return (7.5625 * time * time + 0.75)
    end
    if time < (2.5 / 2.75) then
        time = time - (2.25 / 2.75)
        return (7.5625 * time * time + 0.9375)
    end
    time = time - (2.625 / 2.75)
    return (7.5625 * time * time + 0.984375)
end

---@param time number
---@param duration number
---@return number
function Bounce.EaseInOut(time, duration)
    if time < duration * 0.5 then
        return Bounce.EaseIn(time * 2, duration) * 0.5
    end
    return Bounce.EaseOut(time * 2 - duration, duration) * 0.5 + 0.5
end


FairyGUI.EaseManager = EaseManager
FairyGUI.Bounce = Bounce
return EaseManager