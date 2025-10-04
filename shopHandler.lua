
local NewStamp = require("objects/stamp")

local self = {}
local api = {}

--------------------------------------------------
-- API
--------------------------------------------------

function api.CanSwapFromTable(tableValue)
	local swapSelected = TableHandler.GetSelected()
	if swapSelected and swapSelected.type == "shopSwapSelected" then
		return tableValue >= self.books[swapSelected.index].GetScore()
	end
	local minScore = false
	for i = 1, #self.books do
		if (not minScore) or self.books[i].GetScore() < minScore then
			minScore = self.books[i].GetScore()
		end
	end
	return minScore and tableValue >= minScore
end

function api.ReplaceBook(tableBook, shopIndex)
	local shopBook = self.books[shopIndex]
	if shopBook.GetScore() > tableBook.GetScore() then
		return false
	end
	self.books[shopIndex] = tableBook
	return shopBook
end

function api.RefreshShop(index)
	TableHandler.ClearShopSelected()
	self.books = {}
	local shopDef = self.shopTypes[index]
	for i = 1, shopDef.size do
		self.books[#self.books + 1] = BookHelper.GetBook({scoreRange = shopDef.range})
	end
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end


function api.Draw(drawQueue)
	drawQueue:push({y=100; f=function()
		local mousePos = self.world.GetMousePositionInterface()
		local xOff = Global.WINDOW_X * 0.1
		local yOff = Global.WINDOW_Y * 0.05
		local scale = 120
		
		local swapSelected = TableHandler.GetSelected()
		for i = 1, #self.books do
			self.books[i].Draw(xOff, yOff, scale, false)
			local canAfford = TableHandler.CanAffordShopBook(self.books[i].GetScore())
			local highlight = canAfford and swapSelected and (swapSelected.type == "shopSwapSelected") and (swapSelected.index == i)
			if InterfaceUtil.DrawButton(xOff + 5, yOff + scale*3 + 10, 120, 50, mousePos, "Trade", not canAfford, false, false, highlight, 2, 5) then
				TableHandler.SetUnderMouse({type = "shopSwapSelected", index = i})
			end
			Font.SetSize(2)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf("Value: " .. self.books[i].GetScore(), xOff + 150, yOff + scale*3 + 15, scale*3)
			xOff = xOff + 420
		end
		
		xOff = Global.WINDOW_X * 0.8
		yOff = Global.WINDOW_Y * 0.12
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf("Visit Shop", xOff - 50, yOff, 250, "center")
		yOff = yOff + 50
		for i = 1, #self.shopTypes do
			if InterfaceUtil.DrawButton(xOff, yOff, 150, 60, mousePos, self.shopTypes[i].name, false, false, false, highlight, 2, 5) then
				TableHandler.SetUnderMouse({type = "selectShop", index = i})
			end
			yOff = yOff + 80
		end
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		books = {},
		shopTypes = {
			{name = "Fancy", range = {180, 600}, size = 3},
			{name = "Medium", range = {70, 160}, size = 3},
			{name = "Bargin", range = {20, 70}, size = 3},
		}
	}
	
end

return api
