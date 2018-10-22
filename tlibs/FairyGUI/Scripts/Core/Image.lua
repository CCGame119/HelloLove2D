--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/19 14:24
--

local Class = require('libs.Class')

local Color = Love2DEngine.Color
local Rect = Love2DEngine.Rect
local Vector2 = Love2DEngine.Vector2
local TextureWrapMode = Love2DEngine.TextureWrapMode
local DisplayObject = FairyGUI.DisplayObject
local NGraphics = FairyGUI.NGraphics
local ShaderConfig = FairyGUI.ShaderConfig
local NTexture = FairyGUI.NTexture
local ToolSet = FairyGUI.ToolSet
local FillMethod = FairyGUI.FillMethod
local FlipType = FairyGUI.FlipType

local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

---@class FairyGUI.FlipType:enum
local FlipType = {
    None = 0,
    Horizontal = 1,
    Vertical = 2,
    Both = 3
}

---@class FairyGUI.Image:FairyGUI.DisplayObject
---@field public texture FairyGUI.NTexture
---@field public color Love2DEngine.Color
---@field public flip FairyGUI.FlipType
---@field public fillMethod FairyGUI.FillMethod
---@field public fillOrigin number
---@field public fillAmount number
---@field public fillClockwise boolean
---@field public scale9Grid Love2DEngine.Rect
---@field public scaleByTile boolean
---@field public tileGridIndice number
---@field protected _texture FairyGUI.NTexture
---@field protected _color Love2DEngine.Color
---@field protected _flip FairyGUI.FlipType
---@field protected _scale9Grid Love2DEngine.Rect
---@field protected _scaleByTile boolean
---@field protected _tileGridIndice number
---@field protected _fillMethod FairyGUI.FillMethod
---@field protected _fillOrigin number
---@field protected _fillAmount number
---@field protected _fillClockwise boolean
local Image = Class.inheritsFrom('Image', nil, DisplayObject)

---@param texture FairyGUI.NTexture
function Image:__ctor(texture)
    DisplayObject.__ctor(self)

    self:Create(texture)
end

---@param texture FairyGUI.NTexture
function Image:Create(texture)
    self._touchDisabled = true
    self._fillClockwise = true

    self:CreateGameObject("Image")
    self.graphics = NGraphics(self.gameObject)
    self.graphics.shader = ShaderConfig.imageShader

    self._color = Color.white
    if (texture ~= nil) then
        self:UpdateTexture(texture)
    end
end

function Image:SetNativeSize()
    local oldWidth = self._contentRect.width
    local oldHeight = self._contentRect.height
    if self._texture ~= nil then
        self._contentRect.width = self._texture.width
        self._contentRect.height = self._texture.height
    else
        self._contentRect.width = 0
        self._contentRect.height =0
    end
    if oldWidth ~= self._contentRect.width or oldHeight ~= self._contentRect.height then
        self:OnSizeChanged(true, true)
    end
end

---@param context FairyGUI.UpdateContext
function Image:Update(context)
    if self._requireUpdateMesh then
        self:Rebuild()
    end

    DisplayObject.Update(self, context)
end

---@param value FairyGUI.NTexture
function Image:UpdateTexture(value)
    if value == self._texture then
         return
    end

    self._requireUpdateMesh = true
    self._texture = value
    if self._contentRect.width == 0 then
        self:SetNativeSize()
    end

    self.graphics.texture = self._texture
    self:InvalidateBatchingState()
end

Image.gridTileIndice = { -1, 0, -1, 2, 4, 3, -1, 1, -1 }
Image.gridX = {0, 0, 0, 0}
Image.gridY = {0, 0, 0, 0}
Image.gridTexX = {0, 0, 0, 0}
Image.gridTexY = {0, 0, 0, 0}

---@param gridRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
function Image:GenerateGrids(gridRect, uvRect)
    local sx = uvRect.width /  self._texture.width
    local sy = uvRect.height / self._texture.height
    Image.gridTexX[1] = uvRect.xMin
    Image.gridTexX[2] = uvRect.xMin + gridRect.xMin * sx
    Image.gridTexX[3] = uvRect.xMin + gridRect.xMax * sx
    Image.gridTexX[4] = uvRect.xMax
    Image.gridTexY[1] = uvRect.yMax
    Image.gridTexY[2] = uvRect.yMax - gridRect.yMin * sy
    Image.gridTexY[3] = uvRect.yMax - gridRect.yMax * sy
    Image.gridTexY[4] = uvRect.yMin

    if (self._contentRect.width >= (self._texture.width - gridRect.width)) then
        Image.gridX[2] = gridRect.xMin
        Image.gridX[3] = self._contentRect.width - (self._texture.width - gridRect.xMax)
        Image.gridX[4] = self._contentRect.width
    else
        local tmp = gridRect.xMin / (self._texture.width - gridRect.xMax)
        tmp = self._contentRect.width * tmp / (1 + tmp)
        Image.gridX[2] = tmp
        Image.gridX[3] = tmp
        Image.gridX[4] = self._contentRect.width
    end

    if (self._contentRect.height >= (self._texture.height - gridRect.height)) then
        Image.gridY[2] = gridRect.yMin
        Image.gridY[3] = self._contentRect.height - (self._texture.height - gridRect.yMax)
        Image.gridY[4] = self._contentRect.height
    else
        local tmp = gridRect.yMin / (self._texture.height - gridRect.yMax)
        tmp = self._contentRect.height * tmp / (1 + tmp)
        Image.gridY[2] = tmp
        Image.gridY[3] = tmp
        Image.gridY[4] = self._contentRect.height
    end
end

---@param destRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param sourceW number
---@param sourceH number
---@param vertIndex number
---@return number
function Image:TileFill(destRect, uvRect, sourceW, sourceH, vertIndex)
    local hc = math.ceil(destRect.width / sourceW)
    local vc = math.ceil(destRect.height / sourceH)
    local tailWidth = destRect.width - (hc - 1) * sourceW
    local tailHeight = destRect.height - (vc - 1) * sourceH

    if (vertIndex == 0) then
        self.graphics:Alloc(hc * vc * 4)
        vertIndex = 1
    end

    for i = 0, hc - 1 do
        for j = 0, vc - 1 do
            self.graphics:FillVerts(vertIndex, Rect(destRect.x + i * sourceW, destRect.y + j * sourceH,
                    i == (hc - 1) and tailWidth or sourceW, j == (vc - 1) and tailHeight or sourceH))
            local uvTmp = uvRect
            if (i == hc - 1) then
                uvTmp.xMax = math.lerp(uvRect.xMin, uvRect.xMax, tailWidth / sourceW)
            end
            if (j == vc - 1) then
                uvTmp.yMin = math.lerp(uvRect.yMin, uvRect.yMax, 1 - tailHeight / sourceH)
            end

            self.graphics:FillUV(vertIndex, uvTmp)
            vertIndex = vertIndex + 4
        end
    end

    return vertIndex
end

function Image:Rebuild()
    self._requireUpdateMesh = false
    if self._texture == nil then
        self.graphics:ClearMesh()
        return
    end

    local uvRect = self._texture.uvRect
    if self._flip ~= FlipType.None then
        ToolSet.FlipRect(uvRect, self._flip)
    end

    if self._fillMethod ~= FillMethod.None then
        self.graphics.DrawRectWithFillMethod(self._contentRect, uvRect, self._color,
                self._fillMethod, self._fillAmount, self._fillOrigin, self._fillClockwise)
    elseif self._texture.width == self._contentRect.width and self._texture.height == self._contentRect.height then
        self.graphics.DrawRect(self._contentRect, uvRect, self._color)
    elseif self._scaleByTile then
        --如果纹理是repeat模式，而且单独占满一张纹理，那么可以用repeat的模式优化显示
        if self._texture.nativeTexture ~= nil and self._texture.nativeTexture.wrapMode == TextureWrapMode.Repeat
                and uvRect.x == 0 and uvRect.y == 0 and uvRect.width == 1 and uvRect.height == 1 then
            uvRect.width = uvRect.width * self._contentRect.width / self._texture.width
            uvRect.height = uvRect.height * self._contentRect.height / self._texture.height
            self.graphics:DrawRect(self._contentRect, uvRect, self._color)
        else
            self:TileFill(self._contentRect, uvRect, self._texture.width, self._texture.height, -1)
            self.graphics:FillColors(self._color)
            self.graphics:FillTriangles()
        end
    elseif self._scale9Grid ~= nil then
        local gridRect = self._scale9Grid

        if self._flip ~= FlipType.None then
            ToolSet.FlipInnerRect(self._texture.width, self._texture.height, gridRect, self._flip)
        end

        self:GenerateGrids(gridRect, uvRect)

        if self._tileGridIndice == 0 then
            self.graphics:Alloc(16)
            local k = 0
            for cy = 1, 4 do
                for cx = 1, 4 do
                    self.graphics.uv[k] = Vector2(Image.gridTexX[cx], Image.gridTexY[cy])
                    self.graphics.vertices[k] = Vector2(Image.gridX[cx], -Image.gridY[cy])
                    k = k + 1
                end
            end
            self.graphics:FillTriangles(NGraphics.TRIANGLES_9_GRID)
        else
            ---@type number
            local hc, vc
            ---@type Love2DEngine.Rect
            local drawRect
            ---@type Love2DEngine.Rect
            local texRect
            ---@type number
            local row, col
            ---@type number
            local part

            --先计算需要的顶点数量
            local vertCount = 0
            for pi = 1, 9 do
                col = pi % 3
                row = pi / 3
                part = Image.gridTileIndice[pi]

                if part ~= -1 and band(self._tileGridIndice, lshift(part, 1)) ~= 0 then
                    if part == 0 or part == 1 or part == 4 then
                        hc = math.ceil((Image.gridX[col + 1] - Image.gridX[col]) / gridRect.width)
                    else
                        hc = 1
                    end

                    if part == 2 or part ==3 or part == 4 then
                        vc = math.ceil((Image.gridY[row + 1] - Image.gridY[row]) / gridRect.height)
                    else
                        vc = 1
                    end
                    vertCount = vertCount + hc * vc * 4
                else
                    vertCount = vertCount + 4
                end
            end

            self.graphics:Alloc(vertCount)

            local k = 0
            for pi = 1, 9 do
                col = pi % 3
                row = pi / 3
                part = Image.gridTileIndice[pi]
                drawRect = Rect.MinMaxRect(Image.gridX[col], Image.gridY[row], Image.gridX[col + 1], Image.gridY[row + 1])
                texRect = Rect.MinMaxRect(Image.gridTexX[col], Image.gridTexY[row + 1], Image.gridTexX[col + 1], Image.gridTexY[row])

                if part ~= -1 and (band(self._tileGridIndice, lshift(part, 1)) ~= 0) then
                    k = self:TileFill(drawRect, texRect,
                            (part == 0 or part == 1 or part == 4) and gridRect.width or drawRect.width,
                            (part == 2 or part == 3 or part == 4) and gridRect.height or drawRect.height,
                            k)
                else
                    self.graphics:FillVerts(k, drawRect)
                    self.graphics:FillUV(k, texRect)
                    k = k + 4
                end
            end
            self.graphics:FillTriangles()
        end
        self.graphics:FillColors(self._color)
    else
        self.graphics:DrawRect(self._contentRect, uvRect, self._color)
    end

    if self._texture.rotated then
        NGraphics.RotateUV(self.graphics.uv, uvRect)
    end
    self.graphics:UpdateMesh()
end

---截取当前图片的一部分输出到另一个Mesh。不支持图片的填充模式、九宫格的平铺模式
---@param mesh Love2DEngine.Mesh @目标Mesh
---@param localRect Love2DEngine.Rect @指定图片的区域
function Image:PrintTo(mesh, localRect)
    if self._requireUpdateMesh then
        self:Rebuild()
    end

    local uvRect = self._texture.uvRect
    if self._flip ~= FlipType.None then
        ToolSet.FlipRect(uvRect, self._flip)
    end

    ---@type Love2DEngine.Vector3[]
    local verts
    ---@type Love2DEngine.Vector2[]
    local uv
    ---@type Love2DEngine.Color32[]
    local colors
    ---@type number[]
    local triangles
    local vertCount = 0

    if not self._scaleByTile or self._scale9Grid == nil or
            (self._texture.width == self._contentRect.width and self._texture.height == self._contentRect.height) then
        verts = {}
        uv = {}
        local bound = ToolSet.Intersection(self._contentRect, localRect)

        local u0 = bound.xMin / self._contentRect.width
        local u1 = bound.xMax / self._contentRect.width
        local v0 = (self._contentRect.height - bound.yMax) / self._contentRect.height
        local v1 = (self._contentRect.height - bound.yMin) / self._contentRect.height
        u0 = math.lerp(uvRect.xMin, uvRect.xMax, u0)
        u1 = math.lerp(uvRect.xMin, uvRect.xMax, u1)
        v0 = math.lerp(uvRect.yMin, uvRect.yMax, v0)
        v1 = math.lerp(uvRect.yMin, uvRect.yMax, v1)
        NGraphics.FillUVOfQuad(uv, 1, Rect.MinMaxRect(u0, v0, u1, v1))

        bound.x = 0
        bound.y = 0
        NGraphics.FillVertsOfQuad(verts, 1, bound)
        vertCount = vertCount + 4
    elseif self._scaleByTile then
        verts = {}
        uv = {}

        local hc = math.ceil(self._contentRect.width / self._texture.width)
        local vc = math.ceil(self._contentRect.height / self._texture.height)
        local tailWidth = self._contentRect.width - (hc - 1) * self._texture.width
        local tailHeight = self._contentRect.height - (vc - 1) * self._texture.height

        local offset = Vector2.zero
        for i = 0, hc do
            for j = 0, vc do
                local rect = Rect(i * self._texture.width, j * self._texture.height,
                        i == (hc - 1) and tailWidth or self._texture.width, j == (vc - 1) and tailHeight or self._texture.height)
                local uvTmp = uvRect
                if (i == hc - 1) then
                    uvTmp.xMax = math.lerp(uvRect.xMin, uvRect.xMax, tailWidth / self._texture.width)
                end
                if (j == vc - 1) then
                    uvTmp.yMin = math.lerp(uvRect.yMin, uvRect.yMax, 1 - tailHeight / self._texture.height)
                end

                local bound = ToolSet.Intersection(rect, localRect)
                if bound.xMax - bound.xMin >= 0 and bound.yMax - bound.yMin > 0 then
                    local u0 = (bound.xMin - rect.x) / rect.width
                    local u1 = (bound.xMax - rect.x) / rect.width
                    local v0 = (rect.y + rect.height - bound.yMax) / rect.height
                    local v1 = (rect.y + rect.height - bound.yMin) / rect.height
                    u0 = math.lerp(uvTmp.xMin, uvTmp.xMax, u0)
                    u1 = math.lerp(uvTmp.xMin, uvTmp.xMax, u1)
                    v0 = math.lerp(uvTmp.yMin, uvTmp.yMax, v0)
                    v1 = math.lerp(uvTmp.yMin, uvTmp.yMax, v1)
                    NGraphics.FillUVOfQuad(uv, vertCount, Rect.MinMaxRect(u0, v0, u1, v1))

                    if (i == 0 and j == 0) then
                        offset = Vector2(bound.x, bound.y)
                    end
                    bound.x = bound.x - offset.x
                    bound.y = bound.y - offset.y
                    NGraphics.FillVertsOfQuad(verts, vertCount, bound)

                    vertCount = vertCount + 4
                end
            end
        end
    else
        local gridRect = self._scale9Grid

        if self._flip ~= FlipType.None then
            ToolSet.FlipInnerRect(self._texture.width, self._texture.height, gridRect, self._flip)
        end

        self:GenerateGrids(gridRect, uvRect)

        verts = {}
        uv = {}
        local offset = Vector2.zero

        ---@type Love2DEngine.Rect
        local drawRect
        ---@type Love2DEngine.Rect
        local texRect
        ---@type number
        local row, col
        ---@type number
        local u0, u1, v0, v1

        for pi = 1, 9 do
            col = pi % 3
            row = pi / 3
            drawRect = Rect.MinMaxRect(Image.gridX[col], Image.gridY[row], Image.gridX[col + 1], Image.gridY[row + 1])
            texRect = Rect.MinMaxRect(Image.gridTexX[col], Image.gridTexY[row + 1], Image.gridTexX[col + 1], Image.gridTexY[row])
            local bound = ToolSet.Intersection(drawRect, localRect)
            if (bound.xMax - bound.xMin >= 0 and bound.yMax - bound.yMin > 0) then
                u0 = (bound.xMin - drawRect.x) / drawRect.width
                u1 = (bound.xMax - drawRect.x) / drawRect.width
                v0 = (drawRect.yMax - bound.yMax) / drawRect.height
                v1 = (drawRect.yMax - bound.yMin) / drawRect.height
                u0 = math.lerp(texRect.xMin, texRect.xMax, u0)
                u1 = math.lerp(texRect.xMin, texRect.xMax, u1)
                v0 = math.lerp(texRect.yMin, texRect.yMax, v0)
                v1 = math.lerp(texRect.yMin, texRect.yMax, v1)
                NGraphics.FillUVOfQuad(uv, vertCount, Rect.MinMaxRect(u0, v0, u1, v1))

                if (vertCount == 0) then
                    offset = Vector2(bound.x, bound.y)
                end
                bound.x = bound.x - offset.x
                bound.y = bound.y - offset.y
                NGraphics.FillVertsOfQuad(verts, vertCount, bound)

                vertCount = vertCount + 4
            end
        end
    end

    if (vertCount ~= verts.Length) then
        --Array.Resize(ref verts, vertCount)
        --Array.Resize(ref uv, vertCount)
    end
    local triangleCount = rshift(vertCount, 1) * 3
    triangles = {}
    local k = 1
    for i = 1, vertCount, 4 do
        k = k + 1; triangles[k] = i
        k = k + 1; triangles[k] = i + 1
        k = k + 1; triangles[k] = i + 2

        k = k + 1; triangles[k] = i + 2
        k = k + 1; triangles[k] = i + 3
        k = k + 1; triangles[k] = i
    end

    colors = {}
    for i = 1, vertCount do
        local col = self._color:Clone()
        col.a = self.alpha
        colors[i] = col
    end

    if (self._texture.rotated) then
        NGraphics.RotateUV(uv, uvRect)
    end

    mesh.Clear()
    mesh.vertices = verts
    mesh.uv = uv
    mesh.triangles = triangles
    mesh.colors32 = colors
end

local __get = Class.init_get(Image)
local __set = Class.init_set(Image)

---@param self FairyGUI.Image
__get.texture = function(self) return self._texture end

---@param self FairyGUI.Image
---@param val FairyGUI.NTexture
__set.texture = function(self, val) self:UpdateTexture(val) end


---@param self FairyGUI.Image
__get.color = function(self) return self._color end

---@param self FairyGUI.Image
---@param val Love2DEngine.Color
__set.color = function(self, val)
    if self._color ~= val then
        self._color = val
        self.graphics:Tint(self._color)
    end
end

---@param self FairyGUI.Image
__get.flip = function(self) return self._flip end

---@param self FairyGUI.Image
---@param val FairyGUI.FlipType
__set.flip = function(self, val)
    if self._flip ~= val then
        self._flip = val
        self._requireUpdateMesh = true
    end
end

---@param self FairyGUI.Image
__get.fillMethod = function(self) return self._fillMethod end

---@param self FairyGUI.Image
---@param val FairyGUI.FillMethod
__set.fillMethod = function(self, val)
    if self._fillMethod ~= val then
        self._fillMethod = val
        self._requireUpdateMesh = true
    end
end

---@param self FairyGUI.Image
__get.fillOrigin = function(self) return self._fillOrigin end

---@param self FairyGUI.Image
---@param val number
__set.fillOrigin = function(self, val)
    if self._fillOrigin ~= val then
        self._fillOrigin = val
        self._requireUpdateMesh = true
    end
end

---@param self FairyGUI.Image
__get.fillClockwise = function(self) return self._fillClockwise end

---@param self FairyGUI.Image
---@param val boolean
__set.fillClockwise = function(self, val)
    if self._fillClockwise ~= val then
        self._fillClockwise = val
        self._requireUpdateMesh = true
    end
end

---@param self FairyGUI.Image
__get.fillAmount = function(self) return self._fillAmount end

---@param self FairyGUI.Image
---@param val number
__set.fillAmount = function(self, val)
    if self._fillAmount ~= val then
        self._fillAmount = val
        self._requireUpdateMesh = true
    end
end

---@param self FairyGUI.Image
__get.scale9Grid = function(self) return self._scale9Grid end

---@param self FairyGUI.Image
---@param val Love2DEngine.Rect
__set.scale9Grid = function(self, val)
    if self._scale9Grid ~= val then
        self._scale9Grid = val
        self._requireUpdateMesh = true
    end
end

---@param self FairyGUI.Image
__get.scaleByTile = function(self) return self._scaleByTile end

---@param self FairyGUI.Image
---@param val boolean
__set.scaleByTile = function(self, val)
    if self._scaleByTile ~= val then
        self._scaleByTile = val
        self._requireUpdateMesh = true
    end
end

---@param self FairyGUI.Image
__get.tileGridIndice = function(self) return self._tileGridIndice end

---@param self FairyGUI.Image
---@param val boolean
__set.tileGridIndice = function(self, val)
    if self._tileGridIndice ~= val then
        self._tileGridIndice = val
        self._requireUpdateMesh = true
    end
end


FairyGUI.FlipType = FlipType
FairyGUI.Image = Image
return Image