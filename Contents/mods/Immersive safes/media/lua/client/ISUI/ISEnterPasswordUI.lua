local UIModule = require("ImmersiveSafes_UI_Utilities")
local modDataKey = require("ImmersiveSafes_DMD").modDataKey
local utilities = require("ImmersiveSafes_Common_functions")

local ISEnterPasswordUI = ISPanelJoypad:derive("ISEnterPasswordUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

local size = 18

function ISEnterPasswordUI:initialise()
	ISPanelJoypad.initialise(self)

	UIModule.addBaseUI(self)

	local fontHgt = FONT_HGT_SMALL
	local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Ok") + 12
	local buttonWid2 = getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 12
	local buttonWid = math.max(math.max(buttonWid1, buttonWid2), 100)
	local buttonHgt = math.max(fontHgt + 6, 25)
	local padBottom = 10

	local btn = ISButton:new((self:getWidth() / 2) - 5 - buttonWid, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Ok"), self, self.okAction)
	btn.internal = "OK"
	btn:initialise()
	btn:instantiate()
	btn.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	}
	self:addChild(btn)

	btn = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Close"), self, self.destroy)
	btn.internal = "CANCEL"
	btn:initialise()
	btn:instantiate()
	btn.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	}
	self:addChild(btn)

	btn = ISButton:new(0, (self:getHeight() / 2) - 25, size, size, "^", self, self.onClick)
	btn.internal = "B1PLUS"
	btn:initialise()
	btn:instantiate()
	btn.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	}
	self:addChild(btn)

	table.insert(self.numberElements[1], btn)

	self.number1 = ISTextEntryBox:new("0", 0, self:getHeight() / 2 - 5, size, size)
	self.number1:initialise()
	self.number1:instantiate()
	self.number1:setEditable(false)
	self:addChild(self.number1)

	table.insert(self.numberElements[1], self.number1)

	btn = ISButton:new(0, (self:getHeight() / 2) + 16, size, size, "v", self, self.onClick)
	btn.internal = "B1MINUS"
	btn:initialise()
	btn:instantiate()
	btn.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	}
	self:addChild(btn)

	table.insert(self.numberElements[1], btn)

	--
	btn = ISButton:new(0, (self:getHeight() / 2) - 25, size, size, "^", self, self.onClick)
	btn.internal = "B2PLUS"
	btn:initialise()
	btn:instantiate()
	btn.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	}
	self:addChild(btn)

	table.insert(self.numberElements[2], btn)

	self.number2 = ISTextEntryBox:new("0", 0, self:getHeight() / 2 - 5, 18, 18)
	self.number2:initialise()
	self.number2:instantiate()
	self.number2:setEditable(false)
	self:addChild(self.number2)

	table.insert(self.numberElements[2], self.number2)

	btn = ISButton:new(0, (self:getHeight() / 2) + 16, size, size, "v", self, self.onClick)
	btn.internal = "B2MINUS"
	btn:initialise()
	btn:instantiate()
	btn.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	}
	self:addChild(btn)

	table.insert(self.numberElements[2], btn)

	--
	btn = ISButton:new(0, (self:getHeight() / 2) - 25, size, size, "^", self, self.onClick)
	btn.internal = "B3PLUS"
	btn:initialise()
	btn:instantiate()
	btn.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	}
	self:addChild(btn)

	table.insert(self.numberElements[3], btn)

	self.number3 = ISTextEntryBox:new("0", 0, self:getHeight() / 2 - 5, size, size)
	self.number3:initialise()
	self.number3:instantiate()
	self.number3:setEditable(false)
	self:addChild(self.number3)

	table.insert(self.numberElements[3], self.number3)

	btn = ISButton:new(0, (self:getHeight() / 2) + 16, size, size, "v", self, self.onClick)
	btn.internal = "B3MINUS"
	btn:initialise()
	btn:instantiate()
	btn.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	}
	self:addChild(btn)

	table.insert(self.numberElements[3], btn)

	--
	btn = ISButton:new(0, (self:getHeight() / 2) - 25, size, size, "^", self, self.onClick)
	btn.internal = "B4PLUS"
	btn:initialise()
	btn:instantiate()
	btn.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	}
	self:addChild(btn)

	table.insert(self.numberElements[4], btn)

	self.number4 = ISTextEntryBox:new("0", 0, self:getHeight() / 2 - 5, size, size)
	self.number4:initialise()
	self.number4:instantiate()
	self.number4:setEditable(false)
	self:addChild(self.number4)

	table.insert(self.numberElements[4], self.number4)

	btn = ISButton:new(0, (self:getHeight() / 2) + 16, size, size, "v", self, self.onClick)
	btn.internal = "B4MINUS"
	btn:initialise()
	btn:instantiate()
	btn.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	}
	self:addChild(btn)

	table.insert(self.numberElements[4], btn)

	if self.title == getText('UI_enter_password') and utilities.getPasswordHint(self.player, self.target) then
		local label = ISLabel:new(0, btn:getY() + btn:getHeight() + 5, FONT_HGT_SMALL, getText('UI_remembered_password') .. ": " .. utilities.getPasswordHint(self.player, self.target), 1, 1, 1, 1, UIFont.Small)
		label:initialise()
		self:addChild(label)
		label:setX(self:getWidth() / 2 - label.width / 2)
	end

	if isAdmin() or getDebug() then
		local label = ISLabel:new(0, (self:getHeight() / 2) - 25 - 5 - FONT_HGT_SMALL, FONT_HGT_SMALL, "[ADM] Password:" .. tostring(self.target:getModData()[modDataKey].password), 1, 1, 1, 1, UIFont.Small)
		label:initialise()
		self:addChild(label)
		label:setX(self:getWidth() / 2 - label.width / 2)
	end

	self:centeringButtons()
end

function ISEnterPasswordUI:centeringButtons()
	local padding = 2
	local center = self:getWidth() / 2
	local buttonsWidth = self.number1.width * 4 + padding * 3
	local x = center - buttonsWidth / 2
	for i, v in ipairs(self.numberElements) do
		for _, element in ipairs(v) do
			element:setX(x)
		end
		x = x + size + padding
	end
end

function ISEnterPasswordUI:destroy()
	UIManager.setShowPausedMessage(true)
	self:setVisible(false)
	self:removeFromUIManager()
end

function ISEnterPasswordUI:increment(number)
	local newNumber = tonumber(number:getText()) + 1
	if newNumber > 9 then newNumber = 0 end
	number:setText(tostring(newNumber))
end

function ISEnterPasswordUI:decrement(number)
	local newNumber = tonumber(number:getText()) - 1
	if newNumber < 0 then newNumber = 9 end
	number:setText(tostring(newNumber))
end

function ISEnterPasswordUI:onClick(button)
	if button.internal == "B1PLUS" then self:increment(self.number1) end
	if button.internal == "B1MINUS" then self:decrement(self.number1) end
	if button.internal == "B2PLUS" then self:increment(self.number2) end
	if button.internal == "B2MINUS" then self:decrement(self.number2) end
	if button.internal == "B3PLUS" then self:increment(self.number3) end
	if button.internal == "B3MINUS" then self:decrement(self.number3) end
	if button.internal == "B4PLUS" then self:increment(self.number4) end
	if button.internal == "B4MINUS" then self:decrement(self.number4) end
end

function ISEnterPasswordUI:okAction()
	local str = self.number1:getText() .. self.number2:getText() .. self.number3:getText() .. self.number4:getText()
	self.onclick(self.player, self.target, str)
	self:destroy()
end

function ISEnterPasswordUI:titleBarHeight()
	return 16
end

function ISEnterPasswordUI:prerender()
	self.backgroundColor.a = 0.8
	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
	local th = self:titleBarHeight()
	self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1)
	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
	self:drawTextCentre(self.title, self:getWidth() / 2, 20, 1, 1, 1, 1, UIFont.NewLarge)
end

---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param player IsoPlayer
---@param target IsoObject
---@param onclick function
---@param name string
---@return ISEnterPasswordUI
function ISEnterPasswordUI:new(x, y, width, height, player, target, onclick, name)
	local o = {}
	o = ISPanelJoypad:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	if y == 0 then
		o.y = o:getMouseY() - (height / 2)
		o:setY(o.y)
	end
	if x == 0 then
		o.x = o:getMouseX() - (width / 2)
		o:setX(o.x)
	end
	o.backgroundColor = {
		r = 0,
		g = 0,
		b = 0,
		a = 0.5
	}
	o.borderColor = {
		r = 0.4,
		g = 0.4,
		b = 0.4,
		a = 1
	}
	o.width = width
	o.height = height
	o.anchorLeft = true
	o.anchorRight = true
	o.anchorTop = true
	o.anchorBottom = true
	o.target = target
	o.onclick = onclick
	o.player = player
	o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png")
	o.title = name or getText('UI_enter_password')
	o.numberElements = {
		{},
		{},
		{},
		{},
	}
	return o
end

return ISEnterPasswordUI