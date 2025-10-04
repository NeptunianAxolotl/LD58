
local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs
local NewStamp = require("objects/stamp")

local function CalculateBookScore(self)
	local score = 0
	for i = 1, self.width do
		for j = 1, self.height do
			if self.stamps[i][j] then
				score = score + self.stamps[i][j].GetScore(
					self.stamps[i][j + 1],
					self.stamps[i][j + 1],
					self.stamps[i - 1] and self.stamps[i - 1][j],
					self.stamps[i + 1] and self.stamps[i + 1][j])
			end
		end
	end
	return score
end

local function RegenerateStamps(self)
	for i = 1, self.width do
		self.stamps[i] = {}
		for j = 1, self.height do
			self.stamps[i][j] = NewStamp({name = "basic_stamp", cost = 1 + math.floor(math.random()*10), color = 1 + math.floor(math.random()*8)})
		end
	end
	self.score = CalculateBookScore(self)
end

local function NewBook(def)
	local self = {}
	local api = {}
	self.width = def.width or 3
	self.height = def.height or 3
	self.stamps = {}
	RegenerateStamps(self)
	if def.scoreRange then
		local tries = 100
		while (self.score < def.scoreRange[1] or self.score > def.scoreRange[2]) and tries > 0 do
			RegenerateStamps(self)
			tries = tries - 1
		end
	end
	
	function api.GetScore()
		return self.score
	end
	
	function api.ReplaceStamp(x, y, replacement)
		local old = self.stamps[x][y] or false
		self.stamps[x][y] = replacement
		self.score = CalculateBookScore(self)
		return old
	end
	
	function api.Draw(x, y, scale, checkHover)
		for i = 1, self.width do
			for j = 1, self.height do
				if not checkHover or not TableHandler.JustCheckUnderMouse(x + (i - 1)*scale, y + (j - 1)*scale, scale, scale) then
					love.graphics.setColor(0, 0, 0, 1)
					love.graphics.setLineWidth(2)
					love.graphics.rectangle("line", x + (i - 1)*scale, y + (j - 1)*scale, scale, scale)
				end
			end
		end
		for i = 1, self.width do
			for j = 1, self.height do
				local underMouse = checkHover and TableHandler.CheckAndSetUnderMouse(x + (i - 1)*scale, y + (j - 1)*scale, scale, scale, {type = "book", book = api, x = i, y = j})
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
	
	return api
end

return NewBook
