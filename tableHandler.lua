local ShopDefsData = require("defs/shopDefs")
local ShopDefs = ShopDefsData.def 
local NewStamp = require("objects/stamp")
local SideboardDefs = require("defs/sideboardDefs")

local self = {}
local api = {}

--------------------------------------------------
-- Helpers
--------------------------------------------------

local function DecayTempText()
	if self.tempText then
		self.tempTextDecay = (self.tempTextDecay or 1)
	end
end

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

function api.GetSideboardDrawPosition(index)
	local alwaysShow = (index == 0)
	index = index + (SideboardDefs.maxSlots - self.sideboardDrawSize)
	if self.tutorialPhase then
		if self.tutorialPhase <= self.enabledOnPhase.sideboard - 0.6 then
			index = index + 4
		elseif self.tutorialPhase <= self.enabledOnPhase.sideboard then
			index = index + (self.enabledOnPhase.sideboard - self.tutorialPhase) * 4
		end
	end
	if alwaysShow then
		index = math.min(index, 5)
	end
	local x = self.sideboardX + (index - 1) * self.sideboardLean
	local y = self.sideboardY + self.bookScale * Global.STAMP_HEIGHT * (index - 0.5) + self.sideboardGap * (index - 1)
	return x, y
end

local function GetBookDimensions(book, index)
	local bx, by = GetBookDrawPosition(index)
	local bw, bh = book.GetWidth() * self.bookScale * Global.STAMP_WIDTH, book.GetHeight() * self.bookScale * Global.STAMP_HEIGHT
	return bx, by, bw, bh
end

local function GetMoneyPosition()
	if not self.tutorialPhase then
		return self.moneyX, self.moneyY
	end
	local mx = self.moneyX
	if self.tutorialPhase <= self.enabledOnPhase.money - 0.7 then
		mx = mx + 1200
	elseif self.tutorialPhase <= self.enabledOnPhase.money then
		mx = mx + (self.enabledOnPhase.money - self.tutorialPhase) * 1200
	end
	return mx, self.moneyY
end

local function GetSpotPosition(placePos)
	if not placePos then
		return false
	end
	if placePos.type == "sideboard" then
		local x, y = api.GetSideboardDrawPosition(placePos.index)
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
		local bookMult = book.GetRowColumnGlobalMult()
		local bookStamp = book.ReplaceStamp(placePos.x, placePos.y, self.heldStamp or false)
		if self.heldStamp and placePos.index then
			if book.GetRowColumnGlobalMult() > bookMult then
				local bx, by, bw, bh = GetBookDimensions(book, placePos.index)
				BookHelper.SpawnAllMultiplierEffects(book.GetSelfData(), bx, by, bw, bh)
			else
				local bx, by, bw, bh = GetBookDimensions(book, placePos.index)
				BookHelper.SpawnStampPlaceEffect(book.GetSelfData(), placePos, bx, by, bw, bh)
			end
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
		InterfaceUtil.ResetAnimDt()
		if self.oldSwapSelected and self.oldSwapSelected.type ~= self.swapSelected.type then
			local bookIndex, shopIndex = GetSwapIndecies()
			local shopBook = ShopHandler.ReplaceBook(self.books[bookIndex], shopIndex)
			api.TutorialBoughtBook()
			DecayTempText()
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
		InterfaceUtil.ResetAnimDt()
		if api.CanEnterShop(ShopDefs[placePos.index]) or self.world.IsGodMode() then
			DecayTempText()
			if ShopDefs[placePos.index].cost then
				self.money = math.max(0, self.money - ShopDefs[placePos.index].cost)
			end
			ShopHandler.RefreshShop(placePos.index)
		end
	elseif placePos.type == "buyMoreSideboard" then
		local cost = SideboardDefs.unlockCosts[self.sideboardSize + 1]
		if cost and cost <= self.money and self.sideboardSize < SideboardDefs.maxSlots then
			self.money = self.money - cost
			self.sideboardSize = self.sideboardSize + 1
		end
	end
end

--------------------------------------------------
-- API
--------------------------------------------------

function api.SetTooltip(text)
	self.externalTooltip = text
end

function api.GetBookCount()
	return #self.books
end

function api.AddBook(bookType, text)
	self.books[#self.books + 1] = BookHelper.GetBook(bookType)
	self.books[#self.books].SetPosition({1 - math.random()*0.1, 0})
	if text then
		self.tempText = text
		self.tempTextDecay = false
	end
end

function api.AddMoney(amount)
	self.money = self.money + amount
end

function api.PlaceStampAndMaybeDoAbility(placing, target, book, px, py)
	if target and placing and placing.def.PlaceAbilityCheck then
		if placing.def.PlaceAbilityCheck(placing, target, book, px, py) then
			if placing.def.placeConsumes then
				placing.quality = placing.quality - StampConst.QUALITY_CONSUMED_PER_ABILITY
			end
			local destroySelf = (placing.quality < 1)
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
	if self.world.IsGodMode() then
		return true
	end
	if self.swapSelected and self.swapSelected.type == "mySwapSelected" then
		return shopScore <= self.books[self.swapSelected.index].GetScore()
	end
	return shopScore <= api.GetMaxBookValue()
end

function api.CanEnterShop(shopDef)
	if shopDef.cost and not shopDef.waiveCostIfNoMoney and shopDef.cost > self.money then
		return false
	end
	if ShopHandler.GetBestSoFar() <= shopDef.index then
		return true
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
-- Tutorial
--------------------------------------------------

function api.GetTutorialPhase()
	return self.tutorialPhase
end

function api.TutorialBoughtBook()
	if self.tutorialPhase then
		self.wantedTutorialPhase = self.wantedTutorialPhase + 1
	end
end

function api.UniqueBestBook()
	local best = 1
	for i = 1, #self.books do
		if self.books[i].GetScore() > self.books[best].GetScore() then
			best = i
		end
	end
	return best
end

local function MaxBookScore()
	local score = 0
	for i = 1, #self.books do
		score = math.max(score, self.books[i].GetScore())
	end
	return score
end

local function DoTutorial(dt)
	if self.world.GetCosmos().WantSkipTutorial() then
		self.tutorialPhase = false
		if #self.books == 1 then
			self.books[#self.books + 1] = BookHelper.GetBook("starter_2")
			self.books[1].SetPosition({0.3, 0})
			self.books[1].SetVelocity({10, 0})
			self.books[2].SetPosition({-0.25, 0})
		end
		if #self.books == 2 then
			self.books[#self.books + 1] = BookHelper.GetBook("starter_3")
			self.books[3].SetPosition({0.9, 0})
		end
		return
	end
	if self.tutorialPhase == 1 then
		if MaxBookScore() >= 35 then
			self.wantedTutorialPhase = math.max(2, self.wantedTutorialPhase)
		end
	elseif self.tutorialPhase == 2 then
		if MaxBookScore() >= 50 then
			self.wantedTutorialPhase = math.max(3, self.wantedTutorialPhase)
		end
	elseif self.tutorialPhase == 3 then
		if MaxBookScore() >= 70 then
			self.wantedTutorialPhase = math.max(4, self.wantedTutorialPhase)
		end
	elseif self.tutorialPhase == 4 then
		if ShopHandler.GetCurrentShopIndex() then
			self.wantedTutorialPhase = math.max(5, self.wantedTutorialPhase)
		end
	end
	if self.tutorialPhase < self.wantedTutorialPhase then
		self.tutorialPhase = math.min(self.tutorialPhase + dt*0.75, self.wantedTutorialPhase)
	end
	
	if self.tutorialPhase > 2.6 and #self.books == 1 then
		self.books[#self.books + 1] = BookHelper.GetBook("starter_2")
		self.books[1].SetPosition({0.3, 0})
		self.books[1].SetVelocity({10, 0})
		self.books[2].SetPosition({-0.25, 0})
	end
	if self.tutorialPhase > 4.1 and #self.books == 2 then
		self.books[#self.books + 1] = BookHelper.GetBook("starter_3")
		self.books[3].SetPosition({0.9, 0})
	end
	if self.tutorialPhase >= 7 then
		self.tutorialPhase = false
	end
end

local function DrawTutorial()
	if self.tutorialPhase < 1.5 then
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1 - (self.tutorialPhase - 1) * 2)
		love.graphics.printf("Nothing beats a well organised stamp collection. Improve this one by shifting the bird stamp up so the prices read 2¢, 3¢, 4¢.\n\nClick on the bird to pick it up, then click on a slot to place it.", Global.WINDOW_X*0.08, Global.WINDOW_Y*0.2, 490)
		Font.SetSize(2)
		love.graphics.printf("♥ " .. MaxBookScore() .. " / ♥ 35", Global.WINDOW_X*0.24, Global.WINDOW_Y*0.45, 780, "center")
	elseif self.tutorialPhase > 1.6 and self.tutorialPhase <= 2.5 then
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1 - (self.tutorialPhase - 2) * 2)
		love.graphics.printf("Every collector needs a stamp tray. Use the orange planet from the tray to reach ♥ 50.\n\nMatch colours or make ¢ sequences to multiply ♥ in a line. Sequences need at least three stamps.", Global.WINDOW_X*0.08, Global.WINDOW_Y*0.2, 490)
		Font.SetSize(2)
		love.graphics.printf("♥ " .. MaxBookScore() .. " / ♥ 50", Global.WINDOW_X*0.24, Global.WINDOW_Y*0.45, 780, "center")
	elseif self.tutorialPhase > 2.8 and self.tutorialPhase <= 3.5 then
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1 - (self.tutorialPhase - 3) * 2)
		love.graphics.printf("Mix and match the stamps of two books to make a book worth ♥ 70. Hover your mouse over the icons below the album to see bonuses.", Global.WINDOW_X*0.25, Global.WINDOW_Y*0.25, 780)
		love.graphics.printf("♥ " .. MaxBookScore() .. " / ♥ 70", Global.WINDOW_X*0.24, Global.WINDOW_Y*0.45, 780, "center")
	elseif self.tutorialPhase > 3.8 and self.tutorialPhase <= 4.5 then
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1 - (self.tutorialPhase - 4) * 2)
		love.graphics.printf("Click on Stamp Alley to trade with other collectors. Stamps can be sold to pay for travel, but avoid selling too many.", Global.WINDOW_X*0.25, Global.WINDOW_Y*0.39, 950)
	elseif self.tutorialPhase > 4.8 and self.tutorialPhase <= 5.5 then
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1 - (self.tutorialPhase - 5) * 2)
		love.graphics.printf("Try to trade books of similar ♥. Store excess stamps in other books to build up a collection. Reroll to see new trades.", Global.WINDOW_X*0.25, Global.WINDOW_Y*0.39, 850)
	elseif self.tutorialPhase > 5.8 and self.tutorialPhase <= 6.5 then
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1 - (self.tutorialPhase - 6) * 2)
		love.graphics.printf("Improve the ♥ of your books to gain access to better shops and assemble the ultimate stamp book.", Global.WINDOW_X*0.25, Global.WINDOW_Y*0.37, 950)
	end
end

--------------------------------------------------
-- Win
--------------------------------------------------

local function DrawWin()
	Font.SetSize(2)
	local xPos = Global.WINDOW_X*0.25
	local yPos = Global.WINDOW_Y*0.32 - math.min(9.3, self.winProgress)*35
	if self.winProgress > 0.9 then
		love.graphics.setColor(0, 0, 0, math.min(1, (self.winProgress - 0.9)*3))
		love.graphics.printf("You approach the stamp podium.", xPos, yPos, 860)
	end
	if self.winProgress > 1.9 then
		love.graphics.setColor(0, 0, 0, math.min(1, (self.winProgress - 1.9)*1.5))
		love.graphics.printf("\nBook in hand.", xPos, yPos, 860)
	end
	if self.winProgress > 5 then
		love.graphics.setColor(0, 0, 0, math.min(1, (self.winProgress - 5)*2))
		love.graphics.printf("\n\nA gasp rings out, never before have the Stamp Masters seen such an exquisite collection.", xPos, yPos + 15, 860)
	end
	if self.winProgress > 8.4 then
		love.graphics.setColor(0, 0, 0, math.min(1, (self.winProgress - 8.4)*1.1))
		if ShopHandler.GetBrutalThroughout() then
			love.graphics.printf("\n\n\n\nThey are particularly impressed by your completion of such a brutal journey.", xPos, yPos + 30, 860)
		else
			love.graphics.printf("\n\n\n\nThe vote is unanimous as you are elected Stamp Grandmaster for life.", xPos, yPos + 30, 860)
		end
	end
	if self.winProgress > 10.5 then
		love.graphics.setColor(0, 0, 0, math.min(1, (self.winProgress - 10.5)*2))
		if ShopHandler.GetBrutalThroughout() then
			love.graphics.printf("\n\n\n\n\n                                      The vote is unanimous.", xPos, yPos + 30, 860)
		else
			love.graphics.printf("\n\n\n\n\n\nThanks for playing", xPos, yPos + 38, 740, "center")
		end
	end
	if self.winProgress > 12.2 and ShopHandler.GetBrutalThroughout() then
		love.graphics.setColor(0, 0, 0, math.min(1, (self.winProgress - 12.2)*2))
		love.graphics.printf("\n\n\n\n\n\nThey elect you Stamp Grandmaster for life.", xPos, yPos + 38, 1080)
	end
	if self.winProgress > 13 and ShopHandler.GetBrutalThroughout() then
		love.graphics.setColor(0, 0, 0, math.min(1, (self.winProgress - 13)*2))
		love.graphics.printf("Thanks for playing!", -450 + (self.winProgress - 13)*250*(self.winProgress - 12) + math.random()*50, 600 - (self.winProgress - 13)*(self.winProgress - 13)*80 + math.random()*50, 500, "center")
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
	local wantToSeeSlots = math.min(self.sideboardSize + 1, SideboardDefs.maxSlots)
	if self.sideboardDrawSize < wantToSeeSlots then
		self.sideboardDrawSize = math.min(self.sideboardDrawSize + dt, wantToSeeSlots)
	end
	if self.tutorialPhase then
		DoTutorial(dt)
	end
	if self.tempTextDecay then
		self.tempTextDecay = self.tempTextDecay - dt*1.8
		if self.tempTextDecay <= 0 then
			self.tempTextDecay = false
			self.tempText = false
		end
	end
	if ShopHandler.InWinShop() then
		self.winProgress = (self.winProgress or 0) + dt
	end
end

local function DrawBook(index, xScale, yScale, scale, mousePos, wantTooltip)
	local book = self.books[index]
	local baseX, baseY = GetBookDrawPosition(index)
	Resources.DrawImage("book_width_" .. book.GetWidth(), baseX - 60, baseY - 94)
	book.Draw(baseX + 1, baseY + 2, scale, "book", index)
	local buttonX = baseX + book.GetOfferOffset()
	local canAfford = ShopHandler.CanSwapFromTable(book.GetScore())
	local highlight = canAfford and self.swapSelected and (self.swapSelected.type == "mySwapSelected") and (self.swapSelected.index == index)
	local tradeSelected = self.swapSelected and (self.swapSelected.type == "shopSwapSelected")
	if InterfaceUtil.DrawButton(buttonX, baseY - 60, 120, 50, mousePos, "Offer", not canAfford, canAfford and tradeSelected, false, highlight, 2, 5) then
		api.SetUnderMouse({type = "mySwapSelected", index = index})
	end
	Font.SetSize(2)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.printf("♥ " .. book.GetScore(), buttonX + 138, baseY - 55, xScale*3)
	
	-- Draw bonuses
	local xOff = baseX + xScale * 0.35
	local yOff = baseY + yScale*book.GetHeight() + yScale / 2
	local bonusCount, keyByIndex, bonusByKey = book.GetBonusIterationData()
	for i = 1, bonusCount do
		local bonus = bonusByKey[keyByIndex[i]]
		local hovered = (not wantTooltip) and util.PosInRectangle(mousePos, xOff - xScale*0.5/2, yOff - yScale*0.5/2, xScale*0.5, yScale*0.5)
		Resources.DrawImage(bonus.image, xOff, yOff, false, hovered and 1 or 0.6, 0.5 * self.bonusIconScale)
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
	drawQueue:push({y=20; f=function()
		if self.tempText then
			Font.SetSize(2)
			love.graphics.setColor(0, 0, 0, self.tempTextDecay or 1)
			love.graphics.printf(self.tempText, Global.WINDOW_X*0.25, Global.WINDOW_Y*0.345, 850)
		elseif self.tutorialPhase then
			DrawTutorial()
		end
	end})
	drawQueue:push({y=100; f=function()
		local mousePos = self.world.GetMousePositionInterface()
		local scale = self.bookScale
		local xScale = scale * Global.STAMP_WIDTH
		local yScale = scale * Global.STAMP_HEIGHT
		
		local wantTooltip = false
		local bestBook = api.UniqueBestBook()
		for i = 1, #self.books do
			if i ~= bestBook then
				wantTooltip = DrawBook(i, xScale, yScale, scale, mousePos, wantTooltip)
			end
		end
		wantTooltip = DrawBook(bestBook, xScale, yScale, scale, mousePos, wantTooltip)
		
		local sideX, sideY = api.GetSideboardDrawPosition(1)
		Resources.DrawImage("sideboard", sideX - 412, sideY - 108)
		
		for i = 1, self.sideboardSize do
			local x, y = api.GetSideboardDrawPosition(i)
			local underMouse = api.CheckAndSetUnderMouse(x, y, xScale, yScale, {type = "sideboard", index = i})
			if underMouse then
				love.graphics.setLineWidth(3)
				love.graphics.setColor(0.2, 1, 0.2, 1)
			else
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end
			love.graphics.rectangle("line", x, y, xScale, yScale)
			if self.sideboard[i] then
				self.sideboard[i].Draw(x + xScale/2, y + yScale/2, scale)
			end
		end
		
		if self.winProgress and ShopHandler.InWinShop() then
			DrawWin()
		end
		
		local buySideboard = false
		if self.sideboardSize < SideboardDefs.maxSlots and (not self.tutorialPhase or self.tutorialPhase >= self.enabledOnPhase.money) then
			local x, y = api.GetSideboardDrawPosition(self.sideboardSize + 1)
			local underMouse = api.CheckAndSetUnderMouse(x, y, xScale, yScale, {type = "buyMoreSideboard"})
			if underMouse then
				love.graphics.setLineWidth(3)
				love.graphics.setColor(0.2, 1, 0.2, 1)
				wantTooltip = "Tray Upgrade\nSpend $" .. SideboardDefs.unlockCosts[self.sideboardSize + 1] .. " to increase the size of your stamp tray."
				buySideboard = SideboardDefs.unlockCosts[self.sideboardSize + 1]
			else
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end
			love.graphics.rectangle("line", x, y, xScale, yScale)
			Font.SetSize(2)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf("$" .. SideboardDefs.unlockCosts[self.sideboardSize + 1], x, y + yScale*0.2, xScale, "center")
		end
		
		local moneyPosX, moneyPosY = GetMoneyPosition()
		Resources.DrawImage("tooltip", self.tooltipX - 80, self.tooltipY - 80)
		Resources.DrawImage("money_bag", moneyPosX, moneyPosY, false, false, 1.8)
		
		if InterfaceUtil.DrawButton(moneyPosX - 125, moneyPosY - 12, 220, 70, mousePos, "Sell Stamp", false, false, false, false, 2, 12) then
			if self.heldStamp then
				api.SetUnderMouse({type = "sellStamp", income = self.heldStamp.GetSellValue()})
			else
				wantTooltip = "Drop a stamp here to sell it."
			end
		end
		
		local shopRequirement = ShopHandler.NextShopRequirement()
		if shopRequirement and (not self.tutorialPhase or self.tutorialPhase > 5.8) then
			Font.SetSize(2)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf("♥ " .. MaxBookScore() .. " / ♥ " .. shopRequirement, Global.WINDOW_X*0.24, Global.WINDOW_Y*0.45, 780, "center")
		end
		
		if not wantTooltip then
			local tooltipStamp, tBook, tX, tY = GetTooltipStamp()
			if tooltipStamp then
				wantTooltip = tooltipStamp.GetTooltip(tBook, tX, tY)
			end
		end
		if not wantTooltip and self.underMouse and self.underMouse.tooltip then
			wantTooltip = self.underMouse.tooltip
		end
		
		if wantTooltip or self.externalTooltip then
			Font.SetSize(3)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.printf(wantTooltip or self.externalTooltip, self.tooltipX, self.tooltipY, 340)
		end
		self.externalTooltip = false
		
		local moneyChangeString = ""
		if buySideboard then
			moneyChangeString = " - " .. buySideboard
		elseif self.heldSellAbilityAmount then
			moneyChangeString = " + " .. self.heldSellAbilityAmount
		elseif self.underMouse and self.underMouse.cost and self.underMouse.cost > 0 then
			moneyChangeString = " - " .. self.underMouse.cost
		elseif self.underMouse and self.underMouse.income and self.underMouse.income ~= 0 then
			moneyChangeString = " + " .. self.underMouse.income
		end
		Font.SetSize(1)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf("$" .. self.money .. moneyChangeString, moneyPosX - 120, moneyPosY - 85, 500)
		
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		books = {},
		sideboardSize = SideboardDefs.startSlots,
		sideboardDrawSize = SideboardDefs.startSlots + 1,
		sideboard = {},
		tutorialPhase = 1,
		wantedTutorialPhase = 1,
		enabledOnPhase = {
			money = 4,
			sideboard = 2,
		},
		money = 10,
		moneyX = Global.WINDOW_X * 0.9 + 20,
		moneyY = Global.WINDOW_Y * 0.65,
		tooltipX = Global.WINDOW_X * 0.8 + 20,
		tooltipY = Global.WINDOW_Y * 0.6 + 180,
		sideboardX = 40,
		sideboardY = Global.WINDOW_Y*0.52 + 18,
		sideboardLean = 10,
		sideboardGap = 18,
		bookDrawSpacing = 390,
		bookScale = 1,
		bonusIconScale = 1.3,
	}
	self.sideboard[1] = NewStamp({name = "planet_stamp", cost = 7, quality = 2, color = 1, rarity = 2})
	
	
	self.books[#self.books + 1] = BookHelper.GetBook("starter")
	self.books[1].SetPosition({0, 0})
end

return api
