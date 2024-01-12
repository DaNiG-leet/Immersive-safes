local commonFunctions = require("ImmersiveSafes_Common_functions")

local old_fn = CrowbarWindow.doUnlock
function CrowbarWindow:doUnlock()
    if self.mode == 'SAFE' then
        if commonFunctions.isVaultOpen(self.lockpick_object:getTextureName()) then
            local player = getPlayer()
            player:addLineChatElement(getText('UI_safe_cracked'), 1, 0, 0)
            local checkV = self.lockpick_object:getSprite():getName()
            local reversedV = commonFunctions.checkVaultSprite(checkV)
            self.lockpick_object:setSpriteFromName(reversedV)
            self.lockpick_object:transmitUpdatedSpriteToServer()
            commonFunctions.syncModData(self.lockpick_object, 'Cracked', true)
            commonFunctions.syncModData(self.lockpick_object, 'Locked', false)
            self.character:getXp():AddXP(Perks.Lockpicking, self.addingXP)
        end
    else
        old_fn(self)
    end
end

local old_fn2 = CrowbarActionAnim.isValid
function CrowbarActionAnim:isValid()
    if commonFunctions.isVaultOpen(self.lockpick_object:getTextureName()) ~= nil then
        return true
    end
	return old_fn2(self)
end

local old_fn3 = CrowbarActionAnim.waitToStart
function CrowbarActionAnim:waitToStart()
    if commonFunctions.isVaultOpen(self.lockpick_object:getTextureName()) ~= nil then
        return self.character:shouldBeTurning()
    end
    return old_fn3(self)
end

local old_fn4 = CrowbarActionAnim.update
function CrowbarActionAnim:update()
    if commonFunctions.isVaultOpen(self.lockpick_object:getTextureName()) ~= nil then
        local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
        if uispeed ~= 1 then
            UIManager.getSpeedControls():SetCurrentGameSpeed(1)
        end
        if not self.sound or not self.sound:isPlaying() then
            self.sound = getSoundManager():PlayWorldSound("zReBL_crowbarSound", self.character:getCurrentSquare(), 1, 25, 2, true)
        end
        self.character:faceThisObject(self.lockpick_object)
    else
        old_fn4(self)
    end
end

local old_fn5 = CrowbarActionAnim.start
function CrowbarActionAnim:start()
    if commonFunctions.isVaultOpen(self.lockpick_object:getTextureName()) ~= nil then
        self:setActionAnim("CrowbarAction")
        self.character:getModData().zReBLStopFlag = 0
    else
        old_fn5(self)
    end
end