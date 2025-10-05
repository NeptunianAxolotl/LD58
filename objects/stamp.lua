

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
	
	function self.GetTooltip(book, x, y)
		local tooltip = self.def.humanName
		tooltip = tooltip .. "\nQuality: " .. StampDefData.qualityMap[self.quality]
		tooltip = tooltip .. "\nValue: " .. self.GetSoloScore()
		if book then
			local multiplier = (BookHelper.GetColScoreMultiplier(book.GetSelfData(), x) - 1) + (BookHelper.GetRowScoreMultiplier(book.GetSelfData(), y) - 1)
			if multiplier > 0 then
				if multiplier%1 == 0 then
					tooltip = tooltip .. " x " .. (multiplier + 1)
				else
					tooltip = tooltip .. string.format(" x %.1f", multiplier + 1)
				end
			end
		end
		tooltip = tooltip .. "\n" .. self.def.desc
		return tooltip
	end
	
	function self.Draw(x, y, scale)
		Resources.DrawImage(self.def.image, x, y, false, false, scale, StampDefData.colorMap[self.color] or false)
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf(self.cost, x - scale*0.3, y - scale*0.3, scale)
		Resources.DrawImage("quality_" .. self.quality, x, y, false, false, scale)
	end
	
	return self
end

return NewStamp
