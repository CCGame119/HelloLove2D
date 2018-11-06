--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 13:44
--

--region 模块引用
local Class = require('libs.Class')
local Delegate = require('libs.Delegate')
local bit = require('bit')
local bor, rshift = bit.bor, bit.rshift

local GameObject = Love2DEngine.GameObject
local DisplayOptions = FairyGUI.DisplayOptions
local MeshFilter = Love2DEngine.MeshFilter
local MeshRenderer = Love2DEngine.MeshRenderer
local Mesh = Love2DEngine.Mesh
local Rendering = Love2DEngine.Rendering
local Vector3 = Love2DEngine.Vector3
local Vector2 = Love2DEngine.Vector2
local Color32 = Love2DEngine.Color32
local Color = Love2DEngine.Color
local Rect = Love2DEngine.Rect

local ToolSet = Utils.ToolSet
local ShaderConfig = FairyGUI.ShaderConfig
local Stats = FairyGUI.Stats
local UpdateContext = FairyGUI.UpdateContext
local BlendMode = FairyGUI.BlendMode
local BlendModeUtils = FairyGUI.BlendModeUtils
local FillMethod = FairyGUI.FillMethod
local FillUtils = FairyGUI.FillUtils


--endregion

--region FairyGUI.NGraphics.MeshModifier

---@class FairyGUI.NGraphics.MeshModifier:Delegate @fun()
local MeshModifier = Delegate.newDelegate('MeshModifier')

---@class FairyGUI.StencilEraser:ClassType
---@field public gameObject Love2DEngine.GameObject
---@field public meshFilter Love2DEngine.MeshFilter
---@field public meshRenderer Love2DEngine.MeshRenderer
---@field public enabled boolean
local StencilEraser = Class.inheritsFrom('StencilEraser')

---@param parent Love2DEngine.Transform
function StencilEraser:__ctor(parent)
    self.gameObject = GameObject:get('Eraser')
    ToolSet.SetParent(self.gameObject.transform, parent)
    self.meshFilter = self.gameObject:AddComponent(MeshModifier)
    self.meshRenderer = self.gameObject:AddComponent(MeshRenderer)
    --self.meshRenderer.castShadows = false
    --self.meshRenderer.receiveShadows = false

    self.gameObject.layer = parent.gameObject.layer
    self.gameObject.hideFlags = parent.gameObject.hideFlags
    self.meshFilter.hideFlags = parent.gameObject.hideFlags
    self.meshRenderer.hideFlags = parent.gameObject.hideFlags
end

local __get = Class.init_get(StencilEraser)
local __set = Class.init_set(StencilEraser)

__get.enabled = function(self) return self.meshRenderer.enabled end
__set.enabled = function(self, val) self.meshRenderer.enabled = val end

--endregion

--region FairyGUI.NGraphics
--region 类定义

---@class FairyGUI.NGraphics:ClassType
---@field public vertices Love2DEngine.Vector3[]
---@field public uv Love2DEngine.Vector2[]
---@field public colors Love2DEngine.Color32[]
---@field public triangles number[]
---@field public vertCount number
---@field public meshFilter Love2DEngine.MeshFilter
---@field public meshRenderer Love2DEngine.MeshRenderer
---@field public mesh Love2DEngine.Mesh
---@field public gameObject Love2DEngine.GameObject
---@field public grayed boolean
---@field public blendMode FairyGUI.BlendMode
---@field public dontClip boolean
---@field public maskFrameId number
---@field public vertexMatrix Love2DEngine.Matrix4x4
---@field public cameraPosition Love2DEngine.Vector3
---@field public meshModifier FairyGUI.NGraphics.MeshModifier
---@field public sortingOrder number
---@field public gameObject Love2DEngine.GameObject
---@field public enabled boolean
---@field public vertexMatrix Love2DEngine.Matrix4x4
---@field public texture FairyGUI.NTexture
---@field public shader string
---@field public material Love2DEngine.Material
---@field public materialKeywords string[]
---@field public enabled boolean
---@field public sortingOrder number
---@field public alpha number
---@field private _texture FairyGUI.NTexture
---@field private _shader string
---@field private _material Love2DEngine.Material
---@field private _customMatarial boolean
---@field private _manager MaterialManager
---@field private _materialKeywords string[]
---@field private _alpha number
---@field private _alphaBackup number[] @透明度改变需要通过修改顶点颜色实现，但顶点颜色本身可能就带有透明度，所以这里要有一个备份
---@field private _stencilEraser FairyGUI.StencilEraser
local NGraphics = Class.inheritsFrom('NGraphics')

--endregion

--region 成员函数

--[[
1---2
| / |
0---3
]]
---@type number[] @写死的一些三角形顶点组合，避免每次new
NGraphics.TRIANGLES = {0, 1, 2, 2, 3, 0}

NGraphics.TRIANGLES_9_GRID = {
    4,0,1,1,5,4,
    5,1,2,2,6,5,
    6,2,3,3,7,6,
    8,4,5,5,9,8,
    9,5,6,6,10,9,
    10,6,7,7,11,10,
    12,8,9,9,13,12,
    13,9,10,10,14,13,
    14,10,11,
    11,15,14
}

NGraphics.TRIANGLES_4_GRID = {
    4, 0, 5,
    4, 5, 1,
    4, 1, 6,
    4, 6, 2,
    4, 2, 7,
    4, 7, 3,
    4, 3, 8,
    4, 8, 0
}

---@param gameObject Love2DEngine.GameObject
function NGraphics:__ctor(gameObject)
    self.gameObject = gameObject
    self._alpha = 1
    self._shader = ShaderConfig.imageShader
    self.meshFilter = gameObject:AddComponent(MeshFilter)
    self.meshRenderer = gameObject:AddComponent(MeshRenderer)
    --self.meshRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off
    --self.meshRenderer.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off
    --self.meshRenderer.receiveShadows = false
    self.mesh = Mesh.new()
    self.mesh.name = gameObject.name
    self.meshRenderer:MarkDynamic()

    self.meshFilter.hideFlags = DisplayOptions.hideFlags;
    self.meshRenderer.hideFlags = DisplayOptions.hideFlags;
    self.mesh.hideFlags = DisplayOptions.hideFlags;

    Stats.LatestGraphicsCreation = Stats.LatestGraphicsCreation + 1;
end

---@param shader string
---@param texture FairyGUI.NTexture
function NGraphics:SetShaderAndTexture(shader, texture)
    self._shader = shader
    self._texture = texture
    if self._customMatarial and self._material ~= nil then
        self._material.mainTexture = (self._texture ~= nil and self._texture.nativeTexture or nil)
    end
    self:UpdateManager()
end

function NGraphics:UpdateManager()
    if self._manager ~= nil then
        self._manager:Release()
    end

    if self._texture ~= nil then
        self._manager = self._texture:GetMaterialManager(self._shader, self._materialKeywords)
    else
        self._manager = nil
    end
end

---@param val number
function NGraphics:SetStencilEraserOrder(val)
    if self._stencilEraser ~= nil then
        self._stencilEraser.meshRenderer.sortingOrder = val
    end
end

function NGraphics:Dispose()
    if self.mesh ~= nil then
        self.mesh = nil
    end
    if self._manager ~= nil then
        self._manager:Release()
        self._manager = nil
    end
    self._material = nil
    self.meshRenderer = nil
    self.meshFilter = nil
    self._stencilEraser = nil
    self.meshModifier = nil
end

---@param context FairyGUI.UpdateContext
function NGraphics:UpdateMaterial(context)
    Stats.GraphicsCount = Stats.GraphicsCount + 1
    ---@type FairyGUI.NMaterial
    local nm = nil
    if not self._customMatarial then
        if self._manager ~= nil then
            nm = self._manager.GetMaterial(self, context)
            self._material = nm.material
            if self._material ~= self.meshRenderer.sharedMaterial then
                self.meshRenderer.sharedMaterial = self._material
            end
        else
            self._material = nil
            if self.meshRenderer.sharedMaterial ~= nil then
                self.meshRenderer.sharedMaterial = nil
            end
        end
    end

    if self.maskFrameId ~= 0 and self.maskFrameId ~= UpdateContext.frameId then
        --曾经是遮罩对象，现在不是了
        if self._stencilEraser ~= nil then
            self._stencilEraser.enabled = false
        end
    end

    if self._material ~= nil then
        if self.blendMode ~= BlendMode.Normal then --GetMateria已经保证了不同的blendMode会返回不同的共享材质，所以这里可以放心设置
            BlendModeUtils.Apply(self._material, self.blendMode)
        end

        local clearStencil = false
        if context.clipped then
            if self.maskFrameId ~= UpdateContext.frameId and context.rectMaskDepth > 0 then --在矩形剪裁下，且不是遮罩对象
                self._material:SetVector("_ClipBox", context.clipInfo.clipBox)
                if context.clipInfo.soft then
                    self._material:SetVector("_ClipSoftness", context.clipInfo.softness)
                end
            end

            if context.stencilReferenceValue > 0 then
                if self.maskFrameId == UpdateContext.frameId then --是遮罩
                    if context.stencilReferenceValue == 1 then
                        self._material:SetInt("_StencilComp",  Rendering.CompareFunction.Always)
                        self._material:SetInt("_Stencil", 1)
                        self._material:SetInt("_StencilOp",  Rendering.StencilOp.Replace)
                        self._material:SetInt("_StencilReadMask", 255)
                        self._material:SetInt("_ColorMask", 0)
                    else
                        self._material:SetInt("_StencilComp", Rendering.CompareFunction.Equal);
                        self._material:SetInt("_Stencil", bor(context.stencilReferenceValue, (context.stencilReferenceValue - 1)));
                        self._material:SetInt("_StencilOp", Rendering.StencilOp.Replace);
                        self._material:SetInt("_StencilReadMask", context.stencilReferenceValue - 1);
                        self._material:SetInt("_ColorMask", 0);
                    end

                    --设置擦除stencil的drawcall
                    if (self._stencilEraser == nil) then
                        self._stencilEraser = StencilEraser.new(self.gameObject.transform)
                        self._stencilEraser.meshFilter.mesh = self.mesh
                    else
                        self._stencilEraser.enabled = true
                    end

                    if nm ~= nil then
                        local eraserNm = self._manager:GetMaterial(self, context)
                        eraserNm.stencilSet = true
                        local eraserMat = eraserNm.material
                        if eraserMat ~= self._stencilEraser.meshRenderer.sharedMaterial then
                            self._stencilEraser.meshRenderer.sharedMaterial = eraserMat
                        end

                        local refValue = context.stencilReferenceValue - 1
                        eraserMat:SetInt("_StencilComp", Rendering.CompareFunction.Equal)
                        eraserMat:SetInt("_Stencil", refValue)
                        eraserMat:SetInt("_StencilOp", Rendering.StencilOp.Replace)
                        eraserMat:SetInt("_StencilReadMask", refValue)
                        eraserMat:SetInt("_ColorMask", 0)
                    end
                else
                    local refValue = bor(context.stencilReferenceValue, (context.stencilReferenceValue - 1))
                    if (context.clipInfo.reversedMask) then
                        self._material:SetInt("_StencilComp", Rendering.CompareFunction.NotEqual)
                    else
                        self._material:SetInt("_StencilComp", Rendering.CompareFunction.Equal)
                        self._material:SetInt("_Stencil", refValue)
                        self._material:SetInt("_StencilOp", Rendering.StencilOp.Keep)
                        self._material:SetInt("_StencilReadMask", refValue)
                        self._material:SetInt("_ColorMask", 15)
                    end
                end
                if (nm ~= nil) then nm.stencilSet = true end
            else
                clearStencil = nm == nil or nm.stencilSet
            end
        else
            clearStencil = nm == nil or nm.stencilSet
        end

        if (clearStencil) then
            self._material.SetInt("_StencilComp", Rendering.CompareFunction.Always)
            self._material.SetInt("_Stencil", 0)
            self._material.SetInt("_StencilOp", Rendering.StencilOp.Keep)
            self._material.SetInt("_StencilReadMask", 255)
            self._material.SetInt("_ColorMask", 15)
        end
    end
end

---@param vertCount number
function NGraphics:Alloc(vertCount)
    if (self.vertices == nil or self.vertices.Length ~= vertCount) then
        self.vertices = {} --new Vector3[vertCount]
        self.uv = {} --new Vector2[vertCount]
        self.colors ={} --new Color32[vertCount]
        for i = 1, vertCount do
            table.insert(self.vertices, Vector3())
            table.insert(self.uv, Vector2())
            table.insert(self.colors, Color32())
        end
    end
end

function NGraphics:UpdateMesh()
    if self.meshModifier ~= nil then
        self.meshModifier();
    end

    local vertices = self.vertices
    self.vertCount = #vertices
    if self.vertexMatrix ~= nil then
        local mm = self.vertexMatrix
        local camPos = (self.cameraPosition ~= nil and self.cameraPosition or Vector3.zero)
        local center = Vector3(camPos.x, camPos.y, 0)
        center:Sub(mm:MultiplyPoint(center))
        for i = 1, self.vertCount do
            local pt = vertices[i]
            pt:Assign(mm.MultiplyPoint(pt))
            local vec = pt - camPos
            local lambda = -camPos.z / vec.z
            pt.x = camPos.x + lambda * vec.x
            pt.y = camPos.y + lambda * vec.y
            pt.z = 0

            vertices[i] = pt
        end

        local colors = self.colors
        for i = 1, self.vertCount do
            local col = colors[i]
            if col.a ~= 255 then
                if self._alphaBackup == nil then
                    self._alphaBackup = {}
                end
            end
            col.a = col.a * self._alpha
            colors[i] = col
        end

        if self._alphaBackup ~= nil then
            for i = 1, self.vertCount do
                self._alphaBackup[i] = colors[a]
            end
        end

        self.mesh.Clear()
        self.mesh.vertices = vertices
        self.mesh.uv = self.uv
        self.mesh.triangles = self.triangles
        self.mesh.colors32 = colors
        self.meshFilter.mesh = self.mesh

        if self._stencilEraser ~= nil then
            self._stencilEraser.meshFilter.mesh = self.mesh
        end
    end
end

---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param color Love2DEngine.C
function NGraphics:DrawRect(vertRect, uvRect, color)
    --当四边形发生形变时，只用两个三角面表达会造成图形的变形较严重，这里做一个优化，自动增加更多的面
    if (self.vertexMatrix ~= nil) then
        self:Alloc(9)

        self:FillVerts(1, vertRect)
        self:FillUV(1, uvRect)

        local camPos = Vector2()
        camPos.x = vertRect.x + vertRect.width / 2
        camPos.y = -(vertRect.y + vertRect.height / 2)
        local cx = uvRect.x + (camPos.x - vertRect.x) / vertRect.width * uvRect.width
        local cy = uvRect.y - (camPos.y - vertRect.y) / vertRect.height * uvRect.height

        self.vertices[5] = Vector3(camPos.x, camPos.y, 0)
        self.vertices[6] = Vector3(vertRect.xMin, camPos.y, 0)
        self.vertices[7] = Vector3(camPos.x, -vertRect.yMin, 0)
        self.vertices[8] = Vector3(vertRect.xMax, camPos.y, 0)
        self.vertices[9] = Vector3(camPos.x, -vertRect.yMax, 0)

        self.uv[5] = Vector2(cx, cy)
        self.uv[6] = Vector2(uvRect.xMin, cy)
        self.uv[7] = Vector2(cx, uvRect.yMax)
        self.uv[8] = Vector2(uvRect.xMax, cy)
        self.uv[9] = Vector2(cx, uvRect.yMin)

        self.triangles = NGraphics.TRIANGLES_4_GRID
    else
        self:Alloc(4)
        self:FillVerts(1, vertRect)
        self:FillUV(1, uvRect)
        self.triangles = NGraphics.TRIANGLES
    end

    self:FillColors(color)
end

---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param lineSize number
---@param lineColor Love2DEngine.Color
---@param fillColor Love2DEngine.Color
function NGraphics:DrawRect(vertRect, uvRect, lineSize, lineColor, fillColor)
    if lineSize == 0 then
        self:DrawRect(vertRect, uvRect, fillColor)
    else
        self:Alloc(20)

        local rect = nil;
        --left,right
        rect = Rect.MinMaxRect(0, 0, lineSize, vertRect.height)
        self:FillVerts(1, rect)
        rect = Rect.MinMaxRect(vertRect.width - lineSize, 0, vertRect.width, vertRect.height)
        self:FillVerts(5, rect)

        --top, bottom
        rect = Rect.MinMaxRect(lineSize, 0, vertRect.width - lineSize, lineSize)
        self:FillVerts(9, rect)
        rect = Rect.MinMaxRect(lineSize, vertRect.height - lineSize, vertRect.width - lineSize, vertRect.height)
        self:FillVerts(13, rect)

        --middle
        rect = Rect.MinMaxRect(lineSize, lineSize, vertRect.width - lineSize, vertRect.height - lineSize)
        self:FillVerts(17, rect)

        self:FillShapeUV(vertRect, uvRect)

        local arr = self.colors
        local col32 = Color32.FromColor(lineColor)
        for i = 1, 16 do
            arr[i] = col32
        end

        col32 = Color32.FromColor(fillColor)
        for i = 17, 20 do
            arr[i] = col32;
        end

        self:FillTriangles()
    end
end

---@type number[]
NGraphics.sCornerRadius = { 0, 0, 0, 0 }

---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param fillColor Love2DEngine.Color
---@param topLeftRadius Love2DEngine.Rect
---@param topRightRadius Love2DEngine.Rect
---@param bottomLeftRadius Love2DEngine.Rect
---@param bottomRightRadius Love2DEngine.Rect
function NGraphics:DrawRoundRect(vertRect,  uvRect,  fillColor,
                                 topLeftRadius,  topRightRadius,  bottomLeftRadius,  bottomRightRadius )
    self.sCornerRadius[1] = topRightRadius
    self.sCornerRadius[2] = topLeftRadius
    self.sCornerRadius[3] = bottomLeftRadius
    self.sCornerRadius[4] = bottomRightRadius

    local numSides = 0
    for i = 1, 4 do
        local radius = self.sCornerRadius[i]
        if  radius ~= 0 then
            local radiusX = math.min(radius, vertRect.width / 2)
            local radiusY = math.min(radius, vertRect.height / 2)
            numSides = numSides + math.max(1, math.ceil(math.pi * (radiusX + radiusY) / 4 / 4)) + 1
        else
            numSides = numSides + 1
        end
    end

    self:Alloc(numSides + 1)
    local vertices = self.vertices

    vertices[1] = Vector3(vertRect.width / 2, -vertRect.height / 2)
    local k = 2

    for  i = 1, 4 do
        local radius = self.sCornerRadius[i]

        local radiusX = math.min(radius, vertRect.width / 2)
        local radiusY = math.min(radius, vertRect.height / 2)

        local offsetX = 0
        local offsetY = 0

        if (i == 1 or i == 4) then
            offsetX = vertRect.width - radiusX * 2;
        end
        if (i == 3 or i == 4) then
            offsetY = radiusY * 2 - vertRect.height;
        end

        if (radius ~= 0) then
            local partNumSides = math.max(1, math.ceil(math.pi * (radiusX + radiusY) / 4 / 4)) + 1
            local angleDelta = math.pi / 2 / partNumSides
            local angle = math.pi / 2 * i
            local startAngle = angle

            for j = 1, partNumSides do
                if j == partNumSides then --消除精度误差带来的不对齐
                    angle = startAngle + math.pi / 2
                end
                vertices[k] = Vector3(offsetX + math.cos(angle) * radiusX + radiusX,
                        offsetY + math.sin(angle) * radiusY - radiusY, 0)
                angle = angle + angleDelta;
                k = k + 1
            end
        else
            vertices[k] = Vector3(offsetX, offsetY, 0)
            k = k + 1
        end
    end

    self:FillShapeUV(vertRect, uvRect)

    self:AllocTriangleArray(numSides * 3)
    local triangles = self.triangles

    k = 1
    for i = 2, numSides do
        k = k + 1; triangles[k] = i + 1;
        k = k + 1; triangles[k] = i;
        k = k + 1; triangles[k] = 1;
    end
    k = k + 1; triangles[k] = 2;
    k = k + 1; triangles[k] = numSides + 1;
    k = k + 1; triangles[k] = 1;

    self:FillColors(fillColor);
end

---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param fillColor Love2DEngine.Color
function NGraphics:DrawEllipse(vertRect, uvRect, fillColor)
    local radiusX = vertRect.width / 2
    local radiusY = vertRect.height / 2
    local numSides = math.ceil(math.pi * (radiusX + radiusY) / 4)
    if (numSides < 6) then numSides = 6 end

    self:Alloc(numSides + 1)
    local vertices = self.vertices

    local angleDelta = 2 * math.pi / numSides
    local angle = 0

    vertices[1] = Vector3(radiusX, -radiusY)
    for i = 2, numSides + 1 do
        vertices[i] = Vector3(math.cos(angle) * radiusX + radiusX,
                math.sin(angle) * radiusY - radiusY, 0)
    end

    self:FillShapeUV(vertRect, uvRect)

    self:AllocTriangleArray(numSides * 3)
    local triangles = self.triangles

    local k = 1
    for i = 2, numSides do
        k = k + 1; triangles[k] = i + 1
        k = k + 1; triangles[k] = i
        k = k + 1; triangles[k] = 1
    end
    k = k + 1; triangles[k] = 2
    k = k + 1; triangles[k] = numSides + 1
    k = k + 1; triangles[k] = 1

    self:FillColors(fillColor)
end

---@type number{}
NGraphics.sRestIndices = {}

---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param points Love2DEngine.Vector2[]
---@param fillColor Love2DEngine.Color
function NGraphics:DrawPolygon(vertRect, uvRect, points, fillColor)
    local numVertices = #points
    if numVertices < 3 then return end

    local numTriangles = numVertices - 2
    local i, restIndexPos, numRestIndices
    local k = 1

    self:Alloc(numVertices)
    local vertices = self.vertices

    for i = 1, numVertices do
        vertices[i] = Vector3(points[i].x, -points[i].y)
    end

    self:FillShapeUV(vertRect, uvRect)

    --[[
     Algorithm "Ear clipping method" described here:
     -> https://en.wikipedia.org/wiki/Polygon_triangulation
     Implementation inspired by:
     -> http://polyk.ivank.net
     -> Starling
    ]]

    self:AllocTriangleArray(numTriangles * 3)
    local triangles = self.triangles

    local sRestIndices = {}
    NGraphics.sRestIndices = sRestIndices
    for i = 1, numTriangles do
        table.insert(sRestIndices, i)
    end

    restIndexPos = 1
    numRestIndices = numVertices
    local a, b, c, p
    local otherIndex, earFound
    local i0, i1, i2

    while (numRestIndices > 3) do
        earFound = false
        i0 = sRestIndices[restIndexPos % numRestIndices]
        i1 = sRestIndices[(restIndexPos + 1) % numRestIndices]
        i2 = sRestIndices[(restIndexPos + 2) % numRestIndices]

        a = points[i0]
        b = points[i1]
        c = points[i2]

        if ((a.y - b.y) * (c.x - b.x)  + (b.x - a.x) * (c.y - b.y) >= 0) then
            earFound = true
            for i = 4, numRestIndices do
                otherIndex = sRestIndices[(restIndexPos + i) % numRestIndices]
                p = points[otherIndex]

                if ToolSet.IsPointInTriangle(p, a, b, c) then
                    earFound = false
                    break
                end
            end
        end

        if earFound then
            k = k + 1; triangles[k] = i0
            k = k + 1; triangles[k] = i1
            k = k + 1; triangles[k] = i2
            table.remove(sRestIndices, (restIndexPos + 1)% numRestIndices)

            numRestIndices = numRestIndices - 1
            restIndexPos = 1
        else
            restIndexPos = restIndexPos + 1
            if restIndexPos == numRestIndices then break end -- no more ears
        end
    end

    k = k + 1; triangles[k] = sRestIndices[1]
    k = k + 1; triangles[k] = sRestIndices[2]
    k = k + 1; triangles[k] = sRestIndices[3]

    self:FillColors(fillColor)
end

---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
---@param fillColor Love2DEngine.Color
---@param method
---@param amount number
---@param origin number
---@param clockwise boolean
function NGraphics:DrawRectWithFillMethod(vertRect, uvRect, fillColor,
                                          method, amount, origin, clockwise)
    amount = math.clamp01(amount)
    if method == FillMethod.Horizontal then
        self:Alloc(4)
        FillUtils.FillHorizontal(origin, amount, vertRect, uvRect, self.vertices, self.uv)
    elseif method == FillMethod.Vertical then
        self:Alloc(4)
        FillUtils.FillVertical(origin, amount, vertRect, uvRect, self.vertices, self.uv)
    elseif method == FillMethod.Radial90 then
        self:Alloc(4)
        FillUtils.FillRadial90(origin, amount, vertRect, uvRect, self.vertices, self.uv)
    elseif method == FillMethod.Radial180 then
        self:Alloc(8)
        FillUtils.FillRadial180(origin, amount, vertRect, uvRect, self.vertices, self.uv)
    elseif method == FillMethod.Radial360 then
        self:Alloc(12)
        FillUtils.FillRadial360(origin, amount, vertRect, uvRect, self.vertices, self.uv)
    end

    self:FillColors(fillColor)
    self:FillTriangles()
end

---@param vertRect Love2DEngine.Rect
---@param uvRect Love2DEngine.Rect
function NGraphics:FillShapeUV(vertRect, uvRect)
    local vertices = self.vertices
    local uv = self.uv

    local len = #vertices
    for i = 1, len do
        uv[i] = Vector2(math.lerp(uvr.xMin, uvRect.xMax, (vertices[i] - vertRect.xMin) / vertRect.width),
        math.lerp(uvRect.yMax, uvRect.yMin, (-vertices[i].y - vertRect.yMin) / vertRect.height))
    end
end

---从当前顶点缓冲区位置开始填入一个矩形的四个顶点
---@param index number
---@param rect Love2DEngine.Rect
function NGraphics:FillVerts(index, rect)
    self.vertices[index] = Vector3(rect.xMin, - rect.yMax, 0)
    self.vertices[index + 1] = Vector3(rect.xMin, - rect.yMin, 0)
    self.vertices[index + 2] = Vector3(rect.xMax, - rect.yMin, 0)
    self.vertices[index + 3] = Vector3(rect.xMax, - rect.yMax, 0)
end

---@param index number
---@param rect Love2DEngine.Rect
function NGraphics:FillUV(index, rect)
    self.uv[index] = Vector2(rect.xMin, rect.yMin)
    self.uv[index + 1] = Vector2(rect.xMin, rect.yMax)
    self.uv[index + 2] = Vector2(rect.xMax, rect.yMax)
    self.uv[index + 3] = Vector2(rect.xMax, rect.yMin)
end

---@param value Love2DEngine.Color|Love2DEngine.Color[]
function NGraphics:FillColors(value)
    local arr = self.colors
    local count = #arr
    if Class.isa(value, Color) then
        local col32 = Color32.FromColor(value)
        for i = 1, count do
            arr[i] = col32
        end
        return
    end
    local count2 = #value
    for i = 1, count do
        arr[i] = value[i % count2]
    end
end

---@param requestSize number
function NGraphics:AllocTriangleArray(requestSize)
    if self.triangles == nil or self.triangles.Length ~= requestSize
            or self.triangles == NGraphics.TRIANGLES
            or self.triangles == NGraphics.TRIANGLES_9_GRID
            or self.triangles == NGraphics.TRIANGLES_4_GRID then
        local triangles = {}
        self.triangles = triangles
        for i = 1, requestSize do
            table.insert(triangles, i, 0)
        end
    end
end

---@param triangles number[]
function NGraphics:FillTriangles(triangles)
    if triangles ~= nil then
         self.triangles = triangles
        return
    end

    local vertCount = #self.vertices
    self:AllocTriangleArray(rshift(vertCount, 1) * 3)

    triangles = self.triangles
    local k = 1
    for i = 1, vertCount, 4 do
        k = k + 1; triangles[k] = i
        k = k + 1; triangles[k] = i + 1
        k = k + 1; triangles[k] = i + 2

        k = k + 1; triangles[k] = i + 2
        k = k + 1; triangles[k] = i + 3
        k = k + 1; triangles[k] = i
    end
end

function NGraphics:ClearMesh()
    if self.vertCount > 0 then
        vertCount = 0
        self.mesh:Clear()
        self.meshFilter.mesh = self.mesh
    end
end

---@param value Love2DEngine.Color
function NGraphics:Tint(value)
    if self.colors == nil or self.vertCount == 0 then
        return
    end

    local value32 = Color32.FromColor(value)
    local count = #self.colors
    for i = 1, count do
        local col = value32
        if col.a ~= 255 then
            if self._alphaBackup == nil then
                self._alphaBackup = {}
            end
        end
        col.a = self._alpha * 255
        self.colors[i] = col
    end

    if self._alphaBackup ~= nil then
        if #self._alphaBackup < self.vertCount then
            self._alphaBackup = {}
        end
        for i = 1, self.vertCount do
            self._alphaBackup[i] = self.colors[i].a
        end
    end
    self.mesh.colors32 = self.colors
end

---@param verts Love2DEngine.Vector3[]
---@param index number
---@param rect Love2DEngine.Rect
function NGraphics.FillVertsOfQuad(verts, index, rect)
    verts[index] = Vector3(rect.xMin, -rect.yMax, 0)
    verts[index + 1] = Vector3(rect.xMin, -rect.yMin, 0)
    verts[index + 2] = Vector3(rect.xMax, -rect.yMin, 0)
    verts[index + 3] = Vector3(rect.xMax, -rect.yMax, 0)
end

---@param uv Love2DEngine.Vector2[]
---@param index number
---@param rect Love2DEngine.Rect
function NGraphics.FillUVOfQuad(uv, index, rect)
    uv[index] = Vector2(rect.xMin, rect.yMin)
    uv[index + 1] = Vector2(rect.xMin, rect.yMax)
    uv[index + 2] = Vector2(rect.xMax, rect.yMax)
    uv[index + 3] = Vector2(rect.xMax, rect.yMin)
end

---@param uv Love2DEngine.Vector2[]
---@param baseUVRect Love2DEngine.Rect
function NGraphics.RotateUV(uv, baseUVRect)
    local vertCount = #uv
    local xMin = math.min(baseUVRect.xMin, baseUVRect.xMax)
    local yMin = baseUVRect.yMin
    local yMax = baseUVRect.yMax
    if yMin > yMax then
        yMin = yMax
        yMax = baseUVRect.yMin
    end

    local tmp
    for i = 1, vertCount do
        local m = uv[i]
        tmp = m.y
        m.y = yMin + m.x - xMin
        m.x = xMin + yMax - tmp
        uv[i] = m
    end
end

--endregion

--region 属性访问器

local __get = Class.init_get(NGraphics)
local __set = Class.init_set(NGraphics)

__get.texture = function(self) return self._texture end
__set.texture = function(self, val)
    if self._texture ~= val then
        self._texture = val
        if self._customMatarial and self._material ~= nil then
            self._material.mainTexture = (self._texture ~= nil and self._texture.nativeTexture or nil)
        end
        self:UpdateManager()
    end
end

__get.shader = function(self) return self._shader end
__set.shader = function(self, val) self._shader = val; self:UpdateManager() end

__get.material = function(self) return self._material end
__set.material = function(self, val)
    self._material = val
    if self._material ~= nil then
        self._customMatarial = true
        self.meshRenderer.sharedMaterial = self._material
        if self._texture ~= nil then
            self._material.mainTexture = self._texture.nativeTexture
        end
    else
        self._customMatarial = false
        self.meshRenderer.sharedMaterial = nil
    end
end

__get.materialKeywords = function(self) return self._materialKeywords end
__set.materialKeywords = function(self, val)
    self._materialKeywords = val
    self:UpdateManager()
end

__get.enabled = function(self) return self.meshRenderer.enabled end
__set.enabled = function(self, val) self.meshRenderer.enabled = val end

__get.sortingOrder = function(self) return self.meshRenderer.sortingOrder end
__set.sortingOrder = function(self, val) self.meshRenderer.sortingOrder = val end

__get.alpha = function(self) return self._alpha end
__set.alpha = function(self, val)
    self._alpha = val
    if self.vertCount > 0 then
        local count = #self.colors
        for i = 1, count do
            local col = self.colors[i]
            col.a = self._alpha * ((self._alphaBackup ~= nil) and self._alphaBackup[i] or 255)
            self.colors[i] = col
        end
        self.mesh.colors32 = self.colors
    end
end

--endregion
--endregion

NGraphics.MeshModifier = MeshModifier
FairyGUI.NGraphics = NGraphics
FairyGUI.StencilEraser = StencilEraser
return NGraphics