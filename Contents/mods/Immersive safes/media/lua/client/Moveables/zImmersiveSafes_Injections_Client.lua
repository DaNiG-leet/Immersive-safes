local utilities = require("ImmersiveSafes_Common_functions")
local modDataKay = require("ImmersiveSafes_DMD").modDataKey

local old_ISInventoryPage_setNewContainer = ISInventoryPage.setNewContainer
local old_ISMoveableSpriteProps_pickUpMoveableInternal = ISMoveableSpriteProps.pickUpMoveableInternal
local old_ISMoveableSpriteProps_placeMoveableInternal = ISMoveableSpriteProps.placeMoveableInternal
local old_ISInventoryPaneContextMenu_getContainers = ISInventoryPaneContextMenu.getContainers
local old_ISCraftingUI_getContainers = ISCraftingUI.getContainers
local old_IsoObject_new = IsoObject.new
local modDataBuffer = {}

local function OnRefreshInventoryWindowContainers(inventoryPage, type)
    if isAdmin() then return end
    if type == 'buttonsAdded' then
        for _, v in pairs(inventoryPage.backpacks) do
            if v.inventory and v.inventory:getParent() and instanceof(v.inventory:getParent(), "IsoObject") and utilities.isSafeOpened(v.inventory:getParent()) == false then
                v.onclick = nil
                v.onmousedown = nil
                v:setOnMouseOverFunction(nil)
                v:setOnMouseOutFunction(nil)
                v.textureOverride = getTexture("media/ui/lock.png")
            end
        end
    end
    if type == 'end' then
        if inventoryPage.inventory:getParent() and instanceof(inventoryPage.inventory:getParent(), "IsoObject") and utilities.isSafeOpened(inventoryPage.inventory:getParent()) == false then
            inventoryPage.inventoryPane.lastinventory = inventoryPage.backpacks[#inventoryPage.backpacks].inventory
            inventoryPage:selectContainer(inventoryPage.backpacks[#inventoryPage.backpacks])
        end
    end
end

Events.OnRefreshInventoryWindowContainers.Add(OnRefreshInventoryWindowContainers)

function ISInventoryPage:setNewContainer(inventory)
    if isAdmin() then
        old_ISInventoryPage_setNewContainer(self, inventory)
        return
    end
    if inventory:getParent() and instanceof(inventory:getParent(), "IsoObject") and utilities.isSafeOpened(inventory:getParent()) == false then return end
    old_ISInventoryPage_setNewContainer(self, inventory)
end

function ISMoveableSpriteProps:pickUpMoveableInternal(_character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating)
    if not luautils.stringStarts(_spriteName, "safes_01") then return old_ISMoveableSpriteProps_pickUpMoveableInternal(self, _character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating) end
    local returnedItem = old_ISMoveableSpriteProps_pickUpMoveableInternal(self, _character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating)
    returnedItem:getModData()[modDataKay] = _object:getModData()[modDataKay]
    return returnedItem
end

function ISMoveableSpriteProps:placeMoveableInternal(_square, _item, _spriteName)
    if type(_spriteName) == 'string' and luautils.stringStarts(_spriteName, "safes_01") and _item:getModData()[modDataKay] then
        modDataBuffer = _item:getModData()[modDataKay]
        old_ISMoveableSpriteProps_placeMoveableInternal(self, _square, _item, _spriteName)
        return
    end
    old_ISMoveableSpriteProps_placeMoveableInternal(self, _square, _item, _spriteName)
end

function IsoObject.new(_cell, _square, itemSprite)
    if not type(itemSprite) == 'string' or (type(itemSprite) == 'string' and not luautils.stringStarts(itemSprite, "safes_01")) then return old_IsoObject_new(_cell, _square, itemSprite) end
    local obj = old_IsoObject_new(_cell, _square, itemSprite)
    obj:getModData()[modDataKay] = modDataBuffer
    modDataBuffer = {}
    return obj
end

ISInventoryPaneContextMenu.getContainers = function(...)
    local containers = old_ISInventoryPaneContextMenu_getContainers(...)
    local array = ArrayList.new()
    for i = 0, containers:size() - 1 do
        local itemContainer = containers:get(i)
        if itemContainer then
            local parent = itemContainer:getParent()
            if not parent or not instanceof(parent, "IsoObject") or not luautils.stringStarts(parent:getTextureName(), "safes_01") or utilities.isSafeOpened(parent) == true then array:add(itemContainer) end
        end
    end
    return array
end

function ISCraftingUI:getContainers()
    old_ISCraftingUI_getContainers(self)
    local array = ArrayList.new()
    for i = 0, self.containerList:size() - 1 do
        local itemContainer = self.containerList:get(i)
        local parent = itemContainer:getParent()
        if not parent or not instanceof(parent, "IsoObject") or not luautils.stringStarts(parent:getTextureName(), "safes_01") or utilities.isSafeOpened(parent) == true then
            array:add(itemContainer)
        end
    end

    self.containerList = array
end