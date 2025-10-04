
local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs
local NewStamp = require("objects/stamp")

local function NewBook(def)
	local self = {}
	self.width = def.width or 3
	self.height = def.height or 3
	self.stamps = {}
	for i = 1, self.width do
		self.stamps[i] = {}
		for j = 1, self.height do
			self.stamps[i][j] = NewStamp({name = "basic_stamp", cost = 1 + math.floor(math.random()*10)})
		end
	end
	
	
	function self.Draw(pos, scale)
		for i = 1, self.width do
			for j = 1, self.height do
				love.graphics.setColor(0, 0, 0, 1)
				love.graphics.rectangle("line", pos[1] + (i - 1)*scale, pos[2] + (j - 1)*scale, scale, scale)
				self.stamps[i][j].Draw(pos[1] + (i - 0.5)*scale, pos[2] + (j - 0.5)*scale, scale)
			end
		end
	end
	
	return self
end

return NewBook
