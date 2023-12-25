--TODO: Add anims

require "TimedActions/ISBaseTimedAction"
require "ISUI/ISLayoutManager"

InteractionWithSafeAction = ISBaseTimedAction:derive("InteractionWithSafeAction")

function InteractionWithSafeAction:isValid()
	return true
end

function InteractionWithSafeAction:waitToStart()
	self.character:faceThisObject(self.target)
	return self.character:shouldBeTurning()
end

function InteractionWithSafeAction:perform()
	if self.type == 'enterPassword' then
		local ui = ISEnterPasswordUI:new(0, 0, 300, 200, self.character, self.target, self.fn)
		ui:initialise()
		ui:addToUIManager()
	elseif self.type == 'close' then
		self.fn(self.target)
	elseif self.type == 'open' then
		self.fn(self.pass, self.target)
	elseif self.type == 'setUpPasswordUI' then
		local ui = ISEnterPasswordUI:new(0, 0, 300, 200, self.character, self.target, self.fn, getText('UI_Setup_password'))
		ui:initialise()
		ui:addToUIManager()
	elseif self.type == 'setUpPassword' then
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