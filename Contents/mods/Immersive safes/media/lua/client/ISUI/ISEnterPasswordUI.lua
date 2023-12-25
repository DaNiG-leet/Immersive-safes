ISEnterPasswordUI = ISPanelJoypad:derive("ISEnterPasswordUI");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function ISEnterPasswordUI:initialise()
	ISPanelJoypad.initialise(self);

	local fontHgt = FONT_HGT_SMALL
	local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Ok") + 12
	local buttonWid2 = getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 12
	local buttonWid = math.max(math.max(buttonWid1, buttonWid2), 100)
	local buttonHgt = math.max(fontHgt + 6, 25)
	local padBottom = 10

	self.yes = ISButton:new((self:getWidth() / 2) - 5 - buttonWid, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Ok"), self, ISEnterPasswordUI.onClick);
	self.yes.internal = "OK";
	self.yes:initialise();
	self.yes:instantiate();
	self.yes.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	};
	self:addChild(self.yes);

	self.no = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Close"), self, ISEnterPasswordUI.onClick);
	self.no.internal = "CANCEL";
	self.no:initialise();
	self.no:instantiate();
	self.no.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	};
	self:addChild(self.no);

	self.fontHgt = FONT_HGT_MEDIUM
	local inset = 2
	local height = inset + self.fontHgt * self.numLines + inset
	local y = 55

	self.button1p = ISButton:new((self:getWidth() / 2) - 28, (self:getHeight() / 2) - 25, 16, 16, getText("^"), self, ISEnterPasswordUI.onClick);
	self.button1p.internal = "B1PLUS";
	self.button1p:initialise();
	self.button1p:instantiate();
	self.button1p.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	};
	self:addChild(self.button1p);

	self.number1 = ISTextEntryBox:new("0", self:getWidth() / 2 - 28, self:getHeight() / 2 - 5, 18, 18);
	self.number1:initialise();
	self.number1:instantiate();
	self.number1:setEditable(false)
	self:addChild(self.number1);

	self.button1m = ISButton:new(self:getWidth() / 2 - 28, (self:getHeight() / 2) + 16, 16, 16, getText("v"), self, ISEnterPasswordUI.onClick);
	self.button1m.internal = "B1MINUS";
	self.button1m:initialise();
	self.button1m:instantiate();
	self.button1m.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	};
	self:addChild(self.button1m);

	--
	self.button2p = ISButton:new(self:getWidth() / 2 - 8, (self:getHeight() / 2) - 25, 16, 16, getText("^"), self, ISEnterPasswordUI.onClick);
	self.button2p.internal = "B2PLUS";
	self.button2p:initialise();
	self.button2p:instantiate();
	self.button2p.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	};
	self:addChild(self.button2p);

	self.number2 = ISTextEntryBox:new("0", self:getWidth() / 2 - 8, self:getHeight() / 2 - 5, 18, 18);
	self.number2:initialise();
	self.number2:instantiate();
	self.number2:setEditable(false)
	self:addChild(self.number2);

	self.button2m = ISButton:new(self:getWidth() / 2 - 8, (self:getHeight() / 2) + 16, 16, 16, getText("v"), self, ISEnterPasswordUI.onClick);
	self.button2m.internal = "B2MINUS";
	self.button2m:initialise();
	self.button2m:instantiate();
	self.button2m.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	};
	self:addChild(self.button2m);

	--
	self.button3p = ISButton:new(self:getWidth() / 2 + 12, (self:getHeight() / 2) - 25, 16, 16, getText("^"), self, ISEnterPasswordUI.onClick);
	self.button3p.internal = "B3PLUS";
	self.button3p:initialise();
	self.button3p:instantiate();
	self.button3p.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	};
	self:addChild(self.button3p);

	self.number3 = ISTextEntryBox:new("0", self:getWidth() / 2 + 12, self:getHeight() / 2 - 5, 18, 18);
	self.number3:initialise();
	self.number3:instantiate();
	self.number3:setEditable(false)
	self:addChild(self.number3);

	self.button3m = ISButton:new(self:getWidth() / 2 + 12, (self:getHeight() / 2) + 16, 16, 16, getText("v"), self, ISEnterPasswordUI.onClick);
	self.button3m.internal = "B3MINUS";
	self.button3m:initialise();
	self.button3m:instantiate();
	self.button3m.borderColor = {
		r = 1,
		g = 1,
		b = 1,
		a = 0.1
	};
	self:addChild(self.button3m);

	if isAdmin() or getDebug() then
		y = y - 10
		local label = ISLabel:new((self:getWidth() / 3) + 65, y, height, "[ADM] Password:" .. tostring(self.target:getModData()["password"]), 1, 1, 1, 1, UIFont.Small)
		label:initialise()
		self:addChild(label)
	end

end

function ISEnterPasswordUI:destroy()
	UIManager.setShowPausedMessage(true);
	self:setVisible(false);
	self:removeFromUIManager();
end

function ISEnterPasswordUI:increment(number)
	local newNumber = tonumber(number:getText()) + 1;
	if newNumber > 9 then newNumber = 0; end
	number:setText(newNumber .. "");
end

function ISEnterPasswordUI:decrement(number)
	local newNumber = tonumber(number:getText()) - 1;
	if newNumber < 0 then newNumber = 9; end
	number:setText(newNumber .. "");
end

function ISEnterPasswordUI:onClick(button)
	if button.internal == "CANCEL" then
		self:destroy();
		return;
	end
	if button.internal == "OK" then
		local str = self.number1:getText() .. self.number2:getText() .. self.number3:getText()
		self.onclick(self.player, self.target, str)
		self:destroy();
		return;
	end
	if button.internal == "B1PLUS" then self:increment(self.number1); end
	if button.internal == "B1MINUS" then self:decrement(self.number1); end
	if button.internal == "B2PLUS" then self:increment(self.number2); end
	if button.internal == "B2MINUS" then self:decrement(self.number2); end
	if button.internal == "B3PLUS" then self:increment(self.number3); end
	if button.internal == "B3MINUS" then self:decrement(self.number3); end
end

function ISEnterPasswordUI:titleBarHeight()
	return 16
end

function ISEnterPasswordUI:prerender()
	self.backgroundColor.a = 0.8

	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);

	local th = self:titleBarHeight()
	self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1);

	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

	self:drawTextCentre(self.title, self:getWidth() / 2, 20, 1, 1, 1, 1, UIFont.NewLarge);

	self:updateButtons();
end

function ISEnterPasswordUI:updateButtons()

end

function ISEnterPasswordUI:render()

end

function ISEnterPasswordUI:onMouseMove(dx, dy)
	self.mouseOver = true
	if self.moving then
		self:setX(self.x + dx)
		self:setY(self.y + dy)
		self:bringToTop()
	end
end

function ISEnterPasswordUI:onMouseMoveOutside(dx, dy)
	self.mouseOver = false
	if self.moving then
		self:setX(self.x + dx)
		self:setY(self.y + dy)
		self:bringToTop()
	end
end

function ISEnterPasswordUI:onMouseDown(x, y)
	if not self:getIsVisible() then return end
	self.downX = x
	self.downY = y
	self.moving = true
	self:bringToTop()
end

function ISEnterPasswordUI:onMouseUp(x, y)
	if not self:getIsVisible() then return; end
	self.moving = false
	if ISMouseDrag.tabPanel then ISMouseDrag.tabPanel:onMouseUp(x, y) end
	ISMouseDrag.dragView = nil
end

function ISEnterPasswordUI:onMouseUpOutside(x, y)
	if not self:getIsVisible() then return end
	self.moving = false
	ISMouseDrag.dragView = nil
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
	o = ISPanelJoypad:new(x, y, width, height);
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
	o.name = nil;
	o.backgroundColor = {
		r = 0,
		g = 0,
		b = 0,
		a = 0.5
	};
	o.borderColor = {
		r = 0.4,
		g = 0.4,
		b = 0.4,
		a = 1
	};
	o.width = width;
	o.height = height;
	o.anchorLeft = true;
	o.anchorRight = true;
	o.anchorTop = true;
	o.anchorBottom = true;
	o.target = target;
	o.onclick = onclick;
	o.player = player;
	o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png");
	o.numLines = 1
	o.maxLines = 1
	o.multipleLine = false
	o.title = name or getText('UI_enter_password')
	return o;
end
