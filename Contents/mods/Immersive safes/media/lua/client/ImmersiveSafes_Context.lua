local InteractionWithSafeAction = require("TimedActions/ISInteractionWithSafeAction")

local ImmersiveSafes = {
    utilities = require("ImmersiveSafes_Common_functions"),
    modDataKey = require("ImmersiveSafes_DMD").modDataKey,
    squareOffsetIsoDirections = {
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
}

---Uploads "fingerprints" to the parsingFingers.ini file
---@param target IsoObject
ImmersiveSafes.getPrints = function(playerObj, target)
    local writer = getFileWriter("parsingFingers.ini", true, false)
    local prints = target:getModData()[ImmersiveSafes.modDataKey]['fprints']
    for _, v in pairs(prints) do
        local str = v.n .. ' : ' .. 'Year: ' .. v.t.y .. ', Month: ' .. v.t.mo .. ', Day: ' .. v.t.d .. ', Hour: ' .. v.t.h .. ', Minute: ' .. v.t.mi .. ', X: ' .. v.c.x .. ', Y: ' .. v.c.y .. ', Z: ' .. v.c.z
        writer:write(str .. '\n')
    end
    local time = ImmersiveSafes.utilities.getTime()
    local str = 'World time at the time of writing: Year: ' .. time.y .. ', Month: ' .. time.mo .. ', Day: ' .. time.d .. ', Hour: ' .. time.h .. ', Minute: ' .. time.mi
    writer:write('\n' .. str)
    writer:close()
    playerObj:addLineChatElement('The list of players is uploaded to parsingFingers.ini in your user/Zomboid/lua folder.', 1, 1, 1)
end

---Records the player's "fingerprint" in the safe.
---@param target IsoObject
ImmersiveSafes.setFingerPrint = function(playerObj, target)
    if isAdmin() then return end
    ImmersiveSafes.utilities.sendData(playerObj, 'setFingerPrint', target)
end

---Causes timed action interactions with the safe.
---@param playerObj IsoPlayer
---@param target IsoObject
---@param actionFunc function
---@param actionStr string
---@param pass string
ImmersiveSafes.CommonSafeAction = function(playerObj, target, actionFunc, actionStr, pass)
    if playerObj:isTimedActionInstant() then
        ISTimedActionQueue.add(InteractionWithSafeAction:new(playerObj, target, actionFunc, actionStr, pass))
        return
    end
    local playerSquare = playerObj:getCurrentSquare()
    local safeSquare = target:getSquare()
    local props = target:getProperties()
    local dir = props:Is("Facing") and props:Val("Facing")
    local wall = false
    if dir and not ImmersiveSafes.utilities.isWallSafe(target:getTextureName()) then
        local offset = ImmersiveSafes.squareOffsetIsoDirections[dir]
        local nearSafeSquare = getCell():getGridSquare(safeSquare:getX() + offset.X, safeSquare:getY() + offset.Y, safeSquare:getZ())
        if safeSquare:isBlockedTo(nearSafeSquare) then
            playerObj:addLineChatElement(getText('UI_cant_get_door'), 1, 0, 0)
            return
        end
        local adjacent = AdjacentFreeTileFinder.FindEdge(nearSafeSquare, dir, playerObj, true)
        if adjacent then
            if adjacent ~= playerSquare then
                ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, adjacent))
            end
            ISTimedActionQueue.add(InteractionWithSafeAction:new(playerObj, target, actionFunc, actionStr, pass))
        else
            playerObj:addLineChatElement(getText('UI_cant_get_door'), 1, 0, 0)
        end
        return
    end
    local walk = luautils.walkAdj(playerObj, safeSquare)
    if safeSquare and walk and not wall then
		ISTimedActionQueue.add(InteractionWithSafeAction:new(playerObj, target, actionFunc, actionStr, pass))
    elseif not walk and wall then
        playerObj:addLineChatElement(getText('UI_cant_get_door'), 1, 0, 0)
	end
end

-- Setup password

---Approach and invoke the safe interaction UI to set the password.
---@param playerObj IsoPlayer
---@param target IsoObject
ImmersiveSafes.OnSetUpSafePasswordUI = function(playerObj, target)
    ImmersiveSafes.CommonSafeAction(playerObj, target, ImmersiveSafes.OnSetupSafePassword, 'setUpPasswordUI')
end

---Approach and set the password set in the UI for the safe.
---@param playerObj IsoPlayer
---@param target IsoObject
---@param pass string
ImmersiveSafes.OnSetupSafePassword = function(playerObj, target, pass)
    ImmersiveSafes.CommonSafeAction(playerObj, target, ImmersiveSafes.SetUpSafePassword, 'setUpPassword', pass)
end

---Set a new password.
---@param player IsoPlayer
---@param target IsoObject
---@param str string
ImmersiveSafes.SetUpSafePassword = function(playerObj, target, str)
    target:getModData()[ImmersiveSafes.modDataKey].password = str
    ImmersiveSafes.utilities.updatePasswordHint(playerObj, target)
    ImmersiveSafes.utilities.syncModData(playerObj, target, 'password', str)
    playerObj:addLineChatElement(getText('UI_password_set', str))
    ImmersiveSafes.setFingerPrint(playerObj, target)
end

-- Opening

---Approach and call the UI to enter the safe's password.
---@param playerObj IsoPlayer
---@param target IsoObject
---@param pass string
ImmersiveSafes.OnEnterSafePassword = function(playerObj, target, pass)
    ImmersiveSafes.CommonSafeAction(playerObj, target, ImmersiveSafes.OnOpenSafe, 'enterPassword')
end

---Go over and open the safe.
---@param playerObj IsoPlayer
---@param target IsoObject
---@param pass string
ImmersiveSafes.OnOpenSafe = function(playerObj, target, pass)
    ImmersiveSafes.CommonSafeAction(playerObj, target, ImmersiveSafes.OpenSafe, 'open', pass)
end

---Opens the safe.
---@param str string
---@param target IsoObject
ImmersiveSafes.OpenSafe = function(playerObj, target, pass)
    if target:getModData()[ImmersiveSafes.modDataKey].password == pass then
        ImmersiveSafes.utilities.updatePasswordHint(playerObj, target)
        local reversedV = ImmersiveSafes.utilities.getReversedSprite(target)
        target:setSpriteFromName(reversedV)
        target:transmitUpdatedSpriteToServer()
        playerObj:addLineChatElement(getText('UI_safe_opened'), 1, 0, 0)
        ISInventoryPage.dirtyUI()
    else
        playerObj:addLineChatElement(getText('UI_incorrect_code'), 1, 0, 0)
    end
    ImmersiveSafes.setFingerPrint(playerObj, target)
end

-- Closing

---Go over and close the safe.
---@param playerObj IsoPlayer
---@param target IsoObject
ImmersiveSafes.OnCloseSafe = function(playerObj, target)
    ImmersiveSafes.CommonSafeAction(playerObj, target, ImmersiveSafes.CloseSafe, 'close')
end

---Close the safe.
---@param target IsoObject
ImmersiveSafes.CloseSafe = function(playerObj, target)
    local reversedV = ImmersiveSafes.utilities.getReversedSprite(target)
    target:setSpriteFromName(reversedV)
    target:transmitUpdatedSpriteToServer()
    playerObj:addLineChatElement(getText('UI_safe_closed'), 1, 0, 0)
    ISInventoryPage.dirtyUI()
    ImmersiveSafes.setFingerPrint(playerObj, target)
end

-- Admin

---ADMIN TOOL: Sets the HP of the IsoThumpable safe to 10000.
---@param target IsoObject
ImmersiveSafes.AdminChangeHP = function(playerObj, target)
    ImmersiveSafes.utilities.sendData(playerObj, 'ChangeThumpHP', target)
end

---ADMIN TOOL: Force open the safe.
---@param target IsoObject
ImmersiveSafes.AdminOpenSafe = function(playerObj, target)
    ImmersiveSafes.OpenSafe(playerObj, target, target:getModData()[ImmersiveSafes.modDataKey]['password'])
    ImmersiveSafes.utilities.sendData(playerObj, 'AdminForceOpen', target)
end

-- Context

ImmersiveSafes.getAllSafes = function(objects)
    local safes = {}
    for _, v in ipairs(objects) do if v:getTextureName() and luautils.indexOf(safes, v) == -1 and luautils.stringStarts(v:getTextureName(), "safes_01") and ImmersiveSafes.utilities.getReversedSprite(v) then table.insert(safes, v) end end
    return safes
end

ImmersiveSafes.ContextMenu = function(player, context, objects, test)
    local playerObj = getSpecificPlayer(player)
    local safes = ImmersiveSafes.getAllSafes(objects)
    if #safes == 0 then return end
    for _, safe in ipairs(safes) do
        ImmersiveSafes.utilities.setModData(playerObj, safe)
        local safeIcon = getTexture('media/ui/safe_icon.png')
        if ImmersiveSafes.utilities.isSafeOpened(safe) then
            if safe:getModData()[ImmersiveSafes.modDataKey].password then
                context:addOption(getText('ContextMenu_Close_Safe'), playerObj, ImmersiveSafes.OnCloseSafe, safe).iconTexture = safeIcon
            end
            context:addOption(getText('ContextMenu_Set_Up_New_Password_Safe'), playerObj, ImmersiveSafes.OnSetUpSafePasswordUI, safe).iconTexture = safeIcon
        else
            if safe:getModData()[ImmersiveSafes.modDataKey].password then
                context:addOption(getText('ContextMenu_Open_Safe'), playerObj, ImmersiveSafes.OnEnterSafePassword, safe).iconTexture = safeIcon
            end
        end

        if isAdmin() then
            local adminSafeOptions = context:addOption("Admin Safe Options")
            adminSafeOptions.iconTexture = getTexture("media/ui/BugIcon.png")
            local subMenu = ISContextMenu:getNew(context)
            context:addSubMenu(adminSafeOptions, subMenu)
            subMenu:addOption("Get safe fingerprints", playerObj, ImmersiveSafes.getPrints, safe)
            if ImmersiveSafes.utilities.isSafeOpened(safe) == false then subMenu:addOption('Force safe open', playerObj, ImmersiveSafes.AdminOpenSafe, safe) end
            if instanceof(safe, "IsoThumpable") then
                subMenu:addOption('Safe set 10000 HP', playerObj, ImmersiveSafes.AdminChangeHP, safe)
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ImmersiveSafes.ContextMenu)