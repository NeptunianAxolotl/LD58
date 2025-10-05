
local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs

local function NewBook(def)
	local self = {}
	local api = {}
	self.width = def.width
	self.height = def.height
	self.stamps = def.stamps
	self.score = BookHelper.CalculateBookScore(self)
	
	function api.GetSelfData()
		return self
	end
	
	function api.GetScore()
		return self.score
	end
	
	function api.GetWidth()
		return self.width
	end
	
	function api.GetHeight()
		return self.height
	end
	
	function api.GetStampAt(x, y)
		return self.stamps[x] and self.stamps[x][y]
	end
	
	function api.ReplaceStamp(x, y, replacement)
		replacement, self.stamps[x][y] = TableHandler.PlaceStampAndMaybeDoAbility(replacement, self.stamps[x][y], api, x, y)
		self.score = BookHelper.CalculateBookScore(self)
		return replacement
	end
	
	function api.Draw(x, y, scale, hoverType, index)
		local xScale = scale * Global.STAMP_WIDTH
		local yScale = scale * Global.STAMP_HEIGHT
		for i = 1, self.width do
			for j = 1, self.height do
				if not hoverType or not TableHandler.JustCheckUnderMouse(x + (i - 1)*xScale, y + (j - 1)*yScale, xScale, yScale) then
					love.graphics.setColor(0, 0, 0, 1)
					love.graphics.setLineWidth(2)
					love.graphics.rectangle("line", x + (i - 1)*xScale, y + (j - 1)*yScale, xScale, yScale)
				end
			end
		end
		for i = 1, self.width do
			for j = 1, self.height do
				local underMouse = hoverType and TableHandler.CheckAndSetUnderMouse(
					x + (i - 1)*xScale, y + (j - 1)*yScale, xScale, yScale,
					{type = hoverType, book = api, index = index, x = i, y = j}
				)
				if underMouse then
					love.graphics.setColor(0.2, 1, 0.2, 1)
					love.graphics.setLineWidth(3)
					love.graphics.rectangle("line", x + (i - 1)*xScale, y + (j - 1)*yScale, xScale, yScale)
				end
				if self.stamps[i][j] then
					self.stamps[i][j].Draw(x + (i - 0.5)*xScale, y + (j - 0.5)*yScale, scale)
				end
			end
		end
	end
	
	return api
end

return NewBook
