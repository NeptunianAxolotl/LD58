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

local function GetBookDimensions(book, index)
	local bx, by = self.bookDrawX + self.bookDrawSpacing*(index - 1), self.bookDrawY
	local bw, bh = book.GetWidth() * self.bookScale * Global.STAMP_WIDTH, book.GetHeight() * self.bookScale * Global.STAMP_HEIGHT
	return bx, by, bw, bh
end

local function GetSpotPosition(placePos)
	if not placePos then
		return false
	end
	if placePos.type == "sideboard" then
		local index = placePos.index
		local x = self.sideboardX + self.bookScale * Global.STAMP_WIDTH / 2
		local y = self.sideboardY + self.bookScale * Global.STAMP_HEIGHT * (index - 0.5) + self.sideboardGap * (index - 1)
		return {x, y}
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
		if self.sideboard[index] and self.heldStamp and self.emptySpot and Global.TRANSPOSE_PLACEMENT then
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
		if bookStamp and self.heldStamp and self.emptySpot and Global.TRANSPOSE_PLACEMENT then
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

local function DrawBook(index, xOff, yOff, xScale, yScale, scale, mousePos, drawnTooltip)
	local book = self.books[index]
	book.Draw(xOff, yOff, scale, "book", index)
	local canAfford = ShopHandler.CanSwapFromTable(book.GetScore())
	local highlight = canAfford and self.swapSelected and (self.swapSelected.type == "mySwapSelected") and (self.swapSelected.index == index)
	if InterfaceUtil.DrawButton(xOff + 5, yOff - 60, 120, 50, mousePos, "Offer", not canAfford, false, false, highlight, 2, 5) then
		api.SetUnderMouse({type = "mySwapSelected", index = index})
	end
	Font.SetSize(2)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.printf("♥ " .. book.GetScore(), xOff + 150, yOff - 50, xScale*3)
	
	-- Draw bonuses
	local baseX = xOff
	local baseY = yOff
	yOff = yOff + yScale*book.GetHeight() + yScale / 2
	xOff = xOff + xScale / 2
	local bonusCount, keyByIndex, bonusByKey = book.GetBonusIterationData()
	for i = 1, bonusCount do
		local bonus = bonusByKey[keyByIndex[i]]
		local hovered = (not drawnTooltip) and util.PosInRectangle(mousePos, xOff - xScale*0.45/2, yOff - yScale*0.45/2, xScale*0.45, yScale*0.45)
		Resources.DrawImage(bonus.image, xOff, yOff, false, hovered and 1 or 0.6, 0.45)
		if hovered then
			Font.SetSize(3)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf(bonus.humanName .. "\n" .. bonus.desc, self.tooltipX, self.tooltipY, 380)
			drawnTooltip = true
			for j = 1, #bonus.posList do
				local px, py = bonus.posList[j][1] - 1, bonus.posList[j][2] - 1
				print(px, py)
				love.graphics.setLineWidth(3)
				love.graphics.setColor(0.2, 1, 0.2, 1)
				love.graphics.rectangle("line", baseX + px*xScale, baseY + py*yScale, xScale, yScale)
			end
		end
		xOff = xOff + xScale/2
		if i%(book.GetWidth()*2 - 1) == 0 then
			xOff = baseX + xScale / 2
			yOff = yOff + yScale/2
		end
	end
	return drawnTooltip
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
		local xOff = self.sideboardX
		local yOff = self.sideboardY
		local scale = self.bookScale
		local xScale = scale * Global.STAMP_WIDTH
		local yScale = scale * Global.STAMP_HEIGHT
		
		for i = 1, self.sideboardSize do
			local underMouse = api.CheckAndSetUnderMouse(xOff, yOff, xScale, yScale, {type = "sideboard", index = i})
			if underMouse then
				love.graphics.setLineWidth(3)
				love.graphics.setColor(0.2, 1, 0.2, 1)
			else
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0, 1)
			end
			love.graphics.rectangle("line", xOff, yOff, xScale, yScale)
			if self.sideboard[i] then
				self.sideboard[i].Draw(xOff + xScale/2, yOff + yScale/2, scale)
			end
			yOff = yOff + yScale + self.sideboardGap
		end
		
		local drawnTooltip = false
		xOff = self.bookDrawX
		yOff = self.bookDrawY
		for i = 1, #self.books do
			drawnTooltip = DrawBook(i, xOff, yOff, xScale, yScale, scale, mousePos, drawnTooltip)
			xOff = xOff + self.bookDrawSpacing
		end
		
		xOff = self.tooltipX
		yOff = self.tooltipY
		
		if InterfaceUtil.DrawButton(xOff + 40, yOff - 95, 220, 70, mousePos, "Sell Stamp", false, false, false, false, 2, 12) then
			if self.heldStamp then
				api.SetUnderMouse({type = "sellStamp", income = self.heldStamp.GetSellValue()})
			else
				Font.SetSize(3)
				love.graphics.setColor(0, 0, 0, 1)
				love.graphics.printf("Drop a stamp here to sell it.", xOff - 120, yOff, 220)
				drawnTooltip = true
			end
		end
		
		if not drawnTooltip then
			local tooltipStamp, tBook, tX, tY = GetTooltipStamp()
			if tooltipStamp then
				Font.SetSize(3)
				love.graphics.setColor(0, 0, 0, 1)
				love.graphics.printf(tooltipStamp.GetTooltip(tBook, tX, tY), xOff, yOff, 380)
				drawnTooltip = true
			end
		end
		
		local moneyChangeString = ""
		if self.heldSellAbilityAmount then
			moneyChangeString = " + " .. self.heldSellAbilityAmount
		elseif self.underMouse and self.underMouse.cost then
			moneyChangeString = " - " .. self.underMouse.cost
		elseif self.underMouse and self.underMouse.income then
			moneyChangeString = " + " .. self.underMouse.income
		end
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf("Money: $" .. self.money .. moneyChangeString, xOff + 62, yOff - 150, xScale*3)
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		books = {},
		sideboardSize = 3,
		sideboard = {},
		money = 10,
		tooltipX = Global.WINDOW_X * 0.8 - 30,
		tooltipY = Global.WINDOW_Y * 0.6 + 95,
		sideboardX = Global.WINDOW_X*0.06,
		sideboardY = Global.WINDOW_Y*0.6 - 36,
		sideboardGap = 18,
		bookDrawX = Global.WINDOW_X*0.15,
		bookDrawY = Global.WINDOW_Y*0.6,
		bookDrawSpacing = 390,
		bookScale = 1,
	}
	self.sideboard[2] = NewStamp({name = "basic_stamp", cost = 1 + math.floor(math.random()*3), quality = 1 + math.floor(math.random()*4)})
	
	self.books[#self.books + 1] = BookHelper.GetBook("starter")
	self.books[#self.books + 1] = BookHelper.GetBook("starter")
	self.books[#self.books + 1] = BookHelper.GetBook("starter")
end

return api
