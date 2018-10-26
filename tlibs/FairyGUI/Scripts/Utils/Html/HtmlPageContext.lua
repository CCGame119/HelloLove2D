--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/23 15:27
--

local Class = require('libs.Class')
local Pool = require('libs.Pool')

local Transform = Love2DEngine.Transform
local RichTextField = FairyGUI.RichTextField
local Stage = FairyGUI.Stage
local ToolSet = Utils.ToolSet
local IHtmlPageContext = Utils.IHtmlPageContext
local IHtmlObject = Utils.IHtmlObject
local HtmlElement = Utils.HtmlElement
local HtmlElementType = Utils.HtmlElementType
local HtmlImage = Utils.HtmlImage
local HtmlInput = Utils.HtmlInput
local HtmlButton = Utils.HtmlButton
local HtmlSelect = Utils.HtmlSelect
local HtmlLink = Utils.HtmlLink

---@class Utils.HtmlPageContext:Utils.IHtmlPageContext
---@field private _imagePool Pool
---@field private _inputPool Pool
---@field private _buttonPool Pool
---@field private _selectPool Pool
---@field private _linkPool Pool
local HtmlPageContext = Class.inheritsFrom('HtmlPageContext', nil, IHtmlPageContext)

HtmlPageContext.inst = HtmlPageContext.new()
---@type Love2DEngine.Transform
HtmlPageContext._poolManager = nil

function HtmlPageContext:__ctor()
    self._imagePool = Pool.new(HtmlImage)
    self._inputPool = Pool.new(HtmlInput)
    self._buttonPool = Pool.new(HtmlButton)
    self._selectPool = Pool.new(HtmlSelect)
    self._linkPool = Pool.new(HtmlLink)

    if HtmlPageContext._poolManager == nil then
        HtmlPageContext._poolManager = Stage.inst:CreatePoolManager('HtmlObjectPool')
    end
end

---@param owner FairyGUI.RichTextField
---@param element Utils.HtmlElement
---@return Utils.IHtmlObject
function HtmlPageContext:CreateObject(owner, element)
    ---@type Utils.IHtmlObject
    local ret = nil
    local fromPool = false
    if element.type == HtmlElementType.Image then
        if self._imagePool.count > 0 and HtmlPageContext._poolManager ~= nil then
            ret = self._imagePool:pop()
            fromPool = true
        else
            ret = HtmlImage.new()
        end
    elseif element.type == HtmlElementType.Link then
        if self._linkPool.count > 0 and HtmlPageContext._poolManager ~= nil then
            ret = self._linkPool:pop()
            fromPool = true
        else
            return HtmlLink.new()
        end
    elseif element.type == HtmlElementType.Input then
        local type = element:GetString('type')
        if type ~= nil then
            type = string.lower(type)
        end
        if type == 'button' or type == 'submit' then
            if self._buttonPool.count > 0 and HtmlPageContext._poolManager ~= nil then
                ret = self._buttonPool:pop()
                fromPool = true
            else
                ret = HtmlButton.new()
            end
        else
            if self._inputPool.count > 0 and HtmlPageContext._poolManager ~= nil then
                ret = self._inputPool:pop()
                fromPool = true
            else
                ret = HtmlInput.new()
            end
        end
    elseif element.type == HtmlElementType.Select then
        if self._selectPool.count > 0 and HtmlPageContext._poolManager ~= nil then
            ret = self._selectPool:pop()
            fromPool = true
        else
            ret = HtmlSelect.new()
        end
    end

    if ret == nil then
        if fromPool and ret.displayObject ~= nil and ret.displayObject.isDisposed then
             ret:Dispose()
            return self:CreateObject(owner, element)
        end
        ret:Create(owner, element)
        if ret.displayObject ~= nil then
            ret.displayObject.home = owner.cachedTransform
        end
    end

    return ret
end

---@param obj Utils.IHtmlObject
function HtmlPageContext:FreeObject(obj)
    if HtmlPageContext._poolManager == nil then
        obj:Dispose()
        return
    end

    if obj.displayObject ~= nil and obj.displayObject.isDisposed then
        obj:Dispose()
        return
    end

    obj:Release()
    if obj:isa(HtmlImage) then
        self._imagePool:push(obj)
    elseif obj:isa(HtmlInput) then
        self._inputPool:push(obj)
    elseif obj:isa(HtmlButton) then
        self._buttonPool:push(obj)
    elseif obj:isa(HtmlLink) then
        self._linkPool:push(obj)
    end

    if obj.displayObject ~= nil then
        ToolSet.SetParent(obj.displayObject.cachedTransform, HtmlPageContext._poolManager)
    end
end

---@param image Utils.HtmlImage
---@return FairyGUI.NTexture
function HtmlPageContext:GetImageTexture(image)
    return nil
end

---@param image Utils.HtmlImage
---@param texture FairyGUI.NTexture
function HtmlPageContext:FreeImageTexture(image, texture)
end


Utils.HtmlPageContext = HtmlPageContext
return HtmlPageContext