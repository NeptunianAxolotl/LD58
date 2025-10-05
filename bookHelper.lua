
local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs

local BookDefData = require("defs/bookDefs")
local BookDefs = BookDefData.defs

local NewBook = require("objects/book")
local NewStamp = require("objects/stamp")

local api = {}

function api.CalculateBookScore(self)
	local score = 0
	
	local basic_scores = 0
	local basic_scores_row = {}
	local basic_scores_col = {}
	local quality_row = {}
	local quality_col = {}
	for i = 1, self.width do
		basic_scores_col[i] = 0
		quality_col[i] = 0
	end
	for j = 1, self.height do
		basic_scores_row[j] = 0
		quality_row[j] = 0
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
		-- Get average quality
		for j = 1, self.height do
			if self.stamps[i][j] and self.stamps[i][j].quality then
				quality_col[i] = quality_col[i] + self.stamps[i][j].quality
			end
		end
		quality_col[i] = quality_col[i] / self.height
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
			score = score + basic_scores_col[i] * math.ceil(quality_col[i] - 1)
		end
	end
	
	-- Evaluate the score on each row.
	for j = 1, self.height do
		-- Get average quality
		for i = 1, self.width do
			if self.stamps[i][j] and self.stamps[i][j].quality  then
				quality_row[j] = quality_row[j] + self.stamps[i][j].quality
			end
		end
		quality_row[j] = quality_row[j] / self.width
		-- Do their costs form a sequence?
		local dir = 0
		local x = -100
		if self.stamps[1][j] and self.stamps[1][j].cost then
			x = self.stamps[1][j].cost
		end
		if x >= 0 and self.stamps[2][j] and self.stamps[2][j].cost then
			if x+1 == self.stamps[2][j].cost then
				dir = 1
				x = x + dir
			elseif x-1 == self.stamps[2][j].cost then
				dir = -1
				x = x + dir
			else
				x = -100
				break
			end
		end
		for i = 3, self.width do
			if self.stamps[i][j] and self.stamps[i][j].cost and x+dir == self.stamps[i][j].cost then
				x = x + dir
			else
				x = -100
				break
			end
		end
		if x >= 0 then
			score = score + basic_scores_row[j] * math.ceil(quality_row[j] - 1)
		end
	end
	
	-- Evaluate any other weird scoring stuff.
	for i = 1, self.width do
		for j = 1, self.height do
			if self.stamps[i][j] then
				score = score + self.stamps[i][j].GetAdjacencyScore(
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
				name = util.SampleListWeighted(self.stampDist).stamp,
				quality = self.minQuality + math.floor(math.random()*(self.maxQuality - self.minQuality + 1)),
			})
		end
	end
	self.score = api.CalculateBookScore(self)
end

function api.GetBook(defName)
	local self = util.CopyTable(BookDefs[defName])
	self.stamps = {}
	RegenerateStamps(self)
	if self.scoreRange then
		local tries = 100
		while (self.score < self.scoreRange[1] or self.score > self.scoreRange[2]) and tries > 0 do
			RegenerateStamps(self)
			tries = tries - 1
		end
	end
	return NewBook(self)
end

return api
