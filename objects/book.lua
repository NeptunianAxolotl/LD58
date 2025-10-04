
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
	
	function self.ReplaceStamp(x, y, replacement)
		local old = self.stamps[x][y] or false
		self.stamps[x][y] = replacement
		return old
	end
	
	function self.Draw(x, y, scale)
		for i = 1, self.width do
			for j = 1, self.height do
				if not TableHandler.JustCheckUnderMouse(x + (i - 1)*scale, y + (j - 1)*scale, scale, scale) then
					love.graphics.setColor(0, 0, 0, 1)
					love.graphics.setLineWidth(2)
					love.graphics.rectangle("line", x + (i - 1)*scale, y + (j - 1)*scale, scale, scale)
				end
			end
		end
		for i = 1, self.width do
			for j = 1, self.height do
				local underMouse = TableHandler.CheckAndSetUnderMouse(x + (i - 1)*scale, y + (j - 1)*scale, scale, scale, {type = "book", book = self, x = i, y = j})
				if underMouse then
					love.graphics.setColor(0.2, 1, 0.2, 1)
					love.graphics.setLineWidth(3)
					love.graphics.rectangle("line", x + (i - 1)*scale, y + (j - 1)*scale, scale, scale)
				end
				if self.stamps[i][j] then
					self.stamps[i][j].Draw(x + (i - 0.5)*scale, y + (j - 0.5)*scale, scale)
				end
			end
		end
	end
	
	return self
end

return NewBook
