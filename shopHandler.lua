
local NewStamp = require("objects/stamp")
local ShopDefsData = require("defs/shopDefs")
local ShopDefs = ShopDefsData.def

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
	self.bestShopSoFar = math.min(index, self.bestShopSoFar)
	TableHandler.ClearShopSelected()
	self.currentShopIndex = index
	self.books = {}
	local shopDef = ShopDefs[index]
	for i = 1, shopDef.size do
		self.books[#self.books + 1] = BookHelper.GetBook(util.SampleListWeighted(shopDef.bookType).bookType)
	end
	
	if shopDef.giveBooksUpTo and TableHandler.GetBookCount() < shopDef.giveBooksUpTo then
		TableHandler.AddBook(shopDef.giveBookType, shopDef.giveBookText)
	end
end

function api.GetCurrentShopIndex()
	return self.currentShopIndex
end

function api.GetCurrentContinuoScore(index)
  if self.currentShopIndex == nil
  then return 0
  else
    local shopDef = ShopDefs[self.currentShopIndex]
    return shopDef.continuoValue
  end
end
--------------------------------------------------
-- Drawing
--------------------------------------------------

local function DrawBooks(bookList, canTrade)
	local mousePos = self.world.GetMousePositionInterface()
	local xOff = Global.WINDOW_X * 0.68
	local yOff = Global.WINDOW_Y * 0.05
	local scale = 1
	
	local swapSelected = TableHandler.GetSelected()
	if bookList[1] then
		local minSize = bookList[1].GetWidth()
		for i = 2, #bookList do
			minSize = math.min(bookList[i].GetWidth())
		end
		if minSize == 4 then
			xOff = xOff + 56
		end
	end
	for i = 1, #bookList do
		local book = bookList[i]
		local extraHeight = math.max(0, 3 - book.GetHeight()) * Global.STAMP_HEIGHT
		xOff = xOff - book.GetWidth() * Global.STAMP_WIDTH
		if book.GetWidth() == 2 then
			xOff = xOff - 8
		elseif book.GetWidth() == 4 then
			xOff = xOff + 10
		end
		
		Resources.DrawImage("book_width_" .. book.GetWidth(), xOff - 60, yOff - 630 + Global.STAMP_HEIGHT*book.GetHeight() + extraHeight)
		book.Draw(xOff, yOff + extraHeight, scale, "shopBook")
		local buttonX = xOff + book.GetOfferOffset()
		local canAfford = TableHandler.CanAffordShopBook(book.GetScore())
		local offerActive = swapSelected and (swapSelected.type == "mySwapSelected")
		local highlight = canAfford and swapSelected and (swapSelected.type == "shopSwapSelected") and (swapSelected.index == i)
		if InterfaceUtil.DrawButton(
				buttonX, yOff + Global.STAMP_HEIGHT*book.GetHeight() + 10 + extraHeight, 120, 50, mousePos,
				"Trade", not canAfford, canAfford and offerActive, false, highlight, 2, 5) then
			TableHandler.SetUnderMouse({type = "shopSwapSelected", index = i})
		end
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf("♥ " .. book.GetScore(), buttonX + 138, yOff + Global.STAMP_HEIGHT*book.GetHeight() + 15 + extraHeight, Global.STAMP_WIDTH*3)
		
		xOff = xOff - 120
		if book.GetWidth() == 2 then
			xOff = xOff - 8
		elseif book.GetWidth() == 4 then
			xOff = xOff + 10
		end
	end

end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end


function api.Draw(drawQueue)
	drawQueue:push({y=50; f=function()
		DrawBooks(self.books, true)
		
		local tutorialPhase = TableHandler.GetTutorialPhase()
		if tutorialPhase and tutorialPhase < 3.9 then
			return
		end
		local mousePos = self.world.GetMousePositionInterface()
		
		local xOff = Global.WINDOW_X * 0.76
		local yOff = Global.WINDOW_Y * 0.035
		--love.graphics.setColor(0, 0, 0, 1)
		--Font.SetSize(2)
		--love.graphics.printf("Visit Shop", xOff - 50, yOff, 250, "center")
		for i = 1, #ShopDefs do
			local shopDef = ShopDefs[i]
			if i >= self.bestShopSoFar - ShopDefsData.shopLookahead or self.world.IsGodMode() then
				local canEnter = TableHandler.CanEnterShop(shopDef) or self.world.IsGodMode()
				if InterfaceUtil.DrawButton(xOff, yOff, 410, 60, mousePos, shopDef.name, not canEnter, false, true, highlight or (i == api.GetCurrentShopIndex()), 2, 8) then
					TableHandler.SetUnderMouse({type = "selectShop", index = i, cost = shopDef.cost, tooltip = shopDef.desc})
				end
			end
			yOff = yOff + 80
		end
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		bestShopSoFar = ShopDefsData.starterShop,
		books = {}
	}
end

return api
