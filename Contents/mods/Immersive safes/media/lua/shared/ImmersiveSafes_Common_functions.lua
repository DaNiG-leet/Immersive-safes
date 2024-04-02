local defaultModData = require("ImmersiveSafes_DMD")

local a = {}

a.SafesTileList = {
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

a.isSafeOpened = function(safe)
	local spriteName = safe:getTextureName()
    for _, val in pairs(a.SafesTileList) do
        if val['open'] == spriteName then return true end
        if val['close'] == spriteName then return false end
    end
    return nil
end

a.getReversedSprite = function(safe)
	local spriteName = safe:getTextureName()
	for i, val in pairs(a.SafesTileList) do
		if val['open'] == spriteName then return a.SafesTileList[i]['close'] end
		if val['close'] == spriteName then return a.SafesTileList[i]['open'] end
	end
	return nil
end

a.syncModData = function(IsoPlayer, target, key, value)
	a.sendData(IsoPlayer, 'editSafeModData', target, {
		value = value,
		key = key,
	})
end

a.syncAllModData = function(IsoPlayer, target)
	a.sendData(IsoPlayer, 'syncAllModData', target, target:getModData()[defaultModData.modDataKey])
end

a.sendData = function(IsoPlayer, command, target, data)
	if not isClient() then return end
	local args = a.getTargetData(target)
	args.data = data
	sendClientCommand(IsoPlayer or getPlayer(), 'SafesModule', command, args)
end

a.setModData = function(player, safe)
	if not safe:getModData()[defaultModData.modDataKey] then
		safe:getModData()[defaultModData.modDataKey] = copyTable(defaultModData.modData)
		safe:getModData()[defaultModData.modDataKey].SAFEID = ZombRand(4000, 10000)
		a.syncAllModData(player, safe)
	end
end

a.getTarget = function(x, y, z, target)
    local cell = getCell()
	local currentGridSquare = cell:getGridSquare(x, y, z)
	if currentGridSquare then
		for i = 0, currentGridSquare:getObjects():size() - 1, 1 do
			local item = currentGridSquare:getObjects():get(i)
			if item and item:getSprite() and item:getSprite():getName() == target then
                return item
            end
		end
	end
    return nil
end

a.isWallSafe = function(value)
	for key, val in pairs(a.SafesTileList) do
		if val['open'] == value or val['close'] == value then return val.wallSafe end
	end
	return false
end

a.getTime = function()
    local GAME_TIME = getGameTime()
    return {
        y = GAME_TIME:getYear(),
        mo = GAME_TIME:getMonth() + 1,
        d = GAME_TIME:getDayPlusOne(),
        h = GAME_TIME:getHour(),
        mi = GAME_TIME:getMinutes(),
    }
end

a.getTargetData = function(target)
	local t = {}
	local sq = target:getSquare()
    t.x = sq:getX()
    t.y = sq:getY()
    t.z = sq:getZ()
    t.target = target:getSprite():getName()
	return t
end

a.updatePasswordHint = function(playerObj, target)
    if not playerObj:getModData()[defaultModData.modDataKey] then
        playerObj:getModData()[defaultModData.modDataKey] = {}
    end
    playerObj:getModData()[defaultModData.modDataKey][target:getModData()[defaultModData.modDataKey].SAFEID] = target:getModData()[defaultModData.modDataKey].password
end

a.getPasswordHint = function(playerObj, target)
    if not playerObj:getModData()[defaultModData.modDataKey] then
        playerObj:getModData()[defaultModData.modDataKey] = {}
		return nil
    end
	return playerObj:getModData()[defaultModData.modDataKey][target:getModData()[defaultModData.modDataKey].SAFEID]
end

return a