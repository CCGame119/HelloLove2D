--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 15:41
--

local Class = require('libs.Class')

local Object = Love2DEngine.Object

local DisplayOptions = FairyGUI.DisplayOptions
local UpdateContext = FairyGUI.UpdateContext
local BlendMode = FairyGUI.BlendMode
local BlendModeUtils = FairyGUI.BlendModeUtils
local NMaterial = FairyGUI.NMaterial

---@class FairyGUI.MaterialManager:ClassType
---@field private _texture FairyGUI.NTexture
---@field private _shader Love2DEngine.Shader
---@field private _keywords string[]
---@field private _materials FairyGUI.NMaterial[][]
---@field private _managerKey string
local MaterialManager = Class.inheritsFrom('MaterialManager')

---@type string[][]
MaterialManager.internalKeywords = {nil,
    { "GRAYED" },
    { "CLIPPED" },
    { "CLIPPED", "GRAYED" },
    { "SOFT_CLIPPED" },
    { "SOFT_CLIPPED", "GRAYED" },
    { "ALPHA_MASK" }
}

MaterialManager.internalKeywordCount =  7

---@param texture FairyGUI.NTexture
---@param shader Love2DEngine.Shader
---@param keywords string[]
function MaterialManager:__ctor(texture, shader, keywords)
    self._texture = texture
    self._shader = shader
    self._keywords = keywords
    self._materials = {}
end

---@param graphics FairyGUI.NGraphics
---@param context FairyGUI.UpdateContext
function MaterialManager:GetMaterial(graphics, context)
    local frameId = UpdateContext.frameId
    local blendMode = graphics.blendMode
    local collectionIndex
    local clipId

    if context.clipped and not graphics.dontClip then
        clipId = context.clipInfo.clipId

        if graphics.maskFrameId == UpdateContext.frameId then
            collectionIndex = 7
        elseif context.rectMaskDepth == 0 then
            collectionIndex = graphics.grayed and 2 or 1
        else
            if context.clipInfo.soft then
                collectionIndex = graphics.grayed and 6 or 5
            end
        end
    else
        clipId = 0
        collectionIndex = graphics.grayed and 2 or 1
    end

    ---@type FairyGUI.NMaterial[]
    local items = nil
    if blendMode == BlendMode.Normal then
        items = self._materials[collectionIndex]
        if items == nil then
            items = {}
        end
        self._materials[collectionIndex] = items
    else
        items = self._materials[MaterialManager.internalKeywordCount + collectionIndex]
        if items == nil then
            items = {}
        end
        self._materials[MaterialManager.internalKeywordCount + collectionIndex] = items
    end

    local cnt = #items
    ---@type FairyGUI.NMaterial
    local result = nil
    for i = 1, cnt do
        local mat = items[i]
        if mat.frameId == frameId then
            if collectionIndex ~= 7 and mat.clipId == clipId and mat.blendMode == blendMode then
                return mat
            end
        elseif result == nil then
            result = mat
        end
    end

    if result ~= nil then
        result.frameId = frameId
        result.clipId = clipId
        result.blendMode = blendMode
        if result.combined then
            result.material:SetTexture("_AlphaTex", self._texture.alphaTexture)
        end
    else
        result = self:CreateMaterial()
        local keywords = MaterialManager.internalKeywordCount[collectionIndex]
        if keywords ~=nil then
            cnt = #keywords
            for i = 1, cnt do
                result.material:EnableKeyword(keywords[i])
            end
        end
        result.frameId = frameId
        result.clipId = clipId
        result.blendMode = blendMode
        if BlendModeUtils.Factors[result.blendMode].pma then
            result.material:EnableKeyword("COLOR_FILTER")
        end
        table.insert(items, result)
    end
end

function MaterialManager:CreateMaterial()
    ---@type FairyGUI.NMaterial
    local nm = NMaterial.new(self._shader)
    nm.material.mainTexture = self._texture.nativeTexture
    if self._texture.alphaTexture ~= nil then
        nm.combined = true
        nm.material:EnableKeyword("COMBINED")
        nm.material:SetTexture("_AlphaTex", self._texture.alphaTexture)
    end
    if self._keywords ~= nil then
        local cnt = #self._keywords
        for i = 1, cnt do
            nm.material:EnableKeyword(self._keywords[i])
        end
    end
    nm.material.hideFlags = DisplayOptions.hideFlags
    return nm
end

function MaterialManager:DestroyMaterials()
    local cnt = #self._materials
    for i = 1, cnt do
        local items = self._materials[i]
        if items ~= nil then
            local cnt2 = #items
            for j = 1, cnt2 do
                Object.DestroyImmediate(items[j].material)
            end
            self._materials[i] = {}
        end
    end
end

function MaterialManager:RefreshMaterials()
    local cnt = #self._materials
    local hasAlphaTexture = self._texture.alphaTexture ~= nil
    for i = 1, cnt do
        local items = self._materials[i]
        if items ~= nil then
            local cnt2 = #items
            for j = 1, cnt2 do
                local nm = items[j]
                nm.material.mainTexture = self._texture.nativeTexture
                if hasAlphaTexture then
                    if not nm.combined then
                        nm.combined = true
                        nm.material:EnableKeyword("COMBINED")
                    end
                    nm.material:SetTexture("_AlphaTex", self._texture.alphaTexture)
                end
            end
        end
    end
end

function MaterialManager:Release()
    if self._keywords ~= nil then
        self._texture:DestroyMaterialManager(self)
    end
end

FairyGUI.MaterialManager = MaterialManager
return MaterialManager