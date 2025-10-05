
local NewStamp = require("objects/stamp")
local ShopDefs = require("defs/shopDefs")

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
	local shopDef = ShopDefs[index]
	for i = 1, shopDef.size do
		self.books[#self.books + 1] = BookHelper.GetBook(util.SampleListWeighted(shopDef.bookType).bookType)
	end
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end


function api.Draw(drawQueue)
	drawQueue:push({y=50; f=function()
		local mousePos = self.world.GetMousePositionInterface()
		local xOff = Global.WINDOW_X * 0.1
		local yOff = Global.WINDOW_Y * 0.05
		local scale = 1
		
		local swapSelected = TableHandler.GetSelected()
		for i = 1, #self.books do
			self.books[i].Draw(xOff, yOff, scale, "shopBook")
			local canAfford = TableHandler.CanAffordShopBook(self.books[i].GetScore())
			local highlight = canAfford and swapSelected and (swapSelected.type == "shopSwapSelected") and (swapSelected.index == i)
			if InterfaceUtil.DrawButton(
					xOff + 5, yOff + Global.STAMP_HEIGHT*self.books[i].GetHeight() + 10, 120, 50, mousePos,
					"Trade", not canAfford, false, false, highlight, 2, 5) then
				TableHandler.SetUnderMouse({type = "shopSwapSelected", index = i})
			end
			Font.SetSize(2)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf("♥" .. self.books[i].GetScore(), xOff + 150, yOff + Global.STAMP_HEIGHT*self.books[i].GetHeight() + 15, Global.STAMP_WIDTH*3)
			xOff = xOff + 420
		end
		
		xOff = Global.WINDOW_X * 0.75
		yOff = Global.WINDOW_Y * 0.1
		love.graphics.setColor(0, 0, 0, 1)
		Font.SetSize(2)
		love.graphics.printf("Visit Shop", xOff - 50, yOff, 250, "center")
		yOff = yOff + 50
		for i = 1, #ShopDefs do
			local shopDef = ShopDefs[i]
			local canEnter = TableHandler.CanEnterShop(shopDef)
			if InterfaceUtil.DrawButton(xOff, yOff, 150, 60, mousePos, shopDef.name, not canEnter, false, true, highlight, 2, 5) then
				TableHandler.SetUnderMouse({type = "selectShop", index = i, cost = shopDef.cost})
				love.graphics.setColor(0, 0, 0, 1)
				Font.SetSize(3)
				love.graphics.printf(shopDef.desc, Global.WINDOW_X * 0.75 + 170, Global.WINDOW_Y * 0.1 + 45, 300, "left")
			end
			yOff = yOff + 80
		end
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		books = {}
	}
end

return api
