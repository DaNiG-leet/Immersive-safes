if not isServer() then return end

local ImmersiveSafes = {
    utilities = require("ImmersiveSafes_Common_functions"),
    logFileName = 'safesChanging',
    modDataKey = require("ImmersiveSafes_DMD").modDataKey
}

ImmersiveSafes.Module = 'SafesModule'

ImmersiveSafes.writeLog = function(IsoPlayer, target, message)
    local str = target and (target:getX() .. ' ' .. target:getY() .. ' ' .. target:getZ() .. ' ' .. target:getSprite():getName() .. ' ' .. IsoPlayer:getUsername() .. ' ' .. message) or IsoPlayer:getUsername() .. ' ' .. message
    writeLog(ImmersiveSafes.logFileName, str)
end

ImmersiveSafes.syncSpecificModData = function(target, key, value)
    local args = ImmersiveSafes.utilities.getTargetData(target)
    args.data = {
        key = key,
        value = value
    }
    sendServerCommand(ImmersiveSafes.Module, 'syncSpecificModData', args)
end

ImmersiveSafes.sendToAllModData = function(target, modData)
    local args = ImmersiveSafes.utilities.getTargetData(target)
	args.modData = modData
    sendServerCommand(ImmersiveSafes.Module, 'syncAllModData', args)
end

ImmersiveSafes.commands = {}

ImmersiveSafes.commands.setFingerPrint = function(target, playerObj, args)
    local targetPrints = target:getModData()[ImmersiveSafes.modDataKey].fprints
    if #targetPrints > 200 then
        table.remove(targetPrints, 1)
    end
    table.insert(targetPrints, {
        t = ImmersiveSafes.utilities.getTime(),
        n = playerObj:getUsername(),
        c = {
            x = target:getX(),
            y = target:getY(),
            z = target:getZ(),
        }
    })
    ImmersiveSafes.syncSpecificModData(target, 'fprints', target:getModData()[ImmersiveSafes.modDataKey].fprints)
end

ImmersiveSafes.commands.AdminForceOpen = function(target, playerObj, args)
    ImmersiveSafes.writeLog(playerObj, target, 'forced open the safe')
end

ImmersiveSafes.commands.ChangeThumpHP = function(target, playerObj, args)
    if instanceof(target, "IsoThumpable") then
        target:setMaxHealth(10000)
        target:setHealth(10000)
        ImmersiveSafes.writeLog(playerObj, target, 'set 10000 hp')
    end
end

ImmersiveSafes.commands.editSafeModData = function(target, playerObj, args)
    local data = args.data
    if data.key == 'password' then
        ImmersiveSafes.writeLog(playerObj, target, 'set new pass. Old: ' .. tostring(target:getModData()[ImmersiveSafes.modDataKey][data.key]) .. ' new: ' .. data.value)
    end
    target:getModData()[ImmersiveSafes.modDataKey][data.key] = data.value
    ImmersiveSafes.syncSpecificModData(target, data.key, data.value)
end

ImmersiveSafes.commands.syncAllModData = function(target, playerObj, args)
    target:getModData()[ImmersiveSafes.modDataKey] = args.data
    ImmersiveSafes.sendToAllModData(target, args.data)
end

ImmersiveSafes.OnClientCommand = function(module, command, playerObj, args)
    if module ~= ImmersiveSafes.Module then return end
    if ImmersiveSafes.commands[command] then
        local target = ImmersiveSafes.utilities.getTarget(args.x, args.y, args.z, args.target)
        if target then
            if instanceof(target, "IsoThumpable") then
				target:setMaxHealth(10000)
				target:setHealth(10000)
			end
            ImmersiveSafes.commands[command](target, playerObj, args)
        else
            ImmersiveSafes.writeLog(playerObj, target, 'Error. Target ' .. args.target .. ' has not been found. X: ' .. args.x .. ' Y: ' .. args.y .. ' Z: ' .. args.z)
        end
    end
end

Events.OnClientCommand.Add(ImmersiveSafes.OnClientCommand)