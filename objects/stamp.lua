

local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs

local function NewStamp(def)
	local self = {}
	self.typeDef = StampDefs[def.name]
	self.cost = def.cost
	
	function self.Draw(x, y, scale)
		Resources.DrawImage(self.typeDef.image, x, y, false, false, scale)
		Font.SetSize(3)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf(self.cost, x, y, scale)
	end
	
	return self
end

return NewStamp
