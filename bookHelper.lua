
local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs

local BookDefData = require("defs/bookDefs")
local BookDefs = BookDefData.defs

local NewBook = require("objects/book")
local NewStamp = require("objects/stamp")

local api = {}
local world

function api.GetColScoreMultiplier(self, colIndex)

	local multiplier = 1
	
	-- Get average quality
	local quality = 0
	for j = 1, self.height do
		if self.stamps[colIndex][j] and self.stamps[colIndex][j].quality then
			quality = quality + self.stamps[colIndex][j].quality
		end
	end
	quality = quality / self.width

	-- Is the column full?
	local isfull = true
	for j = 1, self.height do
		if not self.stamps[colIndex][j] then
			isfull = false
			break
		end
	end
	if isfull then
		-- EVALUATE FLUSHES
		-- How many wilds are there? And if they are not all wilds, what might be the flush colour?
		local nwilds = 0
		local candfound = false
		local candcolor = -100
		for j = 1, self.height do
			if self.stamps[colIndex][j].custom and self.stamps[colIndex][j].custom["wild_color"] then
				nwilds = nwilds + 1
			else
				if candfound then
					if candcolor ~= self.stamps[colIndex][j].color then
						candcolor = -200
					end
				else
					candfound = true
					candcolor = self.stamps[colIndex][j].color
				end
			end
		end
		
		if nwilds >= self.height then
			-- full wilds
			multiplier = multiplier + 3 * math.ceil(quality)
		elseif nwilds > 1 then
			-- does not score
		else
			-- check for colours
			if candfound and candcolor >= 0 then
				multiplier = multiplier + 1 * math.ceil(quality)
			end
		end
	end

	return multiplier

end

function api.GetRowScoreMultiplier(self, rowIndex)
	-- Do their costs form a sequence?
	local dir = 0
	local x = -100
	if self.stamps[1][rowIndex] and self.stamps[1][rowIndex].cost then
		x = self.stamps[1][rowIndex].cost
	end
	if x >= 0 and self.stamps[2][rowIndex] and self.stamps[2][rowIndex].cost then
		if x+1 == self.stamps[2][rowIndex].cost then
			dir = 1
			x = x + dir
		elseif x-1 == self.stamps[2][rowIndex].cost then
			dir = -1
			x = x + dir
		else
			return 1
		end
	end
	for i = 3, self.width do
		if self.stamps[i][rowIndex] and self.stamps[i][rowIndex].cost and x+dir == self.stamps[i][rowIndex].cost then
			x = x + dir
		else
			return 1
		end
	end
	-- Get average quality
	local quality = 0
	for i = 1, self.width do
		if self.stamps[i][rowIndex] and self.stamps[i][rowIndex].quality  then
			quality = quality + self.stamps[i][rowIndex].quality
		end
	end
	quality = quality / self.width
	if x >= 0 then
		return math.max(1.5, math.ceil(quality*2)/2)
	end
	return 1
end

function api.CalculateBookScore(self)
	local score = 0
	
	local basic_scores = 0
	local basic_scores_row = {}
	local basic_scores_col = {}
	for i = 1, self.width do
		basic_scores_col[i] = 0
	end
	for j = 1, self.height do
		basic_scores_row[j] = 0
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
		score = score + math.ceil(basic_scores_col[i] * (api.GetColScoreMultiplier(self, i) - 1))
	end
	
	-- Evaluate the score on each row.
	for j = 1, self.height do
		score = score + math.ceil(basic_scores_row[j] * (api.GetRowScoreMultiplier(self, j) - 1))
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

function api.SpawnStampPlaceEffect(self, placePos, bx, by, bw, bh)
	local colMult = api.GetColScoreMultiplier(self, placePos.x)
	local rowMult = api.GetRowScoreMultiplier(self, placePos.y)
	if colMult == 1 and rowMult == 1 then
		return
	end
	local mousePos = world.GetMousePositionInterface()
	local xFrac = math.max(0, math.min(1, (mousePos[1] - bx) / bw))
	local yFrac = math.max(0, math.min(1, (mousePos[2] - by) / bh))
	
	if colMult > 1 then
		EffectsHandler.SpawnEffect("popup", {bx + bw * (placePos.x - 0.5) / self.width, by}, {text = "x" .. colMult, velocity = {0, -5}})
	end
	if rowMult > 1 then
		local ey = by + bh * (placePos.y - 0.5) / self.height
		if xFrac < 0.5 then
			EffectsHandler.SpawnEffect("popup", {bx, ey}, {text = "x" .. rowMult, velocity = {-5, 0}})
		else
			EffectsHandler.SpawnEffect("popup", {bx + bw, ey}, {text = "x" .. rowMult, velocity = {5, 0}})
		end
	end
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

function api.Initialize(parentWorld)
	world = parentWorld
end

return api
