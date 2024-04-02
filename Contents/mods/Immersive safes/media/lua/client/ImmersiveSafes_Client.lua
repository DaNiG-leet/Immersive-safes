local ImmersiveSafes = {
    utilities = require("ImmersiveSafes_Common_functions"),
    modDataKey = require("ImmersiveSafes_DMD").modDataKey,
}

ImmersiveSafes.commands = {}

ImmersiveSafes.commands.syncSpecificModData = function(target, args)
    target:getModData()[ImmersiveSafes.modDataKey][args.data.key] = args.data.value
end

ImmersiveSafes.commands.syncAllModData = function(target, args)
    target:getModData()[ImmersiveSafes.modDataKey] = args.modData
end

ImmersiveSafes.onServerCommand = function(module, command, args)
    if module ~= 'SafesModule' then return end
    if ImmersiveSafes.commands[command] then
        local target = ImmersiveSafes.utilities.getTarget(args.x, args.y, args.z, args.target)
        if target then
            ImmersiveSafes.commands[command](target, args)
        else
            print 'error'
        end
    end
end

Events.OnServerCommand.Add(ImmersiveSafes.onServerCommand)