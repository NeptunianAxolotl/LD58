
StampConst = require("defs/stampDefs")
StampDefs = StampConst.defs

local BookDefData = require("defs/bookDefs")
local BookDefs = BookDefData.defs

local NewBook = require("objects/book")
local NewStamp = require("objects/stamp")

local api = {}
local world

local function FindSnake(self, other, sx, sy, ox, oy, bonusDisplayTable, killImage)
	if not other then
		return 0
	end
	if other.name == "snake_stamp" then
		if bonusDisplayTable then
			local key = "snakes_" .. math.min(sx, ox) .. "_" .. math.min(sy, oy) .. "_" .. math.max(sx, ox) .. "_" .. math.max(sy, oy)
			if not IterableMap.Get(bonusDisplayTable, key) then
				IterableMap.Add(bonusDisplayTable, key, {
					posList = {{sx, sy}, {ox, oy}},
					image = killImage,
					humanName = "Spooked by Snake",
					desc = "Snakes spook other animals, wasting their ♥.",
				})
			end
		end
		return 1
	end
	return 0
end

function api.IsNextToSnake(self, x, y, bonusDisplayTable, left, right, top, bottom, killImage)
	local score = 0
	score = score + FindSnake(self, left,    x, y, x - 1, y, bonusDisplayTable, killImage)
	score = score + FindSnake(self, right,   x, y, x + 1, y, bonusDisplayTable, killImage)
	score = score + FindSnake(self, top,     x, y, x, y - 1, bonusDisplayTable, killImage)
	score = score + FindSnake(self, bottom,  x, y, x, y + 1, bonusDisplayTable, killImage)
	if score > 0 then
		return true
	end
	return false
end

function api.GetColScoreMultiplier(self, colIndex)
	local multiplier = 1
	-- Get average quality
	local quality = 0
	for j = 1, self.height do
		if self.stamps[colIndex][j] and self.stamps[colIndex][j].quality then
			quality = quality + self.stamps[colIndex][j].quality
		end
	end
	quality = quality / self.height

	-- Is the column full?
	for j = 1, self.height do
		if not self.stamps[colIndex][j] then
			return 1
		end
	end
	
	-- EVALUATE FLUSHES
	-- How many wilds are there? And if they are not all wilds, what might be the flush colour?
	local nwilds = 0
	local candfound = false
	local candcolor = -100
	for j = 1, self.height do
		if self.stamps[colIndex][j].def.isWildColor then
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
	
	local quality = math.max(1.5, math.ceil(quality*2)/2)
	if nwilds >= self.height then
		-- full wilds
		multiplier = 3 * quality
	elseif nwilds > 1 then
		multiplier = 1
	else
		-- check for colours
		if candfound and candcolor >= 0 then
			multiplier = quality * self.rowColumnGlobalMult
		end
	end
	return multiplier
end

function api.GetRowScoreMultiplier(self, rowIndex)
	-- Is the row full?
	for i = 1, self.width do
		if not self.stamps[i][rowIndex] then
			return 1
		end
	end
	
	-- Do their costs form a sequence?
	local dir = 0
	local x = -100
	if self.stamps[1][rowIndex] and self.stamps[1][rowIndex].cost then
		x = self.stamps[1][rowIndex].cost
	end
	if x >= 0 and self.stamps[2][rowIndex] and self.stamps[2][rowIndex].cost then
		if x == self.stamps[2][rowIndex].cost then
			return 1
		end
		dir = self.stamps[2][rowIndex].cost - x
		x = x + dir
	end
	if self.width <= 2 and dir ~= -1 and dir ~= 1 then
		return 1 -- No arbitrary sequence bonus for pairs
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
		return math.max(1.5, math.ceil(quality*2)/2) * self.rowColumnGlobalMult
	end
	return 1
end

local function TrackMultiplier(self, mult, posList, humanName, desc, index, bonusDisplayTable, chosenImage)
	IterableMap.Add(bonusDisplayTable, humanName .. index .. "_mult", {
		posList = posList,
		image = chosenImage,
		humanName = humanName,
		desc = desc,
	})
end

function api.GetStampAdjacencyScore(self, i, j, bonusDisplayTable)
	return self.stamps[i][j].GetAdjacencyScore(
		i, j, bonusDisplayTable or false,
		self.stamps[i - 1] and self.stamps[i - 1][j],
		self.stamps[i + 1] and self.stamps[i + 1][j],
		self.stamps[i][j - 1],
		self.stamps[i][j + 1])
end

local function UpdateStampAdjacencyData(self, i, j, bonusDisplayTable)
	return self.stamps[i][j].def.UpdateAdjacencyData(
		self.stamps[i][j], i, j, self,
		bonusDisplayTable or false,
		self.stamps[i - 1] and self.stamps[i - 1][j],
		self.stamps[i + 1] and self.stamps[i + 1][j],
		self.stamps[i][j - 1],
		self.stamps[i][j + 1],
		self.stamps[i + 1] and self.stamps[i + 1][j - 1], -- NE
		self.stamps[i - 1] and self.stamps[i - 1][j - 1], -- NW
		self.stamps[i - 1] and self.stamps[i - 1][j + 1], -- SW
		self.stamps[i + 1] and self.stamps[i + 1][j + 1]  -- SE
	)
end

function api.CalculateBookScore(self, bonusDisplayTable)
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
	
	-- Reset score multipliers that depend on book layout
	self.rowColumnGlobalMult = 1
	
	-- Cache information that stamps need to figure out how their adjacency works (eg disabling if there are too many adjacent).
	for i = 1, self.width do
		for j = 1, self.height do
			if self.stamps[i][j] and self.stamps[i][j].def.UpdateAdjacencyData then
				UpdateStampAdjacencyData(self, i, j, bonusDisplayTable)
			end
		end
	end
	
	-- Evaluate each stamp's individual value.
	for i = 1, self.width do
		for j = 1, self.height do
			if self.stamps[i][j] then
				local scoreme = self.stamps[i][j].GetSoloScore() + api.GetStampAdjacencyScore(self, i, j, bonusDisplayTable)
				score = score + scoreme
				basic_scores = basic_scores + scoreme
				basic_scores_row[j] = basic_scores_row[j] + scoreme
				basic_scores_col[i] = basic_scores_col[i] + scoreme
			end
		end
	end
	
	-- Evaluate the score on each column.
	for i = 1, self.width do
		local mult = api.GetColScoreMultiplier(self, i)
		if mult > 1 and bonusDisplayTable then
			local posList = {}
			for j = 1, self.height do
				posList[#posList + 1] = {i, j}
			end
			TrackMultiplier(
				self, mult, posList, "Column ♥ x" .. mult,
				"Column multiplier for matching stamp colours, improves with better quality stamps.",
				i, bonusDisplayTable, "colcombo")
		end
		score = score + basic_scores_col[i] * (mult - 1)
	end
	
	-- Evaluate the score on each row.
	for j = 1, self.height do
		local mult = api.GetRowScoreMultiplier(self, j)
		if mult > 1 and bonusDisplayTable then
			local posList = {}
			for i = 1, self.width do
				posList[#posList + 1] = {i, j}
			end
			TrackMultiplier(
				self, mult, posList, "Row ♥ x" .. mult,
				"Row multiplier for sequential stamp prices, improves with better quality stamps.",
				j, bonusDisplayTable, "rowcombo")
		end
		--if bonusDisplayTable then
		--TrackMultiplier(
		--	self, 4, {{1, 1}}, math.random(),
		--	"Row multiplier for sequential stamp prices, improved with better quality stamps.",
		--	7, bonusDisplayTable)
		--TrackMultiplier(
		--	self, 4, {{1, 1}}, math.random(),
		--	"Row multiplier for sequential stamp prices, improved with better quality stamps.",
		--	7, bonusDisplayTable)
		--TrackMultiplier(
		--	self, 4, {{1, 1}}, math.random(),
		--	"Row multiplier for sequential stamp prices, improved with better quality stamps.",
		--	7, bonusDisplayTable)
		--end
		score = score + basic_scores_row[j] * (mult - 1)
	end
	
	return math.max(0, math.floor(score))
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
		local ex = bx + bw * (placePos.x - 0.5) / self.width
		EffectsHandler.SpawnEffect("popup", {ex, by}, {text = "x" .. colMult, velocity = {0, -5}})
		EffectsHandler.SpawnEffect("popup", {ex, by + bh}, {text = "x" .. colMult, velocity = {0, 5}})
	end
	if rowMult > 1 then
		local ey = by + bh * (placePos.y - 0.5) / self.height
		EffectsHandler.SpawnEffect("popup", {bx, ey}, {text = "x" .. rowMult, velocity = {-5, 0}})
		EffectsHandler.SpawnEffect("popup", {bx + bw, ey}, {text = "x" .. rowMult, velocity = {5, 0}})
	end
end

function api.SpawnAllMultiplierEffects(self, bx, by, bw, bh)
	for i = 1, self.width do
		local colMult = api.GetColScoreMultiplier(self, i)
		if colMult > 1 then
			local ex = bx + bw * (i - 0.5) / self.width
			EffectsHandler.SpawnEffect("popup", {ex, by}, {text = "x" .. colMult, velocity = {0, -5}})
			EffectsHandler.SpawnEffect("popup", {ex, by + bh}, {text = "x" .. colMult, velocity = {0, 5}})
		end
	end
	for j = 1, self.height do
		local rowMult = api.GetRowScoreMultiplier(self, j)
		if rowMult > 1 then
			local ey = by + bh * (j - 0.5) / self.height
			EffectsHandler.SpawnEffect("popup", {bx, ey}, {text = "x" .. rowMult, velocity = {-5, 0}})
			EffectsHandler.SpawnEffect("popup", {bx + bw, ey}, {text = "x" .. rowMult, velocity = {5, 0}})
		end
	end

end

local function ForceBasicFlush(self)
	i = 1 + math.floor(math.random() * self.width)
	c = 1 + math.floor(math.random() * 8)
	for j = 1, self.height do
		self.stamps[i][j] = NewStamp({
								name = "blank_stamp", 
								quality = self.minQuality + math.floor(math.random()*(self.maxQuality - self.minQuality + 1))
								})
		self.stamps[i][j].color = c
	end
end

local function ForceBasicSequence(self)
	j = 1 + math.floor(math.random()*self.height)
	flip = 1 + math.floor(math.random()*2)
	if flip == 1 then
		jumpsize = 4 - math.ceil(math.sqrt(math.random(9)))
		seqstart = 1 + math.floor(math.random()*(8-jumpsize*self.width))
	else
		jumpsize = -4 + math.ceil(math.sqrt(math.random(9)))
		seqstart = 9 - (1 + math.floor(math.random()*(8+jumpsize*self.width)))
	end
	
	for i = 1, self.width do
		self.stamps[i][j] = NewStamp({
								name = "blank_stamp", 
								quality = self.minQuality + math.floor(math.random()*(self.maxQuality - self.minQuality + 1))
								})
		self.stamps[i][j].cost = seqstart + jumpsize*(i-1)
	end
end

local function ForcePair(self,stamp1,stamp2)
	i = 1 + math.floor(math.random() * self.width)
	j = 1 + math.floor(math.random()*self.height)
	flip = 1 + math.floor(math.random()*2)
	if flip == 1 then
		i2 = i
		j2 = j + 2 * math.floor(math.random()*2) - 1
		if j2 == 0 then
			j2 = 2
		end
		if j2 > self.height then
			j2 = self.height - 1 
		end 
	else
		j2 = j
		i2 = i + 2 * math.floor(math.random()*2) - 1
		if i2 == 0 then
			i2 = 2
		end
		if i2 > self.width then
			i2 = self.width - 1 
		end
	end
	
	self.stamps[i][j] = NewStamp({
		name = stamp1, 
		quality = util.RandomIntegerInRange(self.minQuality, self.maxQuality)
	})
	self.stamps[i2][j2] = NewStamp({
		name = stamp2, 
		quality = util.RandomIntegerInRange(self.minQuality, self.maxQuality)
	})
end

local function permcompare(a,b)
	return a["value"] < b["value"]
end

local function ScrambleForTarget(self, target, attempts)
	
	if target > 1 then
		target = 1
	end
	if target < 0 then
		target = 0
	end
	
	local lstamps = {}
	
	local lsize = 0
	for i = 1, self.width do
		for j = 1, self.height do
			lsize = lsize + 1
			lstamps[lsize] = self.stamps[i][j]
		end
	end
	
	local perms = {}
	local values = {}
	perms[1] = {}
	perms[1]["perm"] = {}
	perms[1]["value"] = -1
	for k = 1, lsize do
		perms[1]["perm"][k] = k
	end
	perms[1]["value"] = api.CalculateBookScore(self)
	
	for a = 2, attempts do
		perms[a] = {}
		perms[a]["perm"] = util.GetRandomPermutation(lsize)
		perms[a]["value"] = -1
		
		for i = 1, self.width do
			for j = 1, self.height do
				nextstamp = perms[a]["perm"][(i-1)*self.height + j]
				self.stamps[i][j] = lstamps[nextstamp]
			end
		end
		
		perms[a]["value"] = api.CalculateBookScore(self)
	end
	
	table.sort(perms, permcompare)
	
	if target < 1e-3 then
		chosen = 1
	elseif target > 1 - 1e-3 then
		chosen = attempts
	else
		chosen = math.ceil(target * attempts)
	end
	
	cperm = perms[chosen]["perm"]
	for i = 1, self.width do
		for j = 1, self.height do
			nextstamp = perms[chosen]["perm"][(i-1)*self.height + j]
			self.stamps[i][j] = lstamps[nextstamp]
		end
	end
	
end

local function SelectRandomStamp(self, stampTypeCounts)
	local name, def
	local tries = 20
	while (not def) or (def.shopLimitCategory and (stampTypeCounts[def.shopLimitCategory] or 0) > def.shopLimit and tries > 0) do
		name = util.SampleListWeighted(self.stampDist).stamp
		def = StampDefs[name]
		tries = tries - 1
	end
	if def.shopLimitCategory then
		stampTypeCounts[def.shopLimitCategory] = (stampTypeCounts[def.shopLimitCategory] or 0) + 1
	end
	return name
end

local function RegenerateStamps(self)
	local stampTypeCounts = {}
	for i = 1, self.width do
		self.stamps[i] = {}
		for j = 1, self.height do
			local name = SelectRandomStamp(self, stampTypeCounts)
			self.stamps[i][j] = NewStamp({
				name = name,
				quality = util.RandomIntegerInRange(self.minQuality, self.maxQuality),
			})
		end
	end
	if self.earlyForceDist then
		forcing = util.SampleListWeighted(self.earlyForceDist).forcing
		if forcing == "force_none" then
			-- do nothing
		elseif forcing == "force_sequence" then
			ForceBasicSequence(self)
		elseif forcing == "force_flush" then
			ForceBasicFlush(self)
		elseif forcing == "force_rocket" then
			ForcePair(self,"rocket_stamp","planet_stamp")
		elseif forcing == "force_pair" then
			ForcePair(self,"pair_stamp","pair_stamp")
		elseif forcing == "force_roo" then
			ForcePair(self,"kangaroo_stamp","kangaroo_stamp")
		else
			error("Error in book generation")
		end
	end
	if self.scramble then
		scramset = util.SampleListWeighted(self.scramble)
		if scramset.attempts > 0 then
			target = scramset.target -- 0 to 1, what fraction of the other attempts is the selected permutation better than. NOT a book score target.
			attempts = scramset.attempts
			ScrambleForTarget(self, target, attempts)
		end
	end
	
	self.score = api.CalculateBookScore(self)
end

local function FillStamps(self, stampsToUse)
	local index = 1
	for i = 1, self.width do
		self.stamps[i] = {}
		for j = 1, self.height do
			if stampsToUse[index] then
				self.stamps[i][j] = NewStamp(stampsToUse[index])
			end
			index = index + 1
		end
	end
	self.score = api.CalculateBookScore(self)
end

function api.GetBook(defName)
	local self = util.CopyTable(BookDefs[defName])
	self.stamps = {}
	if self.predeterminedStamps then
		FillStamps(self, self.predeterminedStamps)
	else
		RegenerateStamps(self)
	end
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
