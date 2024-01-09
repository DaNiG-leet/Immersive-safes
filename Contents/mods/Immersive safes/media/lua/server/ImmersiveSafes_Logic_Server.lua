if not isServer() then return end

local function processItems(args, itemProcessor)
	local cell = getCell()
	local currentGridSquare = cell:getGridSquare(args.x, args.y, args.z)
	if currentGridSquare then
		for i = 0, currentGridSquare:getObjects():size() - 1, 1 do
			local item = currentGridSquare:getObjects():get(i)
			if item and item:getSprite() and item:getSprite():getName() == args.target then
				itemProcessor(item)
			end
		end
	end
end

local function OnClientCommand(module, command, playerObj, args)
	if module ~= 'SafesModule' then return end

	if command == 'editSafeModData' then
		processItems(args, function(item)
			if instanceof(item, "IsoThumpable") then
				item:setMaxHealth(10000)
				item:setHealth(10000)
			end
			
			local oldPass
			if args.key == 'fprints' then
				item:getModData()[args.key] = item:getModData()[args.key] or {}
				item:getModData()[args.key][args.value.nick] = item:getModData()[args.key][args.value.nick] or {}
				table.insert(item:getModData()[args.key][args.value.nick], args.value.time)
			else
				if args.key == 'password' then
					oldPass = item:getModData()[args.key]
				end
				item:getModData()[args.key] = args.value
			end

			args.moddata = item:getModData()
			args.sender = playerObj:getUsername()

			if args.key == 'password' then
				local str = args.sender .. " changing safe's password (" .. args.target .. ") at the coordinates: " .. args.x .. ', ' .. args.y .. ', ' .. args.z ..
				' . Old password: ' .. tostring(oldPass) .. ' , new password: ' .. tostring(args.value)
				writeLog('safesChanging', str)
			end

			sendServerCommand('SafesModule', 'editSafeModData', args)
		end)
	elseif command == 'ChangeThumpHP' then
		processItems(args, function(item)
			if not instanceof(item, "IsoThumpable") then
				print('Error: ' .. tostring(item) .. ' is not IsoThumpable')
				return
			end
			item:setMaxHealth(10000)
			item:setHealth(10000)
			local str = playerObj:getUsername() .. ' changing HP of ' .. args.target .. '. Coordinates: ' .. args.x .. ', ' .. args.y .. ', ' .. args.z
			writeLog('safesChanging', str)
		end)
	elseif command == 'AdminLoging' then
		writeLog('admin', args.emmitor .. ' ' .. args.str)
	end
end

Events.OnClientCommand.Add(OnClientCommand)