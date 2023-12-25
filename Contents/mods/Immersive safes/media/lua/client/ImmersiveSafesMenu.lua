if not isClient() then return end
--Immersive safes
--Coded by DaNiG
--TODO: Make compobility with mod on lockpicking

local ImmersiveSafes = {}
---A list of all possible safes.
local VaultTileList = {
	{
		close = 'safes_01_0',
		open = 'safes_01_2'
	},
	{
		close = 'safes_01_1',
		open = 'safes_01_3'
	},
	{
		close = 'safes_01_4',
		open = 'safes_01_6'
	},
	{
		close = 'safes_01_5',
		open = 'safes_01_7'
	},
	{
		close = 'safes_01_8',
		open = 'safes_01_10'
	},
	{
		close = 'safes_01_9',
		open = 'safes_01_11'
	},
	{
		close = 'safes_01_12',
		open = 'safes_01_14'
	},
	{
		close = 'safes_01_13',
		open = 'safes_01_15'
	},
	{
		close = 'safes_01_16',
		open = 'safes_01_18',
        wallSafe = true,
	},
	{
		close = 'safes_01_17',
		open = 'safes_01_19',
        wallSafe = true,
	},
	{
		close = 'safes_01_20',
		open = 'safes_01_22',
        wallSafe = true,
	},
	{
		close = 'safes_01_21',
		open = 'safes_01_23',
        wallSafe = true,
	},
	{
		close = 'safes_01_24',
		open = 'safes_01_26',
        wallSafe = true,
	},
	{
		close = 'safes_01_25',
		open = 'safes_01_27',
        wallSafe = true,
	},
	{
		close = 'safes_01_28',
		open = 'safes_01_30',
        wallSafe = true,
	},
	{
		close = 'safes_01_29',
		open = 'safes_01_31',
        wallSafe = true,
	},
	{
		close = 'safes_01_32',
		open = 'safes_01_33'
	},
	{
		close = 'safes_01_34',
		open = 'safes_01_35'
	},
}

local squareOffsetIsoDirections = {
    ['S'] = {
        ['X'] = 0,
        ['Y'] = 1 
    },
    ['E'] = {
        ['X'] = 1,
        ['Y'] = 0 
    },
    ['N'] = {
        ['X'] = 0,
        ['Y'] = -1 
    },
    ['W'] = {
        ['X'] = -1,
        ['Y'] = 0 
    },
}

---Returns the opposite name of the sprite. If it is not a safe, returns nil.
---@param value string
---@return string|nil
function ImmersiveSafes.checkVaultSprite(value)
    for key, val in pairs(VaultTileList) do
        if val['open'] == value then return VaultTileList[key]['close'] end
        if val['close'] == value then return VaultTileList[key]['open'] end
    end
    return nil
end

---Checks to see if the safe is a wall safe.
---@param value string
---@return boolean
function ImmersiveSafes.isWallSafe(value)
    for key, val in pairs(VaultTileList) do
        if val['open'] == value or val['close'] == value then return val.wallSafe end
    end
    return false
end

---Checks to see if the safe is open.
---@param value string
---@return boolean|nil
function ImmersiveSafes.isVaultOpen(value)
    for key, val in pairs(VaultTileList) do
        if val['open'] == value then return true end
        if val['close'] == value then return false end
    end
    return nil
end

---Uploads "fingerprints" to the parsingFingers.ini file
---@param vaultObj IsoObject
function ImmersiveSafes.getPrints(vaultObj)
    local writer = getFileWriter("parsingFingers.ini", true, false)
    local modData = vaultObj:getModData()['fprints'] or {}
    for k, v in pairs(modData) do
        local str = k .. ' : ' .. '\n' .. '   '
        for _, t in pairs(v) do str = str .. t .. '\n' .. '   ' end
        writer:write(str .. '\n')
    end
    local GAME_TIME = getGameTime()
    local str = 'World time at the time of writing: Year: ' .. GAME_TIME:getYear() .. ', Month: ' .. GAME_TIME:getMonth() + 1 .. ', Day: ' .. GAME_TIME:getDayPlusOne() .. ', Hour: ' .. GAME_TIME:getHour() .. ', Minute: ' .. GAME_TIME:getMinutes()
    writer:write(str)
    writer:close()
    getPlayer():addLineChatElement('The list of players is uploaded to parsingFingers.ini in the lua folder.', 1, 1, 1)
end

---Records the player's "fingerprint" in the safe.
---@param vaultObj IsoObject
function ImmersiveSafes.setFingerPrint(vaultObj)
    if isAdmin() then return end
    local GAME_TIME = getGameTime()
    local obj = {}
    obj.nick = getPlayer():getUsername()
    obj.time = 'Year: ' .. GAME_TIME:getYear() .. ', Month: ' .. GAME_TIME:getMonth() + 1 .. ', Day: ' .. GAME_TIME:getDayPlusOne() .. ', Hour: ' .. GAME_TIME:getHour() .. ', Minute: ' .. GAME_TIME:getMinutes()
    ImmersiveSafes.syncModData(vaultObj, 'fprints', obj)
end

---Causes timed action interactions with the safe.
---@param playerObj IsoPlayer
---@param target IsoObject
---@param actionFunc Function
---@param actionStr string
---@param pass string
function ImmersiveSafes.CommonSafeAction(playerObj, target, actionFunc, actionStr, pass)
    local playerSquare = playerObj:getCurrentSquare()
    local safeSquare = target:getSquare()
    local props = target:getProperties()
    local dir = props:Is("Facing") and props:Val("Facing")
    if dir and not ImmersiveSafes.isWallSafe(target:getTextureName()) then
        local offset = squareOffsetIsoDirections[dir]
        safeSquare = getCell():getGridSquare(safeSquare:getX() + offset.X, safeSquare:getY() + offset.Y, safeSquare:getZ())
        local adjacent = AdjacentFreeTileFinder.FindEdge(safeSquare, dir, playerObj, true)
        if adjacent then
            if adjacent ~= playerSquare then
                ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, adjacent))
            end
            ISTimedActionQueue.add(InteractionWithSafeAction:new(playerObj, target, actionFunc, actionStr, pass))
        else
            getPlayer():addLineChatElement(getText('UI_cant_get_door'), 1, 0, 0)
        end
        return
    end
    local walk = luautils.walkAdj(playerObj, safeSquare)
    if safeSquare and walk then
		ISTimedActionQueue.add(InteractionWithSafeAction:new(playerObj, target, actionFunc, actionStr, pass))
    elseif not walk then
        getPlayer():addLineChatElement(getText('UI_cant_get_door'), 1, 0, 0)
	end
end

---Approach and invoke the safe interaction UI to set the password.
---@param playerObj IsoPlayer
---@param target IsoObject
function ImmersiveSafes.OnSetUpSafePasswordUI(playerObj, target)
    ImmersiveSafes.CommonSafeAction(playerObj, target, ImmersiveSafes.OnSetupSafePassword, 'setUpPasswordUI')
end

---Approach and set the password set in the UI for the safe.
---@param playerObj IsoPlayer
---@param target IsoObject
---@param pass string
function ImmersiveSafes.OnSetupSafePassword(playerObj, target, pass)
    ImmersiveSafes.CommonSafeAction(playerObj, target, ImmersiveSafes.SetUpSafePassword, 'setUpPassword', pass)
end

---Approach and call the UI to enter the safe's password.
---@param playerObj IsoPlayer
---@param target IsoObject
---@param pass string
function ImmersiveSafes.OnEnterSafePassword(playerObj, target, pass)
    ImmersiveSafes.CommonSafeAction(playerObj, target, ImmersiveSafes.OnOpenSafe, 'enterPassword')
end

---Go over and open the safe.
---@param playerObj IsoPlayer
---@param target IsoObject
---@param pass string
function ImmersiveSafes.OnOpenSafe(playerObj, target, pass)
    ImmersiveSafes.CommonSafeAction(playerObj, target, ImmersiveSafes.OpenSafe, 'open', pass)
end

---Go over and close the safe.
---@param playerObj IsoPlayer
---@param target IsoObject
function ImmersiveSafes.OnCloseSafe(playerObj, target)
    ImmersiveSafes.CommonSafeAction(playerObj, target, ImmersiveSafes.CloseSafe, 'close')
end

---Opens the safe.
---@param str string
---@param target IsoObject
function ImmersiveSafes.OpenSafe(str, target)
    if target:getModData()['password'] == str then
        getPlayer():addLineChatElement(getText('UI_safe_opened'), 1, 0, 0)
        local checkV = target:getSprite():getName()
        local reversedV = ImmersiveSafes.checkVaultSprite(checkV)
        target:setSpriteFromName(reversedV)
        target:transmitUpdatedSpriteToServer()
        ImmersiveSafes.syncModData(target, 'Locked', false)
    else
        getPlayer():addLineChatElement(getText('UI_incorrect_code'), 1, 0, 0)
    end
    ImmersiveSafes.setFingerPrint(target)
end

---Set a new password.
---@param player IsoPlayer
---@param target IsoObject
---@param str string
function ImmersiveSafes.SetUpSafePassword(player, target, str)
    ImmersiveSafes.setFingerPrint(target)
    ImmersiveSafes.syncModData(target, 'password', str)
end

---Close the safe.
---@param target IsoObject
function ImmersiveSafes.CloseSafe(target)
    local checkV = target:getSprite():getName()
    local reversedV = ImmersiveSafes.checkVaultSprite(checkV)
    target:setSpriteFromName(reversedV)
    target:transmitUpdatedSpriteToServer()
    ImmersiveSafes.setFingerPrint(target)
    ImmersiveSafes.syncModData(target, 'Locked', true)
    getPlayer():addLineChatElement(getText('UI_safe_closed'), 1, 0, 0)
end

---ADMIN TOOL: Force open the safe.
---@param target IsoObject
function ImmersiveSafes.AdminOpenSafe(target)
    local args = {}
    local sq = target:getSquare()
    args.emmitor = getPlayer():getUsername()
    args.str = 'forcibly opened the safe. Coordinates: ' .. sq:getX() .. ', ' .. sq:getY() .. ', ' .. sq:getZ() .. ' . Sprite name: ' .. tostring(target:getTextureName())
    ImmersiveSafes.AdminLoging(args)
    ImmersiveSafes.OpenSafe(target:getModData()['password'], target)
end

---Logging the administration's actions on the server.
---@param args table
function ImmersiveSafes.AdminLoging(args)
    sendClientCommand(getPlayer(), 'SafesModule', 'AdminLoging', args)
end

---ADMIN TOOL: Sets the HP of the IsoThumpable safe to 10000.
---@param target IsoObject
function ImmersiveSafes.AdminChangeHP(target)
    local args = {}
    local sq = target:getSquare()
    args.x = sq:getX()
    args.y = sq:getY()
    args.z = sq:getZ()
    args.target = target:getSprite():getName()
    sendClientCommand(getPlayer(), 'SafesModule', 'ChangeThumpHP', args)
end

---Adds context menu items for the safe.
---@param player IsoPlayer
---@param context ISContextMenu
---@param objects table
---@param test boolean
function ImmersiveSafes.ContextMenu(player, context, objects, test)
    local sq
    local playerObj = getSpecificPlayer(player)
    for i, v in ipairs(objects) do
        local square = v:getSquare()
        if square and not sq then
            sq = square
            if v:getTextureName() and luautils.stringStarts(v:getTextureName(), "safes_01") then
                ImmersiveSafes.playerObj = playerObj
                local checkV = v:getTextureName()
                if not ImmersiveSafes.checkVaultSprite(checkV) then return end

                if ImmersiveSafes.isVaultOpen(checkV) == false and v:getModData()['password'] then
                    context:addOption(getText('ContextMenu_Open_Safe'), ImmersiveSafes.playerObj, ImmersiveSafes.OnEnterSafePassword, v).iconTexture = getTexture("media/ui/safe.png")
                elseif ImmersiveSafes.isVaultOpen(checkV) and v:getModData()['password'] then
                    context:addOption(getText('ContextMenu_Close_Safe'), ImmersiveSafes.playerObj, ImmersiveSafes.OnCloseSafe, v).iconTexture = getTexture("media/ui/safe.png")
                end
                
                if ImmersiveSafes.isVaultOpen(checkV) then context:addOption(getText('ContextMenu_Set_Up_New_Password_Safe'), ImmersiveSafes.playerObj, ImmersiveSafes.OnSetUpSafePasswordUI, v).iconTexture = getTexture("media/ui/safe.png") end

                if isAdmin() then
                    local adminSafeOptions = context:addOption("Admin Safe Options")
                    adminSafeOptions.iconTexture = getTexture("media/ui/BugIcon.png")
                    local subMenu = ISContextMenu:getNew(context)
                    context:addSubMenu(adminSafeOptions, subMenu)
                    subMenu:addOption('[ADM] ' .. "Vault: " .. i .. " get fingerprints", v, ImmersiveSafes.getPrints)
                    if ImmersiveSafes.isVaultOpen(checkV) == false then subMenu:addOption('[ADM] ' .. "Vault: " .. i .. " force open", v, ImmersiveSafes.AdminOpenSafe) end
                    if instanceof(v, "IsoThumpable") then
                        subMenu:addOption('[ADM] ' .. "Vault: " .. i .. " set 10000 HP", v, ImmersiveSafes.AdminChangeHP)
                    end
                end
            end
        end
    end
end

---Synchronizes modData with the server.
---@param target IsoObject
---@param key string
---@param value any
function ImmersiveSafes.syncModData(target, key, value)
    local args = {}
    local sq = target:getSquare()
    args.x = sq:getX()
    args.y = sq:getY()
    args.z = sq:getZ()
    args.target = target:getSprite():getName()
    args.value = value
    args.key = key
    sendClientCommand(getPlayer(), 'SafesModule', 'editSafeModData', args)
end

---Writes modData to a specific object.
---@param IsoObject IsoObject
---@param modData KahluaTable
function ImmersiveSafes.setModData(IsoObject, modData)
    local isoObjectModData = IsoObject:getModData()
    for k, v in pairs(modData) do isoObjectModData[k] = v end
    getPlayerLoot(0):refreshBackpacks()
end

local function onServerCommand(module, command, args)
    if module ~= 'SafesModule' then return end

    if command == 'editSafeModData' then
        local currentGridSquare = getCell():getGridSquare(args.x, args.y, args.z)
        if not currentGridSquare or not currentGridSquare:getObjects() or currentGridSquare:getObjects():isEmpty() then
            return
        end
        local objects = currentGridSquare:getObjects()
        for i = objects:size() - 1, 0, -1 do
            local item = objects:get(i)
            if not item then
                return
            end
            local itemSprite = item:getSprite()
            if not itemSprite then
                return
            end
            local spriteName = itemSprite:getName()
            if not spriteName then
                return
            end
            if item and item:getSprite() and item:getSprite():getName() and item:getSprite():getName() == args.target then
                ImmersiveSafes.setModData(item, args.moddata)
                if args.key == 'password' and getPlayer():getUsername() == args.sender then getPlayer():addLineChatElement(getText('UI_password_set', tostring(item:getModData()['password'])), 1, 0, 0) end
                break
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ImmersiveSafes.ContextMenu)
Events.OnServerCommand.Add(onServerCommand)