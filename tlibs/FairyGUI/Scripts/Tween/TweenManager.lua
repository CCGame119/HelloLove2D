--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 19:35
--

local Class = require('libs.Class')
local Pool = require('libs.Pool')

local Object = Love2DEngine.Object
local GameObject = Love2DEngine.GameObject
local HideFlags = Love2DEngine.HideFlags
local LuaBehaviour = Love2DEngine.LuaBehaviour
local GTweener = FairyGUI.GTweener
local TweenPropType = FairyGUI.TweenPropType


---@class FairyGUI.TweenManager:ClassType
local TweenManager = Class.inheritsFrom('TweenManager')
local m = TweenManager

---@type FairyGUI.GTweener[]
TweenManager._activeTweens = {}
---@type Pool
TweenManager._tweenerPool = Pool.new(GTweener)
TweenManager._totalActiveTweens = 0
TweenManager._inited = false

---@return FairyGUI.GTweener
function TweenManager.CreateTween()
    if not m._inited then
        m.Init()
    end

    ---@type FairyGUI.GTweener
    local tweener = m._tweenerPool:pop()
    tweener:_Init()
    m._totalActiveTweens = m._totalActiveTweens + 1
    m._activeTweens[m._totalActiveTweens] = tweener

    return tweener
end

---@param target any
---@param propType FairyGUI.TweenPropType
---@return boolean
function TweenManager.IsTweening(target, propType)
    if nil == target then
        return false
    end

    local anyType = propType == TweenPropType.None
    for i = 1, m._totalActiveTweens do
        local tweener = m._activeTweens[i]
        if tweener ~= nil and tweener.target == target and not tweener._killed
            and (anyType or tweener._propType == propType) then
            return true
        end
    end
    return false
end

---@param target any
---@param propType
---@param completed
---@return boolean
function TweenManager.KillTweens(target, propType, completed)
    if nil == target then
        return false
    end
    local flag = false
    local anyType = propType == TweenPropType.None
    for i = 1, m._totalActiveTweens do
        local tweener = m._activeTweens[i]
        if tweener ~= nil and tweener.target == target and not tweener._killed
                and (anyType or tweener._propType == propType) then
             tweener:Kill(completed)
            flag = true
        end
    end
    return flag
end

---@param target any
---@param propType
---@return FairyGUI.GTweener
function TweenManager.GetTween(target, propType)
    if nil == target then
        return false
    end

    local anyType = propType == TweenPropType.None
    for i = 1, m._totalActiveTweens do
        local tweener = m._activeTweens[i]
        if tweener ~= nil and tweener.target == target and not tweener._killed
                and (anyType or tweener._propType == propType) then
            return tweener
        end
    end
    return nil
end

function TweenManager.Update()
    local cnt = m._totalActiveTweens
    local freePosStart = -1
    local freePosCount = 0
    for i = 1, cnt do
        local tweener = m._activeTweens[i]
        if tweener == nil then
            if freePosStart == -1 then
                freePosStart = i
            end
            freePosCount = freePosCount + 1
        elseif tweener._killed then
            tweener:_Reset()
            m._tweenerPool:push(tweener)
            m._activeTweens[i] = nil

            if freePosStart == -1 then
                freePosStart = i
            end
            freePosCount = freePosCount + 1
        else
            if not tweener._paused then
                tweener:_Update()
            end
            if freePosStart ~= -1 then
                m._activeTweens[freePosStart] = tweener
                m._activeTweens[i] = nil
                freePosCount = freePosCount + 1
            end
        end
    end

    if freePosStart >= 0 then
        if m._totalActiveTweens ~= cnt  then
            local j = cnt
            cnt = m._totalActiveTweens - cnt
            for i = 1, cnt do

                m._activeTweens[freePosStart] = m._activeTweens[j]
                freePosStart = freePosStart + 1
                j = j + 1
            end
        end
        m._totalActiveTweens = freePosStart
    end
end

function TweenManager.Clean()
    m._tweenerPool:clear()
end

function TweenManager.Init()
    local TweenEngine = FairyGUI.TweenEngine
    m._inited = true
    local gameObject = GameObject.new("[FairyGUI.TweenManager]")
    gameObject.hideFlags = HideFlags.HideInHierarchy
    gameObject:SetActive(true)

    gameObject.AddComponent(TweenEngine)
end

---@class Love2DEngine.TweenPropType:Love2DEngine.LuaBehaviour
local TweenEngine = Class.inheritsFrom('TweenEngine', nil, LuaBehaviour)

function TweenEngine:Update()
    TweenManager.Update()
end

FairyGUI.TweenManager = TweenManager
FairyGUI.TweenEngine = TweenEngine
return TweenManager