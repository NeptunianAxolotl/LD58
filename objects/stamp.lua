

local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs

local function NewStamp(def)
	local self = {}
	self.def = StampDefs[def.name]
	self.name = def.name
	self.quality = def.quality
	self.def.InitRandomStamp(self, def)
	
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
		tooltip = tooltip .. "\nQuality: " .. StampDefData.qualityMap[self.quality]
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
		local colorDef = StampDefData.colorMap[self.color]
		Resources.DrawImage("stamp_back", x, y, false, alpha or false, scale, colorDef and colorDef[1])
		Resources.DrawImage(self.def.image, x, y, false, alpha or false, scale, colorDef and colorDef[2])
		Resources.DrawImage("stamp", x, y, false, alpha or false, scale, StampDefData.rarityColorMap[self.rarity] or false)
		Resources.DrawImage("quality_" .. self.quality, x, y, false, alpha or false, scale)
		
		Font.SetSize(4)
		love.graphics.setColor(0, 0.05, 0, alpha or 1)
		local costString = self.def.GetSellValue(self) > 1 and ("$" .. self.cost) or (self.cost .. "¢")
		love.graphics.printf(costString, x - Global.STAMP_WIDTH*scale*0.39, y - Global.STAMP_HEIGHT*scale*0.41, Global.STAMP_WIDTH*scale)
	end
	
	return self
end

return NewStamp
