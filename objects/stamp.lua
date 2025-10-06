
local function PostInitStamp(self)
	local def = self.def
	if def.minQuality then
		self.quality = math.max(def.minQuality, self.quality)
	end
	if def.maxQuality then
		self.quality = math.min(def.maxQuality, self.quality)
	end
end

local function NewStamp(def)
	local self = {}
	self.def = StampDefs[def.name]
	self.name = def.name
	self.quality = def.quality
	self.def.InitRandomStamp(self, def)
	PostInitStamp(self)
	
	function self.GetAdjacencyScore(x, y, bonusDisplayTable, left, right, top, bottom)
		return self.def.GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	end
	
	function self.GetSoloScore()
		return self.def.GetSoloScore(self)
	end
	
	function self.GetSellValue()
		return self.def.GetSellValue(self)
	end
	
	function self.GetStampMultiplier(book, x, y)
		local multiplier = 1
		if book then
			multiplier = BookHelper.GetColScoreMultiplier(book.GetSelfData(), x) + BookHelper.GetRowScoreMultiplier(book.GetSelfData(), y) - 1
		end
		return multiplier
	end
	
	function self.GetTooltip(book, x, y)
		local tooltip = self.def.humanName
		tooltip = tooltip .. "\nQuality: " .. StampConst.qualityMap[self.quality]
		local adjBonus = book and BookHelper.GetStampAdjacencyScore(book.GetSelfData(), x, y) or 0
		local multiplier = self.GetStampMultiplier(book, x, y)
		if adjBonus == 0 then
			tooltip = tooltip .. "\nValue: ♥ " .. self.GetSoloScore()
		elseif adjBonus > 0 then
			tooltip = tooltip .. "\nValue: ♥ " .. (multiplier > 1 and "(" or "") .. self.GetSoloScore() .. " + " .. adjBonus .. (multiplier > 1 and ")" or "")
		else
			tooltip = tooltip .. "\nValue: ♥ " .. (multiplier > 1 and "(" or "") .. self.GetSoloScore() .. " - " .. (-1*adjBonus) .. (multiplier > 1 and ")" or "")
		end
		if multiplier > 1 then
			if multiplier%1 == 0 then
				tooltip = tooltip .. " x " .. multiplier
			else
				tooltip = tooltip .. string.format(" x %.1f", multiplier)
			end
		end
		tooltip = tooltip .. "\n" .. self.def.desc
		return tooltip
	end
	
	function self.Draw(x, y, scale, alpha)
		local colorDef = StampConst.colorMap[self.color]
		Resources.DrawImage(self.def.backImage or "stamp_back", x, y, false, alpha or false, scale, colorDef and colorDef[1])
		if self.def.image then
			Resources.DrawImage(self.def.image, x, y, false, alpha or false, scale, (not self.def.noForegroundColor) and colorDef and colorDef[2])
		end
		if self.def.DoPlaceAbility then
			Resources.DrawImage("border2", x, y, false, alpha or false, scale, StampConst.rarityColorMap[self.rarity] or false)
		else
			Resources.DrawImage("stamp", x, y, false, alpha or false, scale, StampConst.rarityColorMap[self.rarity] or false)
		end
		Resources.DrawImage("quality_" .. self.quality, x, y, false, alpha or false, scale)
		
		Font.SetSize(4)
		if self.color == 100 then
			love.graphics.setColor(1, 1, 1, alpha or 1)
		else
			love.graphics.setColor(0, 0.05, 0, alpha or 1)
		end
		local costString = self.def.GetSellValue(self) >= 4 and ("$" .. self.cost) or (self.cost .. "¢")
		if self.def.costDrawAppend then
			costString = self.def.costDrawAppend .. costString
		end
		love.graphics.printf(costString, x - Global.STAMP_WIDTH*scale*0.39, y - Global.STAMP_HEIGHT*scale*0.41, Global.STAMP_WIDTH*scale)
	end
	
	return self
end

return NewStamp
