
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

function api.CanAffordShopBook(shopScore)
	if self.swapSelected and self.swapSelected.type == "mySwapSelected" then
		return shopScore <= self.books[self.swapSelected.index].GetScore()
	end
	local maxScore = 0
	for i = 1, #self.books do
		if self.books[i].GetScore() > maxScore then
			maxScore = self.books[i].GetScore()
		end
	end
	return shopScore <= maxScore
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
		local xOff = Global.WINDOW_X *0.08
		local yOff = Global.WINDOW_Y *0.6
		local scale = 120
		
		for i = 1, self.sideboardSize do
			local underMouse = api.CheckAndSetUnderMouse(xOff, yOff, scale, scale, {type = "sideboard", index = i})
			love.graphics.setLineWidth(3)
			if underMouse then
				love.graphics.setColor(0.2, 1, 0.2, 1)
			else
				love.graphics.setColor(0, 0, 0, 1)
			end
			love.graphics.rectangle("line", xOff, yOff, scale, scale)
			if self.sideboard[i] then
				self.sideboard[i].Draw(xOff + scale/2, yOff + scale/2, scale)
			end
			yOff = yOff + scale + 20
		end
		
		xOff = Global.WINDOW_X *0.2
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
			xOff = xOff + 420
		end
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		books = {},
		sideboardSize = 2,
		sideboard = {},
	}
	self.sideboard[2] = NewStamp({name = "basic_stamp", cost = 1 + math.floor(math.random()*3)})
	
	self.books[#self.books + 1] = BookHelper.GetBook({scoreRange = {0, 70}})
	self.books[#self.books + 1] = BookHelper.GetBook({scoreRange = {0, 70}})
end

return api
