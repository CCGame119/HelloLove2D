--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2019/1/24 16:01
--

local Class = require('libs.Class')
local Delegate = require('libs.Delegate')

local UIPackage = FairyGUI.UIPackage
local Stats = FairyGUI.Stats
local PackageItem = FairyGUI.PackageItem
local ObjectType = FairyGUI.ObjectType

---@class FairyGUI.UIObjectFactory:ClassType
local UIObjectFactory = FairyGUI.UIObjectFactory

---@type table<string, FairyGUI.UIObjectFactory.GComponentCreator>
UIObjectFactory.packageItemExtensions = {}
---@type FairyGUI.UIObjectFactory.GLoaderCreator
UIObjectFactory.loaderCreator = nil
---@type table<string, FairyGUI.UIObjectFactory.GLoaderCreator>
UIObjectFactory.defaultLoaderCreators = {}
---@type table<string, FairyGUI.UIObjectFactory.GComponentCreator>
UIObjectFactory.defaultCreators = {}

---@overload fun(url:string, creator:FairyGUI.UIObjectFactory.GComponentCreator)
---@param url string
---@param type ClassType
function UIObjectFactory.SetPackageItemExtension(url, type)
    local creator = nil
    if not Class.isa(type, GComponentCreator) then
        creator = UIObjectFactory.defaultCreators[type:clsName()]
        if nil == creator then
            creator = GComponentCreator.new(function() return type.new() end)
            UIObjectFactory.defaultCreators[type:clsName()] = creator
        end
    else
        creator = type
    end

    if url == nil then
        error("Invaild url: " .. url)
    end

    local pi = UIPackage.GetItemByURL(url)
    if pi ~= nil then
        pi.extensionCreator = creator
    end
    UIObjectFactory.packageItemExtensions[url] = creator
end

---@overload fun(creator:FairyGUI.UIObjectFactory.GLoaderCreator)
---@param type ClassType
function UIObjectFactory.SetLoaderExtension(type)
    local creator = nil
    if not Class.isa(type, GLoaderCreator) then
        creator = UIObjectFactory.defaultLoaderCreators[type:clsName()]
        if nil == creator then
            creator = GLoaderCreator.new(function() return type.new() end)
            UIObjectFactory.defaultLoaderCreators[type:clsName()] = creator
        end
    else
        creator = type
    end

    UIObjectFactory.loaderCreator = creator
end

---@param pi FairyGUI.PackageItem
function UIObjectFactory.ResolvePackageItemExtension(pi)
    pi.extensionCreator = UIObjectFactory.packageItemExtensions[UIPackage.URL_PREFIX .. pi.owner.id .. pi.id]
            or UIObjectFactory.packageItemExtensions[UIPackage.URL_PREFIX .. pi.owner.name .. "/" .. pi.name]
end

function UIObjectFactory.Clear()
    UIObjectFactory.packageItemExtensions = {}
    UIObjectFactory.loaderCreator = nil
end

---@overload fun(type:FairyGUI.ObjectType):FairyGUI.GObject
---@param pi FairyGUI.PackageItem
---@return FairyGUI.GObject
function UIObjectFactory.NewObject(pi)
    local type = nil
    if pi:isa(PackageItem) then
        if pi.extensionCreator ~= nil then
            Stats.LatestObjectCreation = Stats.LatestObjectCreation + 1
            return pi.extensionCreator()
        else
            type = pi.objectType
        end
    else
        type = pi
    end

    Stats.LatestObjectCreation = Stats.LatestObjectCreation + 1

    if type == ObjectType.Image then
        return FairyGUI.GImage.new()

    elseif type == ObjectType.MovieClip then
        return FairyGUI.GMovieClip.new()

    elseif type == ObjectType.Component then
        return FairyGUI.GComponent.new()

    elseif type == ObjectType.Text then
        return FairyGUI.GTextField.new()

    elseif type == ObjectType.RichText then
        return FairyGUI.GRichTextField.new()

    elseif type == ObjectType.InputText then
        return FairyGUI.GTextInput.new()

    elseif type == ObjectType.Group then
        return FairyGUI.GGroup.new()

    elseif type == ObjectType.List then
        return FairyGUI.GList.new()

    elseif type == ObjectType.Graph then
        return FairyGUI.GGraph.new()

    elseif type == ObjectType.Loader then
        if (UIObjectFactory.loaderCreator ~= nil) then
            return UIObjectFactory.loaderCreator()
        else
            return FairyGUI.GLoader.new()
        end
    elseif type == ObjectType.Button then
        return FairyGUI.GButton.new()

    elseif type == ObjectType.Label then
        return FairyGUI.GLabel.new()

    elseif type == ObjectType.ProgressBar then
        return FairyGUI.GProgressBar.new()

    elseif type == ObjectType.Slider then
        return FairyGUI.GSlider.new()

    elseif type == ObjectType.ScrollBar then
        return FairyGUI.GScrollBar.new()

    elseif type == ObjectType.ComboBox then
        return FairyGUI.GComboBox.new()

    else
        return nil
    end
end
