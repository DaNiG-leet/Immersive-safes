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
            if v.inventory and v.inventory:getParent() and v.inventory:getParent():getModData() and v.inventory:getParent():getModData()['Locked'] then
                v.onclick = nil
                v.onmousedown = nil
                v:setOnMouseOverFunction(nil)
                v:setOnMouseOutFunction(nil)
                v.textureOverride = getTexture("media/ui/lock.png")
            end
        end
    end
    if type == 'end' then if inventoryPage.inventory:getParent() and inventoryPage.inventory:getParent():getModData() and inventoryPage.inventory:getParent():getModData()['Locked'] then inventoryPage:selectContainer(inventoryPage.backpacks[#inventoryPage.backpacks]) end end
end

Events.OnRefreshInventoryWindowContainers.Add(OnRefreshInventoryWindowContainers)

function ISInventoryPage:setNewContainer(inventory)
    if isAdmin() then
        old_ISInventoryPage_setNewContainer(self, inventory)
        return
    end
    if inventory:getParent() and inventory:getParent():getModData() and inventory:getParent():getModData()['Locked'] then return end
    old_ISInventoryPage_setNewContainer(self, inventory)
end

function ISMoveableSpriteProps:pickUpMoveableInternal(_character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating)
    if not luautils.stringStarts(_spriteName, "safes_01") then return old_ISMoveableSpriteProps_pickUpMoveableInternal(self, _character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating) end
    local returnedItem = old_ISMoveableSpriteProps_pickUpMoveableInternal(self, _character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating)
    for k, v in pairs(_object:getModData()) do
        returnedItem:getModData()[k] = v
    end
    return returnedItem
end

function ISMoveableSpriteProps:placeMoveableInternal(_square, _item, _spriteName)
    if type(_spriteName) == 'string' and luautils.stringStarts(_spriteName, "safes_01") then
        for k, v in pairs(_item:getModData()) do
            print(k .. ' ' .. tostring(v))
            modDataBuffer[k] = v
        end
        old_ISMoveableSpriteProps_placeMoveableInternal(self, _square, _item, _spriteName)
        return
    end
    old_ISMoveableSpriteProps_placeMoveableInternal(self, _square, _item, _spriteName)
end

function IsoObject.new(_cell, _square, itemSprite)
    if not type(itemSprite) == 'string' or (type(itemSprite) == 'string' and not luautils.stringStarts(itemSprite, "safes_01")) then return old_IsoObject_new(_cell, _square, itemSprite) end
    local obj = old_IsoObject_new(_cell, _square, itemSprite)
    local modData = obj:getModData()
    for k, v in pairs(modDataBuffer) do
        modData[k] = v
    end
    return obj
end

ISInventoryPaneContextMenu.getContainers = function(...)
    local containers = old_ISInventoryPaneContextMenu_getContainers(...)
    local array = ArrayList.new()
    for i = 0, containers:size() - 1 do
        local itemContainer = containers:get(i)
        local parent = itemContainer:getParent()
        if not parent or not parent:getModData() or not parent:getModData()['Locked'] then array:add(itemContainer) end
    end

    return array
end

function ISCraftingUI:getContainers()
    old_ISCraftingUI_getContainers(self)
    local array = ArrayList.new()
    for i = 0, self.containerList:size() - 1 do
        local itemContainer = self.containerList:get(i)
        local parent = itemContainer:getParent()
        if not parent or not parent:getModData() or not parent:getModData()['Locked'] then
            array:add(itemContainer)
        end
    end

    self.containerList = array
end
