
local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs
local NewStamp = require("objects/stamp")

local function CalculateBookScore(self)
	local score = 0
	
	local basic_scores = 0
	local basic_scores_row = {}
	local basic_scores_col = {}
	local quality_row = {}
	local quality_col = {}
	for i = 1, self.width do
		basic_scores_col[i] = 0
		quality_col[i] = false
	end
	for j = 1, self.height do
		basic_scores_row[j] = 0
		quality_row[j] = false
	end
	
	-- Evaluate each stamp's individual value.
	for i = 1, self.width do
		for j = 1, self.height do
			if self.stamps[i][j] then
				local scoreme = self.stamps[i][j].GetSoloScore()
				score = score + scoreme
				basic_scores = basic_scores + scoreme
				basic_scores_row[j] = basic_scores_row[j] + scoreme
				basic_scores_col[i] = basic_scores_col[i] + scoreme
			end
		end
	end
	
	-- Evaluate the score on each column.
	for i = 1, self.width do
		-- Get minimum quality
		for j = 1, self.height do
			if self.stamps[i][j] and self.stamps[i][j].quality and ((not quality_col[i]) or self.stamps[i][j].quality < quality_col[i]) then
				quality_col[i] = self.stamps[i][j].quality
			end
		end
		-- Are they all the same colour?
		local x = -100
		if self.stamps[i][1] and self.stamps[i][1].color then
			x = self.stamps[i][1].color
		end
		for j = 2, self.height do
			if self.stamps[i][j] and self.stamps[i][j].color and x == self.stamps[i][j].color then
				-- do nothing
			else
				x = -100
				break
			end
		end
		if x >= 0 then
			score = score + basic_scores_col[i] --* (quality_col[i] - 1)
		end
	end
	
	-- Evaluate the score on each row.
	for j = 1, self.height do
		-- Get minimum quality
		for i = 1, self.width do
			if self.stamps[i][j] and self.stamps[i][j].quality and ((not quality_row[j]) or self.stamps[i][j].quality < quality_row[j]) then
				quality_row[j] = self.stamps[i][j].quality
			end
		end
		-- Do their costs form a sequence?
		local x = -100
		if self.stamps[1][j] and self.stamps[1][j].cost then
			 x = self.stamps[1][j].cost
		end
		for i = 2, self.width do
			if self.stamps[i][j] and self.stamps[i][j].cost and x+1 == self.stamps[i][j].cost then
				x = x + 1
			else
				x = -100
				break
			end
		end
		if x >= 0 then
			score = score + basic_scores_row[j] --* (quality_row[i] - 1)
		end
	end
	
	-- Evaluate any other weird scoring stuff.
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
			self.stamps[i][j] = NewStamp({
				name = "basic_stamp",
				cost = 1 + math.floor(math.random()*10),
				color = 1 + math.floor(math.random()*8),
				quality = 1 + math.floor(math.random()*4),
			})
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
