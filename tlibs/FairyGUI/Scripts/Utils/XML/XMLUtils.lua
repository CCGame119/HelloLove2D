--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/24 11:35
--

local Class = require('libs.Class')

---@class Utils.XMLUtils:ClassType
local XMLUtils = Class.inheritsFrom('XMLUtils')

function XMLUtils.DecodeString(aSource)
    local len = #aSource
    local sb = ''
    local pos1, pos2 = 1, 1

    while true do
        pos2 = string.find(aSource, '&', pos1, true)
        if nil == pos2 then
            sb = sb .. string.sub(aSource, pos1)
            break
        end
        sb = sb .. string.sub(aSource, pos1, pos2 - 1)

        pos1 = pos2 + 1
        pos2 = pos1
        local _end = math.min(len, pos2 + 10)
        while pos2 < _end do
            if aSource[pos2] == ';' then
                break
            end
            pos2 = pos2 + 1
        end
        if pos2 < _end and pos2 > pos1 then
            local entity = string.sub(aSource, pos1, pos2 - 1)
            local u = 0
            if entity[1] == '#' then
                if #entity > 1 then
                    if entity[2] == 'x' then
                        u = tonumber(string.sub(entity, 3), 16)
                    else
                        u = tonumber(string.sub(entity, 2))
                    end
                    sb = sb .. string.char(u)
                    pos1 = pos2 + 1
                else
                    sb = sb .. '&'
                end
            else
                if entity == 'amp' then
                    u = 38
                elseif entity == 'apos' then
                    u = 39
                elseif entity == 'gt' then
                    u = 62
                elseif entity == 'lt' then
                    u = 60
                elseif entity == 'nbsp' then
                    u = 32
                elseif entity == 'quot' then
                    u = 34
                end

                if u > 0 then
                    sb = sb .. string.char(u)
                    pos1 = pos2 + 1
                else
                    sb = sb .. '&'
                end
            end
        else
            sb = sb .. '&'
        end
    end
    return sb
end

---@param str string
function XMLUtils.EncodeString(str)
    if str == nil or string.len(str) == 0 then
        return ''
    end
    str = string.gsub(str, '&', '&amp;')
    str = string.gsub(str, '<', '&lt;')
    str = string.gsub(str, '>', '&gt;')
    str = string.gsub(str, "'", '&apos;')
    return str
end

Utils.XMLUtils = XMLUtils
return XMLUtils