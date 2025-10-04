

local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs

local function NewStamp(def)
	local self = {}
	self.typeDef = StampDefs[def.name]
	self.name = def.name
	self.cost = def.cost
	self.color = {math.random()*0.8 + 0.2, math.random()*0.8 + 0.2, math.random()*0.8 + 0.2}
	
	function self.Draw(x, y, scale)
		Resources.DrawImage(self.typeDef.image, x, y, false, false, scale, self.color)
		Font.SetSize(2)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf(self.cost, x - scale*0.3, y - scale*0.3, scale)
	end
	
	return self
end

return NewStamp
