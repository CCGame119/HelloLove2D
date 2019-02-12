--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 12:06
--

local Class = require('libs.Class')

local Behaviour = Love2DEngine.Behaviour
local Transform = Love2DEngine.Transform

---@class Love2DEngine.LuaBehaviour:Love2DEngine.Behaviour
---@field public scriptName string @脚本名称
local LuaBehaviour = Class.inheritsFrom('LuaBehaviour', nil, Behaviour)

function LuaBehaviour:Awake() end
function LuaBehaviour:Start() end
function LuaBehaviour:OnEnable() end
function LuaBehaviour:OnDisable() end
function LuaBehaviour:LateUpdate() end
function LuaBehaviour:Update() end
function LuaBehaviour:FixedUpdate() end
function LuaBehaviour:OnGUI() end
function LuaBehaviour:OnApplicationQuit() end

---@param routine fun():thread
function LuaBehaviour:StartCoroutine(routine)
    local  co = coroutine.create(routine)
    coroutine.resume(co)
    return co
end

function LuaBehaviour.UpdateBehaviours(dt)
    LuaBehaviour.__UpdateBehaviours(Transform.root, dt)
end

---@param transform Love2DEngine.Transform
function LuaBehaviour.__UpdateBehaviours(transform, dt)
    for i, trans in ipairs(transform.childs) do
        local go = trans.gameObject
        if go.active then
            for _, behaviour in pairs(go._luaBehaviours) do
                if behaviour.enabled then
                    if not behaviour.isActiveAndEnabled then
                        behaviour:OnEnable()
                        behaviour.isActiveAndEnabled = true
                    else
                        behaviour:Update()
                        behaviour:FixedUpdate()
                    end
                else
                    if behaviour.isActiveAndEnabled then
                       behaviour:OnDisable()
                       behaviour.isActiveAndEnabled = false
                    end
                end
            end

            for _, behaviour in pairs(go._luaBehaviours) do
                if behaviour.enabled and behaviour.isActiveAndEnabled then
                    behaviour:LateUpdate()
                end
            end
        end
        --LuaBehaviour.__UpdateBehaviours(go.transform)
    end
end

--TODO: Love2DEngine.LuaBehaviour

local __get = Class.init_get(LuaBehaviour)

---@param self Love2DEngine.LuaBehaviour
__get.scriptName = function(self)
    return self:clsName()
end

Love2DEngine.LuaBehaviour = LuaBehaviour
return LuaBehaviour