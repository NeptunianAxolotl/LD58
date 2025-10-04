
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
	return tableValue >= minScore
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
		local yOff = Global.WINDOW_Y * 0.02
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
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		books = {},
	}
	
	self.books[#self.books + 1] = BookHelper.GetBook({scoreRange = {60, 400}})
	self.books[#self.books + 1] = BookHelper.GetBook({scoreRange = {60, 400}})
	self.books[#self.books + 1] = BookHelper.GetBook({scoreRange = {60, 400}})
end

return api
