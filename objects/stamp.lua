

local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs

local function NewStamp(def)
	local self = {}
	self.def = StampDefs[def.name]
	self.name = def.name
	self.cost = def.cost
	self.color = def.color
	self.quality = def.quality
	
	function self.GetAdjacencyScore(left, right, top, bottom)
		return self.def.GetAdjacencyScore(self, left, right, top, bottom)
	end
	
	function self.GetSoloScore()
		return self.def.GetSoloScore(self)
	end
	
	function self.GetSellValue()
		return self.def.GetSellValue(self)
	end
	
	function self.Draw(x, y, scale)
		Resources.DrawImage(self.def.image, x, y, false, false, scale, StampDefData.colorMap[self.color])
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf(self.cost, x - scale*0.3, y - scale*0.3, scale)
		Resources.DrawImage("quality_" .. self.quality, x, y, false, false, scale)
	end
	
	return self
end

return NewStamp
