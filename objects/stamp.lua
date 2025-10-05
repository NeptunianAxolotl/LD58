

local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs

local function NewStamp(def)
	local self = {}
	self.def = StampDefs[def.name]
	self.name = def.name
	self.quality = def.quality
	self.def.InitRandomStamp(self)
	
	function self.GetAdjacencyScore(left, right, top, bottom)
		return self.def.GetAdjacencyScore(self, left, right, top, bottom)
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
		tooltip = tooltip .. "\nValue: " .. self.GetSoloScore()
		local multiplier = self.GetStampMultiplier(book, x, y)
		if multiplier%1 == 0 then
			tooltip = tooltip .. " x " .. multiplier
		else
			tooltip = tooltip .. string.format(" x %.1f", multiplier)
		end
		tooltip = tooltip .. "\n" .. self.def.desc
		return tooltip
	end
	
	function self.Draw(x, y, scale, alpha)
		Resources.DrawImage(self.def.image, x, y, false, alpha or false, scale, StampDefData.colorMap[self.color] or false)
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, alpha or 1)
		love.graphics.printf(self.cost, x - Global.STAMP_WIDTH*scale*0.3, y - Global.STAMP_HEIGHT*scale*0.3, Global.STAMP_WIDTH*scale)
		Resources.DrawImage("quality_" .. self.quality, x, y, false, alpha or false, scale)
	end
	
	return self
end

return NewStamp
