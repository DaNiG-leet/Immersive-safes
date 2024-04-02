--TODO: Add anims

local ISEnterPasswordUI = require("ISUI/ISEnterPasswordUI")

local InteractionWithSafeAction = ISBaseTimedAction:derive("InteractionWithSafeAction")

function InteractionWithSafeAction:isValid()
	return true
end

function InteractionWithSafeAction:waitToStart()
	if self.character:isTimedActionInstant() then
		return false
	end
	self.character:faceThisObject(self.target)
	return self.character:shouldBeTurning()
end

function InteractionWithSafeAction:perform()
	if self.type == 'enterPassword' or self.type == 'setUpPasswordUI' then
		local ui = ISEnterPasswordUI:new(0, 0, 300, 200, self.character, self.target, self.fn, self.type == 'setUpPasswordUI' and getText('UI_Setup_password') or nil)
		ui:initialise()
		ui:addToUIManager()
	else
		self.fn(self.character, self.target, self.pass)
	end
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

---@param character IsoPlayer
---@param target IsoObject
---@param fn function
---@param type string
---@param pass string
function InteractionWithSafeAction:new(character, target, fn, type, pass)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.maxTime = 0
	o.stopOnWalk = true
	o.stopOnRun = true
	o.character = character
	o.playerNum = character:getPlayerNum()
	o.target = target
	o.fn = fn
	o.type = type
	o.pass = pass
	return o
end

return InteractionWithSafeAction