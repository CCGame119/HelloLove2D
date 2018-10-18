--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/16 11:23
--

local Class = require('libs.Class')

local NGraphics = FairyGUI.NGraphics

---@class FairyGUI.FillMethod:enum
local FillMethod = {
    None = 0,
    -- The Image will be filled Horizontally
    Horizontal = 1,
    -- The Image will be filled Vertically.
    Vertical = 2,
    -- The Image will be filled Radially with the radial center in one of the corners.
    Radial90 = 3,
    -- The Image will be filled Radially with the radial center in one of the edges.
    Radial180 = 4,
    -- The Image will be filled Radially with the radial center at the center.
    Radial360 = 5,
}

---@class FairyGUI.OriginHorizontal:enum
local OriginHorizontal = {Left = 0, Right = 1}

---@class FairyGUI.OriginVertical:enum
local OriginVertical = {Top = 0, Bottom = 1}

---@class FairyGUI.Origin90:enum
local Origin90 = {TopLeft = 0, TopRight = 1, BottomLeft = 2, BottomRight = 3}

---@class FairyGUI.Origin180:enum
local Origin180 = {Top = 0, Bottom = 1, Left = 2, Right = 3}

---@class FairyGUI.Origin360:enum
local Origin360 = {Top = 0, Bottom = 1, Left = 2, Right = 3}

---@class FairyGUI.FillUtils:ClassType
local FillUtils = Class.inheritsFrom('FillUtils')

---@param origin FairyGUI.OriginHorizontal
---@param amount number
---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param verts Love2DEngine.Vector3[]
---@param uv Love2DEngine.Vector2[]
function FillUtils.FillHorizontal(origin, amount, vertRect, uvRect, verts, uv)
    if (origin == OriginHorizontal.Left) then
        vertRect.width = vertRect.width * amount
        uvRect.width = uvRect.width * amount
    else
        vertRect.x = vertRect.x + vertRect.width * (1 - amount);
        vertRect.width = vertRect.width * amount;
        uvRect.x = uvRect.x + uvRect.width * (1 - amount);
        uvRect.width = uvRect.width * amount;
    end

    NGraphics.FillVertsOfQuad(verts, 1, vertRect);
    NGraphics.FillUVOfQuad(uv, 1, uvRect);
end

---@param origin FairyGUI.OriginVertical
---@param amount number
---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param verts Love2DEngine.Vector3[]
---@param uv Love2DEngine.Vector2[]
function FillUtils.FillVertical(origin, amount, vertRect, uvRect, verts, uv)
    if (origin == OriginHorizontal.Bottom) then
        vertRect.y = vertRect.y + vertRect.height * (1 - amount)
        vertRect.height = vertRect.height * amount
        uvRect.height = uvRect.height * amount
    else
        vertRect.height = vertRect.height * amount;
        uvRect.y = uvRect.y + uvRect.height * (1 - amount);
        uvRect.height = uvRect.height * amount;
    end

    NGraphics.FillVertsOfQuad(verts, 1, vertRect);
    NGraphics.FillUVOfQuad(uv, 1, uvRect);
end

---@param origin FairyGUI.Origin90
---@param amount number
---@param clockwise boolean
---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param verts Love2DEngine.Vector3[]
---@param uv Love2DEngine.Vector2[]
function FillUtils.FillRadial90(origin, amount, clockwise, vertRect, uvRect, verts, uv)
    NGraphics.FillVertsOfQuad(verts, 1, vertRect)
    NGraphics.FillUVOfQuad(uv, 1, uvRect)
    if amount < 0.001 then
        verts[1], verts[2], verts[3] = verts[4], verts[4], verts[4]
        uv[1], uv[2], uv[3] = uv[4], uv[4], uv[4]
        return
    end

    if amount > 0.999 then return end

    if origin == Origin90.BottomLeft then
        if clockwise then
            local v = math.tan(math.pi / 2 * (1 - amount))
            local h = vertRect.width * v
            if (h > vertRect.height) then
                local ratio = (h - vertRect.height) / h
                verts[3].x = verts[3].x - vertRect.width * ratio
                verts[4] = verts[3]

                uv[3].x = uv[3].x - uvRect.width * ratio
                uv[4] = uv[3]
            else
                local ratio = h / vertRect.height
                verts[4].y = verts[4].y + h
                uv[4].y = uv[4].y + uvRect.height * ratio
            end
        else
            local v = math.tan(math.pi / 2 * amount)
            local h = vertRect.width * v
            if (h > vertRect.height) then
                local ratio = (h - vertRect.height) / h
                verts[2].x = verts[2].x + vertRect.width * (1 - ratio)
                uv[2].x = uv[2].x + uvRect.width * (1 - ratio)
            else
                local ratio = h / vertRect.height
                verts[3].y = verts[3].y - vertRect.height * (1 - ratio)
                verts[2] = verts[3]

                uv[3].y = uv[3].y - uvRect.height * (1 - ratio)
                uv[2] = uv[3]
            end
        end
    elseif origin == Origin90.BottomRight then
        if clockwise then
            local v = math.tan(math.pi / 2 * amount)
            local h = vertRect.width * v
            if (h > vertRect.height) then
                local ratio = (h - vertRect.height) / h
                verts[3].x = verts[3].x - vertRect.width * (1 - ratio)
                uv[3].x = uv[3].x - uvRect.width * (1 - ratio)
            else
                local ratio = h / vertRect.height
                verts[2].y = verts[1].y - vertRect.height * (1 - ratio)
                verts[3] = verts[4]

                uv[2].y = uv[2].y - uvRect.height * (1 - ratio)
                uv[3] = uv[4]
            end
        else
            local v = math.tan(math.pi / 2 * (1 - amount))
            local h = vertRect.width * v
            if (h > vertRect.height) then
                local ratio = (h - vertRect.height) / h
                verts[2].x = verts[2].x + vertRect.width * ratio
                verts[1] = verts[2]
                uv[2].x = uv[2].x + uvRect.width * ratio
                uv[1] = uv[2]
            else
                local ratio = h / vertRect.height
                verts[1].y = verts[1].y + h
                uv[1].y = uv[1].y + uvRect.height * ratio
            end
        end
    elseif origin == Origin90.TopLeft then
        if clockwise then
            local v = math.tan(math.pi / 2 * amount)
            local h = vertRect.width * v
            if (h > vertRect.height) then
                local ratio = (h - vertRect.height) / h
                verts[1].x = verts[1].x + vertRect.width * (1 - ratio)
                uv[1].x = uv[1].x + uvRect.width * (1 - ratio)
            else
                local ratio = h / vertRect.height
                verts[4].y = verts[4].y + vertRect.height * (1 - ratio)
                verts[1] = verts[4]

                uv[4].y = uv[4].y + uvRect.height * (1 - ratio)
                uv[1] = uv[4]
            end
        else
            local v = math.tan(math.pi / 2 * (1 - amount))
            local h = vertRect.width * v
            if (h > vertRect.height) then
                local ratio = (h - vertRect.height) / h
                verts[4].x = verts[4].x - vertRect.width * ratio
                verts[3] = verts[4]
                uv[4].x = uv[4].x - uvRect.width * ratio
                uv[3] = uv[4]
            else
                local ratio = h / vertRect.height
                verts[3].y = verts[3].y - h
                uv[3].y = uv[3].y - uvRect.height * ratio
            end
        end
    elseif origin == Origin90.TopRight then
        if clockwise then
            local v = math.tan(math.pi / 2 * (1 - amount))
            local h = vertRect.width * v
            if (h > vertRect.height) then
                local ratio = (h - vertRect.height) / h
                verts[1].x = verts[1].x + vertRect.width * ratio
                verts[2] = verts[3]
                uv[1].x = uv[1].x + uvRect.width * ratio
                uv[2] = uv[3]
            else
                local ratio = h / vertRect.height
                verts[2].y = verts[2].y - vertRect.height * ratio;
                uv[2].y = uv[2].y - uvRect.height * ratio;
            end
        else
            local v = math.tan(math.pi / 2 * amount)
            local h = vertRect.width * v
            if (h > vertRect.height) then
                local ratio = (h - vertRect.height) / h
                verts[4].x = verts[4].x - vertRect.width * (1 - ratio)
                uv[4].x = uv[4].x - uvRect.width * (1 - ratio)
            else
                local ratio = h / vertRect.height
                verts[1].y = verts[1].y + vertRect.height * (1 - ratio)
                verts[4] = verts[1]
                uv[1].y = uv[1].y + uvRect.height * (1 - ratio)
                uv[4] = uv[1]
            end
        end
    end
end

---@param origin FairyGUI.Origin180
---@param amount number
---@param clockwise boolean
---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param verts Love2DEngine.Vector3[]
---@param uv Love2DEngine.Vector2[]
function FillUtils.FillRadial180(origin, amount, clockwise, vertRect, uvRect, verts, uv)
    if origin == Origin180.Top then
        if (amount <= 0.5) then
            vertRect.width = vertRect.width / 2
            uvRect.width = uvRect.width / 2
            if clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            end
            amount = amount / 0.5
            FillUtils.FillRadial90(clockwise and Origin90.TopLeft or Origin90.TopRight, amount, clockwise, vertRect, uvRect, verts, uv)
            verts[5], verts[6], verts[7], verts[8] = verts[0], verts[0], verts[0], verts[0]
            uv[5], uv[6], uv[7], uv[8] = uv[0], uv[0], uv[0], uv[0]
        else
            vertRect.width = vertRect.width / 2
            uvRect.width = uvRect.width / 2
            if not clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            end

            amount = (amount - 0.5) / 0.5
            FillUtils.FillRadial90(clockwise and Origin90.TopRight or Origin90.TopLeft, amount, clockwise, vertRect, uvRect, verts, uv)

            if clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            else
                vertRect.x = vertRect.x - vertRect.width
                uvRect.x = uvRect.x - uvRect.width
            end
            NGraphics.FillVertsOfQuad(verts, 5, vertRect)
            NGraphics.FillUVOfQuad(uv, 5, uvRect)
        end
    elseif origin == Origin180.Bottom then
        if (amount <= 0.5) then
            vertRect.width = vertRect.width / 2
            uvRect.width = uvRect.width / 2
            if not clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            end
            amount = amount / 0.5
            FillUtils.FillRadial90(clockwise and Origin90.BottomRight or Origin90.BottomLeft, amount, clockwise, vertRect, uvRect, verts, uv)
            verts[5], verts[6], verts[7], verts[8] = verts[0], verts[0], verts[0], verts[0]
            uv[5], uv[6], uv[7], uv[8] = uv[0], uv[0], uv[0], uv[0]
        else
            vertRect.width = vertRect.width / 2
            uvRect.width = uvRect.width / 2
            if clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            end
            amount = (amount - 0.5) / 0.5
            FillUtils.FillRadial90(clockwise and Origin90.BottomLeft or Origin90.BottomRight, amount, clockwise, vertRect, uvRect, verts, uv)

            if clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            else
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            end
            NGraphics.FillVertsOfQuad(verts, 5, vertRect)
            NGraphics.FillUVOfQuad(uv, 5, uvRect)
        end
    elseif origin == Origin180.Left then
        if (amount <= 0.5) then
            if clockwise then
                vertRect.height = vertRect.height / 2
                uvRect.yMin = uvRect.yMin + uvRect.height / 2
            else
                vertRect.yMin = vertRect.yMin + vertRect.height / 2
                uvRect.yMax = uvRect.yMax - uvRect.height / 2
            end
            amount = amount / 0.5
            FillUtils.FillRadial90(clockwise and Origin90.BottomLeft or Origin90.TopLeft, amount, clockwise, vertRect, uvRect, verts, uv)
            verts[5], verts[6], verts[7], verts[8] = verts[0], verts[0], verts[0], verts[0]
            uv[5], uv[6], uv[7], uv[8] = uv[0], uv[0], uv[0], uv[0]
        else
            if clockwise then
                vertRect.yMin = vertRect.yMin + vertRect.height / 2
                uvRect.yMax = uvRect.yMax - uvRect.height / 2
            else
                vertRect.height = vertRect.height / 2
                uvRect.yMin = uvRect.yMin + uvRect.height / 2
            end
            amount = (amount - 0.5) / 0.5
            FillUtils.FillRadial90(clockwise and Origin90.TopLeft or Origin90.BottomLeft, amount, clockwise, vertRect, uvRect, verts, uv)

            if clockwise then
                vertRect.y = vertRect.y - vertRect.height
                uvRect.y = uvRect.y + uvRect.height
            else
                vertRect.y = vertRect.y + vertRect.height
                uvRect.y = uvRect.y - uvRect.height
            end
            NGraphics.FillVertsOfQuad(verts, 5, vertRect)
            NGraphics.FillUVOfQuad(uv, 5, uvRect)
        end
    elseif origin == Origin180.Right then
        if (amount <= 0.5) then
            if clockwise then
                vertRect.yMin = vertRect.yMin + vertRect.height / 2
                uvRect.yMax = uvRect.yMax - uvRect.height / 2
            else
                vertRect.height = vertRect.height / 2
                uvRect.yMin = uvRect.yMin + uvRect.height / 2
            end
            amount = amount / 0.5
            FillUtils.FillRadial90(clockwise and Origin90.TopRight or Origin90.BottomRight, amount, clockwise, vertRect, uvRect, verts, uv)
            verts[5], verts[6], verts[7], verts[8] = verts[0], verts[0], verts[0], verts[0]
            uv[5], uv[6], uv[7], uv[8] = uv[0], uv[0], uv[0], uv[0]
        else
            if clockwise then
                vertRect.height = vertRect.height / 2
                uvRect.yMin = uvRect.yMin + uvRect.height / 2
            else
                vertRect.yMin = vertRect.yMin + vertRect.height / 2
                uvRect.yMax = uvRect.yMax - uvRect.height / 2
            end
            amount = (amount - 0.5) / 0.5
            FillUtils.FillRadial90(clockwise and Origin90.BottomRight or Origin90.TopRight, amount, clockwise, vertRect, uvRect, verts, uv)

            if clockwise then
                vertRect.y = vertRect.y + vertRect.height
                uvRect.y = uvRect.y - uvRect.height
            else
                vertRect.y = vertRect.y - vertRect.height
                uvRect.y = uvRect.y + uvRect.height
            end
            NGraphics.FillVertsOfQuad(verts, 5, vertRect)
            NGraphics.FillUVOfQuad(uv, 5, uvRect)
        end
    end
end

---@param origin FairyGUI.Origin360
---@param amount number
---@param clockwise boolean
---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param verts Love2DEngine.Vector3[]
---@param uv Love2DEngine.Vector2[]
function FillUtils.FillRadial360(origin, amount, clockwise, vertRect, uvRect, verts, uv)
    if origin == Origin360.Top then
        if amount < 0.5 then
            amount = amount / 0.5
            vertRect.width = vertRect.width / 2
            uvRect.width = uvRect.width / 2
            if clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            end
            FillUtils.FillRadial180(clockwise and Origin180.Left or Origin180.Right, amount, clockwise, vertRect, uvRect, verts, uv)
            verts[9], verts[10], verts[11], verts[12] = verts[8], verts[8], verts[8], verts[8]
            uv[9], uv[10], uv[11], uv[12] = uv[8], uv[8], uv[8], uv[8]
        else
            vertRect.width = vertRect.width / 2
            uvRect.width = uvRect.width / 2
            if not clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            end
            amount = (amount - 0.5) / 0.5
            FillUtils.FillRadial180(clockwise and Origin180.Right or Origin180.Left, amount, clockwise, vertRect, uvRect, verts, uv)

            if clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            else
                vertRect.x = vertRect.x - vertRect.width
                uvRect.x = uvRect.x - uvRect.width
            end
            NGraphics.FillVertsOfQuad(verts, 9, vertRect)
            NGraphics.FillUVOfQuad(uv, 9, uvRect)
        end
    elseif origin == Origin360.Bottom then
        if amount < 0.5 then
            amount = amount / 0.5
            vertRect.width = vertRect.width / 2
            uvRect.width = uvRect.width / 2
            if not clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            end
            FillUtils.FillRadial180(clockwise and Origin180.Right or Origin180.Left, amount, clockwise, vertRect, uvRect, verts, uv)
            verts[9], verts[10], verts[11], verts[12] = verts[8], verts[8], verts[8], verts[8]
            uv[9], uv[10], uv[11], uv[12] = uv[8], uv[8], uv[8], uv[8]
        else
            vertRect.width = vertRect.width / 2
            uvRect.width = uvRect.width / 2
            if clockwise then
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            end
            amount = (amount - 0.5) / 0.5
            FillUtils.FillRadial180(clockwise and Origin180.Left or Origin180.Right, amount, clockwise, vertRect, uvRect, verts, uv)

            if clockwise then
                vertRect.x = vertRect.x - vertRect.width
                uvRect.x = uvRect.x - uvRect.width
            else
                vertRect.x = vertRect.x + vertRect.width
                uvRect.x = uvRect.x + uvRect.width
            end
            NGraphics.FillVertsOfQuad(verts, 9, vertRect)
            NGraphics.FillUVOfQuad(uv, 9, uvRect)
        end
    elseif origin == Origin360.Left then
        if amount < 0.5 then
            amount = amount / 0.5
            if clockwise then
                vertRect.height = vertRect.height / 2
                uvRect.yMin = uvRect.yMin + uvRect.height / 2
            else
                vertRect.yMin = vertRect.yMin + vertRect.height / 2
                uvRect.yMax = uvRect.yMax - uvRect.height / 2
            end
            FillUtils.FillRadial180(clockwise and Origin180.Bottom or Origin180.Top, amount, clockwise, vertRect, uvRect, verts, uv)
            verts[9], verts[10], verts[11], verts[12] = verts[8], verts[8], verts[8], verts[8]
            uv[9], uv[10], uv[11], uv[12] = uv[8], uv[8], uv[8], uv[8]
        else
            if clockwise then
                vertRect.yMin = vertRect.yMin + vertRect.height / 2
                uvRect.yMax = uvRect.yMax - uvRect.height / 2
            else
                vertRect.height = vertRect.height / 2
                uvRect.yMin = uvRect.yMin + uvRect.height / 2
            end
            amount = (amount - 0.5) / 0.5
            FillUtils.FillRadial180(clockwise and Origin180.Top or Origin180.Bottom, amount, clockwise, vertRect, uvRect, verts, uv)

            if clockwise then
                vertRect.y = vertRect.y - vertRect.height
                uvRect.y = uvRect.y + uvRect.height
            else
                vertRect.y = vertRect.y + vertRect.height
                uvRect.y = uvRect.y - uvRect.height
            end
            NGraphics.FillVertsOfQuad(verts, 9, vertRect)
            NGraphics.FillUVOfQuad(uv, 9, uvRect)
        end
    elseif origin == Origin360.Right then
        if amount < 0.5 then
            if clockwise then
                vertRect.yMin = vertRect.yMin + vertRect.height / 2
                uvRect.yMax = uvRect.yMax - uvRect.height / 2
            else
                vertRect.height = vertRect.height / 2
                uvRect.yMin = uvRect.yMin + uvRect.height / 2
            end
            amount = amount / 0.5
            FillUtils.FillRadial180(clockwise and Origin180.Top or Origin180.Bottom, amount, clockwise, vertRect, uvRect, verts, uv)
            verts[9], verts[10], verts[11], verts[12] = verts[8], verts[8], verts[8], verts[8]
            uv[9], uv[10], uv[11], uv[12] = uv[8], uv[8], uv[8], uv[8]
        else
            if clockwise then
                vertRect.height = vertRect.height / 2
                uvRect.yMin = uvRect.yMin + uvRect.height / 2
            else
                vertRect.yMin = vertRect.yMin + vertRect.height / 2
                uvRect.yMax = uvRect.yMax - uvRect.height / 2
            end
            amount = (amount - 0.5) / 0.5
            FillUtils.FillRadial180(clockwise and Origin180.Bottom or Origin180.Top, amount, clockwise, vertRect, uvRect, verts, uv)

            if clockwise then
                vertRect.y = vertRect.y + vertRect.height
                uvRect.y = uvRect.y - uvRect.height
            else
                vertRect.y = vertRect.y - vertRect.height
                uvRect.y = uvRect.y + uvRect.height
            end
            NGraphics.FillVertsOfQuad(verts, 9, vertRect)
            NGraphics.FillUVOfQuad(uv, 9, uvRect)
        end
    end
end

FairyGUI.FillMethod = FillMethod
FairyGUI.OriginHorizontal = OriginHorizontal
FairyGUI.OriginVertical = OriginVertical
FairyGUI.Origin90 = Origin90
FairyGUI.Origin180 = Origin180
FairyGUI.Origin360 = Origin360
FairyGUI.FillUtils = FillUtils
return FillUtils