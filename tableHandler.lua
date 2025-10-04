local ShopDefs = require("defs/shopDefs")
local NewStamp = require("objects/stamp")

local self = {}
local api = {}

--------------------------------------------------
-- API
--------------------------------------------------

function api.GetSelected()
	return self.swapSelected
end

function api.ClearShopSelected()
	self.swapSelected = false
end

function api.GetMaxBookValue()
	local maxScore = 0
	for i = 1, #self.books do
		if self.books[i].GetScore() > maxScore then
			maxScore = self.books[i].GetScore()
		end
	end
	return maxScore
end

function api.CanAffordShopBook(shopScore)
	if self.swapSelected and self.swapSelected.type == "mySwapSelected" then
		return shopScore <= self.books[self.swapSelected.index].GetScore()
	end
	return shopScore <= api.GetMaxBookValue()
end

function api.CanEnterShop(shopDef)
	if shopDef.cost and not shopDef.waiveCostIfNoMoney and shopDef.cost > self.money then
		return false
	end
	if shopDef.bookRequirement and shopDef.bookRequirement > api.GetMaxBookValue() then
		return false
	end
	return true
end

function api.JustCheckUnderMouse(x, y, width, height)
	local mouse = self.world.GetMousePositionInterface()
	return util.PosInRectangle(mouse, x, y, width, height)
end

function api.SetUnderMouse(thing)
	self.underMouse = thing
end

function api.CheckAndSetUnderMouse(x, y, width, height, thing)
	if not api.JustCheckUnderMouse(x, y, width, height) then
		return false
	end
	api.SetUnderMouse(thing)
	return true
end

local function GetSwapIndecies()
	if self.oldSwapSelected.type == "mySwapSelected" then
		return self.oldSwapSelected.index, self.swapSelected.index
	else
		return self.swapSelected.index, self.oldSwapSelected.index
	end
end

local function MousePlaceClick(placePos)
	if not placePos then
		return false
	end
	if placePos.type == "sideboard" then
		local index = placePos.index
		local sideStamp = self.sideboard[index] or false
		self.sideboard[index] = self.heldStamp or false
		self.heldStamp = sideStamp
		local leftEmptySpace = self.heldStamp and not self.sideboard[index]
		return leftEmptySpace
	elseif placePos.type == "book" then
		local book = placePos.book
		local bookStamp = book.ReplaceStamp(placePos.x, placePos.y, self.heldStamp or false)
		local leftEmptySpace = bookStamp and not self.heldStamp
		self.heldStamp = bookStamp
		return leftEmptySpace
	elseif placePos.type == "sellStamp" then
		if self.heldStamp then
			self.money = self.money + self.heldStamp.GetSellValue()
			self.heldStamp = false
		end
	elseif placePos.type == "mySwapSelected" or placePos.type == "shopSwapSelected" then
		self.swapSelected = placePos
		if self.oldSwapSelected and self.oldSwapSelected.type ~= self.swapSelected.type then
			local bookIndex, shopIndex = GetSwapIndecies()
			local shopBook = ShopHandler.ReplaceBook(self.books[bookIndex], shopIndex)
			if shopBook then
				self.books[bookIndex] = shopBook
				self.swapSelected = false
			end
		end
	elseif placePos.type == "selectShop" then
		if api.CanEnterShop(ShopDefs[placePos.index]) then
			if ShopDefs[placePos.index].cost then
				self.money = math.max(0, self.money - ShopDefs[placePos.index].cost)
			end
			ShopHandler.RefreshShop(placePos.index)
		end
	end
end

function api.MousePressed(x, y, button)
	self.oldSwapSelected = self.swapSelected
	self.swapSelected = false
	
	if button == 1 then
		if MousePlaceClick(self.underMouse) then
			self.emptySpot = self.underMouse
		end
	elseif button == 2 and self.heldStamp and self.emptySpot then
		MousePlaceClick(self.emptySpot)
		self.emptySpot = false
	end
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
	self.underMouse = false
end

function api.Draw(drawQueue)
	if self.heldStamp then
		drawQueue:push({y=500; f=function()
			if self.heldStamp then
				local mouse = self.world.GetMousePositionInterface()
				local scale = 120
				self.heldStamp.Draw(mouse[1], mouse[2], scale)
			end
		end})
	end
	drawQueue:push({y=100; f=function()
		local mousePos = self.world.GetMousePositionInterface()
		local xOff = Global.WINDOW_X *0.06
		local yOff = Global.WINDOW_Y *0.6 - 36
		local scale = 100
		
		for i = 1, self.sideboardSize do
			local underMouse = api.CheckAndSetUnderMouse(xOff, yOff, scale, scale, {type = "sideboard", index = i})
			if underMouse then
				love.graphics.setLineWidth(3)
				love.graphics.setColor(0.2, 1, 0.2, 1)
			else
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0, 1)
			end
			love.graphics.rectangle("line", xOff, yOff, scale, scale)
			if self.sideboard[i] then
				self.sideboard[i].Draw(xOff + scale/2, yOff + scale/2, scale)
			end
			yOff = yOff + scale + 18
		end
		
		xOff = Global.WINDOW_X *0.15
		yOff = Global.WINDOW_Y *0.6
		for i = 1, #self.books do
			self.books[i].Draw(xOff, yOff, scale, true)
			local canAfford = ShopHandler.CanSwapFromTable(self.books[i].GetScore())
			local highlight = canAfford and self.swapSelected and (self.swapSelected.type == "mySwapSelected") and (self.swapSelected.index == i)
			if InterfaceUtil.DrawButton(xOff + 5, yOff - 60, 120, 50, mousePos, "Offer", not canAfford, false, false, highlight, 2, 5) then
				api.SetUnderMouse({type = "mySwapSelected", index = i})
			end
			Font.SetSize(2)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf("Value: " .. self.books[i].GetScore(), xOff + 150, yOff - 50, scale*3)
			xOff = xOff + 390
		end
		
		xOff = Global.WINDOW_X *0.8
		yOff = Global.WINDOW_Y *0.6 - 50
		
		if InterfaceUtil.DrawButton(xOff - 20, yOff + 150, 220, 70, mousePos, "Sell Stamp", false, false, false, false, 2, 12) then
			if self.heldStamp then
				api.SetUnderMouse({type = "sellStamp", income = self.heldStamp.GetSellValue()})
			else
				Font.SetSize(3)
				love.graphics.setColor(0, 0, 0, 1)
				love.graphics.printf("Drop a stamp here to sell it.", xOff - 20, yOff + 235, 220)
			end
		end
		
		local moneyChangeString = ""
		if self.underMouse and self.underMouse.cost then
			moneyChangeString = " - " .. self.underMouse.cost
		elseif self.underMouse and self.underMouse.income then
			moneyChangeString = " + " .. self.underMouse.income
		end
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf("Money: $" .. self.money .. moneyChangeString, xOff, yOff, scale*3)
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		books = {},
		sideboardSize = 3,
		sideboard = {},
		money = 10,
	}
	self.sideboard[2] = NewStamp({name = "basic_stamp", cost = 1 + math.floor(math.random()*3), quality = 1 + math.floor(math.random()*4)})
	
	self.books[#self.books + 1] = BookHelper.GetBook("starter")
	self.books[#self.books + 1] = BookHelper.GetBook("starter")
	self.books[#self.books + 1] = BookHelper.GetBook("starter")
end

return api
