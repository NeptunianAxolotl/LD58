local ShopDefs = require("defs/shopDefs")
local NewStamp = require("objects/stamp")

local self = {}
local api = {}

--------------------------------------------------
-- Helpers
--------------------------------------------------

local function GetTooltipStamp()
	if self.heldStamp then
		return self.heldStamp
	end
	if not self.underMouse then
		return false
	end
	if self.underMouse.type == "sideboard" then
		local index = self.underMouse.index
		return self.sideboard[index] or false
	elseif self.underMouse.type == "book" or self.underMouse.type == "shopBook" then
		local book = self.underMouse.book
		return book.GetStampAt(self.underMouse.x, self.underMouse.y) or false, book, self.underMouse.x, self.underMouse.y
	end
	return false
end

local function GetMousePlaceStamp()
	if not self.underMouse then
		return false
	end
	if self.underMouse.type == "sideboard" then
		local index = self.underMouse.index
		return self.sideboard[index] or false
	elseif self.underMouse.type == "book" then
		local book = self.underMouse.book
		return book.GetStampAt(self.underMouse.x, self.underMouse.y) or false, book, self.underMouse.x, self.underMouse.y
	end
	return false
end

local function GetSwapIndecies()
	if self.oldSwapSelected.type == "mySwapSelected" then
		return self.oldSwapSelected.index, self.swapSelected.index
	else
		return self.swapSelected.index, self.oldSwapSelected.index
	end
end

local function GetBookDrawPosition(index)
	local book = self.books[index]
	local bookPos = book.GetPosition()
	local baseX = bookPos[1]*450 + 860 - self.bookScale*Global.STAMP_WIDTH*book.GetWidth()/2
	local baseY = 650 + 45*bookPos[1]*bookPos[1] - bookPos[2]*30
	return baseX, baseY
end

local function GetSideboardDrawPosition(index)
	index = index + (self.maxSideboard - self.sideboardDrawSize)
	local x = self.sideboardX + (index - 1) * self.sideboardGap/2
	local y = self.sideboardY + self.bookScale * Global.STAMP_HEIGHT * (index - 0.5) + self.sideboardGap * (index - 1)
	return x, y
end

local function GetBookDimensions(book, index)
	local bx, by = GetBookDrawPosition(index)
	local bw, bh = book.GetWidth() * self.bookScale * Global.STAMP_WIDTH, book.GetHeight() * self.bookScale * Global.STAMP_HEIGHT
	return bx, by, bw, bh
end

local function GetSpotPosition(placePos)
	if not placePos then
		return false
	end
	if placePos.type == "sideboard" then
		local x, y = GetSideboardDrawPosition(placePos.index)
		return {x + self.bookScale * Global.STAMP_WIDTH/2, y + self.bookScale * Global.STAMP_HEIGHT/2}
	elseif placePos.type == "book" then
		local book = placePos.book
		local bx, by, bw, bh = GetBookDimensions(book, placePos.index)
		return {bx + bw*(placePos.x - 0.5)/book.GetWidth(), by + bh*(placePos.y - 0.5)/book.GetHeight()}
	end
end

local function MousePlaceClick(placePos)
	if not placePos then
		return false
	end
	if placePos.type == "sideboard" then
		local index = placePos.index
		self.heldStamp, self.sideboard[index] = api.PlaceStampAndMaybeDoAbility(self.heldStamp, self.sideboard[index])
		local leftEmptySpace = self.heldStamp and not self.sideboard[index]
		if self.sideboard[index] and self.heldStamp and self.emptySpot and self.world.GetCosmos().TransposePlacementMode() then
			local spot = self.emptySpot
			self.emptySpot = false
			MousePlaceClick(spot)
		end
		return leftEmptySpace
	elseif placePos.type == "book" then
		local book = placePos.book
		local bookStamp = book.ReplaceStamp(placePos.x, placePos.y, self.heldStamp or false)
		if self.heldStamp and placePos.index then
			local bx, by, bw, bh = GetBookDimensions(book, placePos.index)
			BookHelper.SpawnStampPlaceEffect(book.GetSelfData(), placePos, bx, by, bw, bh)
		end
		local leftEmptySpace = bookStamp and not self.heldStamp
		self.heldStamp = bookStamp
		if bookStamp and self.heldStamp and self.emptySpot and self.world.GetCosmos().TransposePlacementMode() then
			local spot = self.emptySpot
			self.emptySpot = false
			MousePlaceClick(spot)
		end
		return leftEmptySpace
	elseif placePos.type == "sellStamp" then
		if self.heldStamp then
			api.AddMoney(self.heldStamp.GetSellValue())
			self.heldStamp = false
		end
	elseif placePos.type == "mySwapSelected" or placePos.type == "shopSwapSelected" then
		self.swapSelected = placePos
		if self.oldSwapSelected and self.oldSwapSelected.type ~= self.swapSelected.type then
			local bookIndex, shopIndex = GetSwapIndecies()
			local shopBook = ShopHandler.ReplaceBook(self.books[bookIndex], shopIndex)
			if shopBook then
				local bookPos = self.books[bookIndex].GetPosition()
				shopBook.SetPosition({bookPos[1] + math.random()*0.06 - 0.03, 0.2 + math.random()*0.3})
				self.books[bookIndex] = shopBook
				self.swapSelected = false
			end
		elseif self.oldSwapSelected and self.oldSwapSelected.type == self.swapSelected.type and self.oldSwapSelected.index == self.swapSelected.index then
			self.swapSelected = false
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

--------------------------------------------------
-- API
--------------------------------------------------

function api.AddMoney(amount)
	self.money = self.money + amount
end

function api.PlaceStampAndMaybeDoAbility(placing, target, book, px, py)
	if target and placing and placing.def.PlaceAbilityCheck then
		if placing.def.PlaceAbilityCheck(placing, target, book, px, py) then
			local destroySelf = placing.def.placeConsumes
			placing.def.DoPlaceAbility(placing, target, book, px, py)
			if target.wantDestroy then
				target = false
			end
			if destroySelf then
				placing = false
			end
		end
	else
		target, placing = placing, target -- Swap stamps if no ability
	end
	return placing, target
end

function api.BookOnOffer()
	return self.swapSelected and self.swapSelected.type == "mySwapSelected" and self.swapSelected.index
end

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

function api.GetTotalBookValue()
	local totalScore = 0
	for i = 1, #self.books do
			totalScore = totalScore + self.books[i].GetScore()
	end
	return totalScore
end

function api.GetAverageFullness()
  local totalFullness = 0
  for i = 1, #self.books do
			totalFullness = totalFullness + self.books[i].GetFullness()
	end
	return totalFullness / #self.books
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
	for i = 1, #self.books do
		self.books[i].UpdatePhysics(dt, i, self.books)
	end
	if self.sideboardDrawSize < self.sideboardSize then
		self.sideboardDrawSize = math.min(self.sideboardDrawSize + dt, self.sideboardSize)
	end
end

local function DrawBook(index, xScale, yScale, scale, mousePos, wantTooltip)
	local book = self.books[index]
	local baseX, baseY = GetBookDrawPosition(index)
	Resources.DrawImage("book_width_" .. book.GetWidth(), baseX - 60, baseY - 94)
	book.Draw(baseX + 1, baseY + 2, scale, "book", index)
	local canAfford = ShopHandler.CanSwapFromTable(book.GetScore())
	local highlight = canAfford and self.swapSelected and (self.swapSelected.type == "mySwapSelected") and (self.swapSelected.index == index)
	if InterfaceUtil.DrawButton(baseX + 5, baseY - 60, 120, 50, mousePos, "Offer", not canAfford, false, false, highlight, 2, 5) then
		api.SetUnderMouse({type = "mySwapSelected", index = index})
	end
	Font.SetSize(2)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.printf("♥ " .. book.GetScore(), baseX + 142, baseY - 54, xScale*3)
	
	-- Draw bonuses
	local xOff = baseX + xScale * 0.35
	local yOff = baseY + yScale*book.GetHeight() + yScale / 2
	local bonusCount, keyByIndex, bonusByKey = book.GetBonusIterationData()
	for i = 1, bonusCount do
		local bonus = bonusByKey[keyByIndex[i]]
		local hovered = (not wantTooltip) and util.PosInRectangle(mousePos, xOff - xScale*0.5/2, yOff - yScale*0.5/2, xScale*0.5, yScale*0.5)
		Resources.DrawImage(bonus.image, xOff, yOff, false, hovered and 1 or 0.6, 0.5)
		if hovered then
			Font.SetSize(3)
			love.graphics.setColor(0, 0, 0, 1)
			wantTooltip = bonus.humanName .. "\n" .. bonus.desc
			for j = 1, #bonus.posList do
				local px, py = bonus.posList[j][1] - 1, bonus.posList[j][2] - 1
				love.graphics.setLineWidth(3)
				love.graphics.setColor(0.2, 1, 0.2, 1)
				love.graphics.rectangle("line", baseX + px*xScale, baseY + py*yScale, xScale, yScale)
			end
		end
		xOff = xOff + xScale*(book.GetWidth() - 0.7) / (book.GetWidth()*2 - 2)
		if i%(book.GetWidth()*2 - 1) == 0 then
			xOff = baseX + xScale * 0.35
			yOff = yOff + yScale * 0.6
		end
	end
	return wantTooltip
end

function api.Draw(drawQueue)
	if self.heldStamp then
		drawQueue:push({y=500; f=function()
			self.heldSellAbilityAmount = false
			if self.heldStamp then
				local mouse = self.world.GetMousePositionInterface()
				local scale = 1
				if self.emptySpot then
					local pos = GetSpotPosition(self.emptySpot)
					self.heldStamp.Draw(pos[1], pos[2], scale, 0.15)
				end
				if self.heldStamp.def.PlaceAbilityCheck then
					local other, book, px, py = GetMousePlaceStamp()
					if other and self.heldStamp.def.PlaceAbilityMoneyGain and self.heldStamp.def.PlaceAbilityCheck(self.heldStamp, other, book, px, py) then
						self.heldSellAbilityAmount = self.heldStamp.def.PlaceAbilityMoneyGain(self, other, book, px, py)
					end
					if self.emptySpot then
						local pos = GetSpotPosition(self.emptySpot)
						love.graphics.setLineWidth(4)
						if not other then
							love.graphics.setColor(0.3, 0.95, 0.2, 0.4)
						elseif self.heldStamp.def.PlaceAbilityCheck(self.heldStamp, other, book, px, py) then
							love.graphics.setColor(0.3, 0.95, 0.2, 1)
						else
							love.graphics.setColor(0.95, 0.1, 0.2, 1)
						end
						love.graphics.line(pos[1], pos[2], mouse[1], mouse[2])
					end
				else
					self.heldStamp.Draw(mouse[1], mouse[2], scale)
				end
			end
		end})
	else
		self.heldSellAbilityAmount = false
	end
	drawQueue:push({y=100; f=function()
		local mousePos = self.world.GetMousePositionInterface()
		local scale = self.bookScale
		local xScale = scale * Global.STAMP_WIDTH
		local yScale = scale * Global.STAMP_HEIGHT
		
		local wantTooltip = false
		for i = 1, #self.books do
			wantTooltip = DrawBook(i, xScale, yScale, scale, mousePos, wantTooltip)
		end
		
		local sideX, sideY = GetSideboardDrawPosition(1)
		Resources.DrawImage("sideboard", sideX - 412, sideY - 108)
		
		for i = 1, self.sideboardSize do
			local x, y = GetSideboardDrawPosition(i)
			local underMouse = api.CheckAndSetUnderMouse(x, y, xScale, yScale, {type = "sideboard", index = i})
			if underMouse then
				love.graphics.setLineWidth(3)
				love.graphics.setColor(0.2, 1, 0.2, 1)
			else
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0, 1)
			end
			love.graphics.rectangle("line", x, y, xScale, yScale)
			if self.sideboard[i] then
				self.sideboard[i].Draw(x + xScale/2, y + yScale/2, scale)
			end
		end
		
		Resources.DrawImage("tooltip", self.tooltipX - 80, self.tooltipY - 80)
		Resources.DrawImage("money_bag", self.moneyX, self.moneyY, false, false, 1.8)
		
		if InterfaceUtil.DrawButton(self.moneyX - 125, self.moneyY - 15, 220, 70, mousePos, "Sell Stamp", false, false, false, false, 2, 12) then
			if self.heldStamp then
				api.SetUnderMouse({type = "sellStamp", income = self.heldStamp.GetSellValue()})
			else
				wantTooltip = "Drop a stamp here to sell it."
			end
		end
		
		if not wantTooltip then
			local tooltipStamp, tBook, tX, tY = GetTooltipStamp()
			if tooltipStamp then
				wantTooltip = tooltipStamp.GetTooltip(tBook, tX, tY)
			end
		end
		
		if wantTooltip then
			Font.SetSize(3)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf(wantTooltip, self.tooltipX, self.tooltipY, 380)
		end
		
		local moneyChangeString = ""
		if self.heldSellAbilityAmount then
			moneyChangeString = " + " .. self.heldSellAbilityAmount
		elseif self.underMouse and self.underMouse.cost then
			moneyChangeString = " - " .. self.underMouse.cost
		elseif self.underMouse and self.underMouse.income then
			moneyChangeString = " + " .. self.underMouse.income
		end
		Font.SetSize(1)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf("$" .. self.money .. moneyChangeString, self.moneyX - 110, self.moneyY - 90, 500)
		
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		books = {},
		sideboardSize = 2,
		sideboardDrawSize = 2,
		maxSideboard = 5,
		sideboard = {},
		money = 10,
		moneyX = Global.WINDOW_X * 0.9 + 20,
		moneyY = Global.WINDOW_Y * 0.65,
		tooltipX = Global.WINDOW_X * 0.8 + 20,
		tooltipY = Global.WINDOW_Y * 0.6 + 180,
		sideboardX = 40,
		sideboardY = Global.WINDOW_Y*0.52 + 18,
		sideboardGap = 18,
		bookDrawSpacing = 390,
		bookScale = 1,
	}
	self.sideboard[1] = NewStamp({name = "basic_stamp", cost = 1 + math.floor(math.random()*3), quality = 1 + math.floor(math.random()*4)})
	
	self.books[#self.books + 1] = BookHelper.GetBook("starter")
	self.books[#self.books + 1] = BookHelper.GetBook("starter")
	self.books[#self.books + 1] = BookHelper.GetBook("starter")
end

return api
