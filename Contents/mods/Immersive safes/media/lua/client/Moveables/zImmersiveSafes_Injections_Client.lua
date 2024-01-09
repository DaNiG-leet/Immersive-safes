local old_fn1 = ISInventoryPage.setNewContainer
local oldFn_2 = ISMoveableSpriteProps.pickUpMoveableInternal
local oldFn_3 = ISMoveableSpriteProps.placeMoveableInternal
local oldFn_4 = ISInventoryPaneContextMenu.getContainers
local oldFn_5 = ISCraftingUI.getContainers
local IsoObject_new = IsoObject.new
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
        old_fn1(self, inventory)
        return
    end
    if inventory:getParent() and inventory:getParent():getModData() and inventory:getParent():getModData()['Locked'] then return end
    old_fn1(self, inventory)
end

function ISMoveableSpriteProps:pickUpMoveableInternal(_character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating)
    if not luautils.stringStarts(_spriteName, "safes_01") then return oldFn_2(self, _character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating) end
    local returnedItem = oldFn_2(self, _character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating)
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
        oldFn_3(self, _square, _item, _spriteName)
        return
    end
    oldFn_3(self, _square, _item, _spriteName)
end

function IsoObject.new(_cell, _square, itemSprite)
    if not type(itemSprite) == 'string' or (type(itemSprite) == 'string' and not luautils.stringStarts(itemSprite, "safes_01")) then return IsoObject_new(_cell, _square, itemSprite) end
    local obj = IsoObject_new(_cell, _square, itemSprite)
    local modData = obj:getModData()
    for k, v in pairs(modDataBuffer) do
        modData[k] = v
    end
    return obj
end

ISInventoryPaneContextMenu.getContainers = function(...)
    local containers = oldFn_4(...)
    local array = ArrayList.new()
    for i = 0, containers:size() - 1 do
        local itemContainer = containers:get(i)
        local parent = itemContainer:getParent()
        if not parent or not parent:getModData() or not parent:getModData()['Locked'] then array:add(itemContainer) end
    end

    return array
end

function ISCraftingUI:getContainers()
    oldFn_5(self)
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
