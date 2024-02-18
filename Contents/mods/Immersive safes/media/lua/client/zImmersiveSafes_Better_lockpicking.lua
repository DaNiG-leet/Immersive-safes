local commonFunctions = require("ImmersiveSafes_Common_functions")

local old_CrowbarWindow_doUnlock = CrowbarWindow.doUnlock
function CrowbarWindow:doUnlock()
    if self.mode == 'SAFE' then
        if commonFunctions.isVaultOpen(self.lockpick_object:getTextureName()) then
            local player = getPlayer()
            player:addLineChatElement(getText('UI_safe_cracked'), 1, 0, 0)
            self.lockpick_object:setSpriteFromName(commonFunctions.checkVaultSprite(self.lockpick_object:getSprite():getName()))
            self.lockpick_object:transmitUpdatedSpriteToServer()
            commonFunctions.syncModData(self.lockpick_object, 'Cracked', true)
            commonFunctions.syncModData(self.lockpick_object, 'Locked', false)
            self.character:getXp():AddXP(Perks.Lockpicking, self.addingXP)
        end
    else
        old_CrowbarWindow_doUnlock(self)
    end
end

local old_CrowbarActionAnim_isValid = CrowbarActionAnim.isValid
function CrowbarActionAnim:isValid()
    if commonFunctions.isVaultOpen(self.lockpick_object:getTextureName()) ~= nil then
        return true
    end
	return old_CrowbarActionAnim_isValid(self)
end

local old_CrowbarActionAnim_waitToStart = CrowbarActionAnim.waitToStart
function CrowbarActionAnim:waitToStart()
    if commonFunctions.isVaultOpen(self.lockpick_object:getTextureName()) ~= nil then
        return self.character:shouldBeTurning()
    end
    return old_CrowbarActionAnim_waitToStart(self)
end

local old_CrowbarActionAnim_update = CrowbarActionAnim.update
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
        old_CrowbarActionAnim_update(self)
    end
end

local old_CrowbarActionAnim_start = CrowbarActionAnim.start
function CrowbarActionAnim:start()
    if commonFunctions.isVaultOpen(self.lockpick_object:getTextureName()) ~= nil then
        self:setActionAnim("CrowbarAction")
        self.character:getModData().zReBLStopFlag = 0
    else
        old_CrowbarActionAnim_start(self)
    end
end