
StampConst = require("defs/stampDefs")
StampDefs = StampConst.defs

local BookDefData = require("defs/bookDefs")
local BookDefs = BookDefData.defs

local NewBook = require("objects/book")
local NewStamp = require("objects/stamp")

local api = {}
local world

function api.BaseStampScore(self)
	return math.floor(3 * (self.quality + 1) / 2)
end

function api.WantColorBlindSymbol()
	return world.GetCosmos().IsColorblindMode()
end

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

local function TrackMultiplier(self, mult, posList, humanName, desc, index, bonusDisplayTable, chosenImage)
	IterableMap.Add(bonusDisplayTable, humanName .. index .. chosenImage .. "_mult", {
		posList = posList,
		image = chosenImage,
		humanName = humanName,
		desc = desc,
	})
end

local function ColorsMatch(currentCol, stamp)
	if stamp.def.noColor then
		return false
	end
	if stamp.def.isWildColor then
		return currentCol
	end
	if currentCol == true then
		return stamp.color
	end
	return (stamp.color == currentCol) and stamp.color
end

function api.GetColScoreMultiplier(self, colIndex, bonusDisplayTable)
	-- Is the column full?
	for j = 1, self.height do
		if not self.stamps[colIndex][j] then
			return 1
		end
	end
	
	-- Do their costs form a sequence?
	local sequenceBonus = true
	local colorBonus = true
	local dir = 0
	local x = self.stamps[colIndex][1].cost
	local colorBonus = ColorsMatch(colorBonus, self.stamps[colIndex][1])
	if self.stamps[colIndex][2] and self.stamps[colIndex][2].cost then
		dir = self.stamps[colIndex][2].cost - x
		x = x + dir
		colorBonus = ColorsMatch(colorBonus, self.stamps[colIndex][2])
	end
	if self.height <= 2 then
		sequenceBonus = false
	end
	for j = 3, self.height do
		if self.stamps[colIndex][j] and self.stamps[colIndex][j].cost and x+dir == self.stamps[colIndex][j].cost then
			x = x + dir
		else
			sequenceBonus = false
		end
		colorBonus = ColorsMatch(colorBonus, self.stamps[colIndex][j])
	end
	
	if not (colorBonus or sequenceBonus) then
		return 1
	end
	
	-- Get average quality
	local quality = 0
	for j = 1, self.height do
		if self.stamps[colIndex][j] and self.stamps[colIndex][j].quality  then
			quality = quality + self.stamps[colIndex][j].quality
		end
	end
	quality = quality / self.height
	local mult = 1 + math.max(1, math.floor(quality*2)/2)*self.rowColumnGlobalMult
	
	if bonusDisplayTable then
		local posList = {}
		for j = 1, self.height do
			posList[#posList + 1] = {colIndex, j}
		end
		if sequenceBonus then
			TrackMultiplier(
				self, mult, posList, "Column ♥ + " .. (mult - 1)*100 .. "%",
				"Column multiplier for sequential stamp prices, improves with better quality stamps. Requires a sequence of at least three.",
				colIndex, bonusDisplayTable, "colnumber")
		end
		if colorBonus then
			TrackMultiplier(
				self, mult, posList, "Column ♥ + " .. (mult - 1)*100 .. "%",
				"Column multiplier for matching stamp colours, improves with better quality stamps.",
				colIndex, bonusDisplayTable, "colcombo")
		end
	end
	
	if colorBonus and sequenceBonus then
		mult = mult*2 - 1
	end
	return mult
end

function api.GetRowScoreMultiplier(self, rowIndex, bonusDisplayTable)
	-- Is the row full?
	for i = 1, self.width do
		if not self.stamps[i][rowIndex] then
			return 1
		end
	end
	
	-- Do their costs form a sequence?
	local sequenceBonus = true
	local colorBonus = true
	local dir = 0
	local x = self.stamps[1][rowIndex].cost
	local colorBonus = ColorsMatch(colorBonus, self.stamps[1][rowIndex])
	if self.stamps[2][rowIndex] and self.stamps[2][rowIndex].cost then
		dir = self.stamps[2][rowIndex].cost - x
		x = x + dir
		colorBonus = ColorsMatch(colorBonus, self.stamps[2][rowIndex])
	end
	if self.width <= 2 then
		sequenceBonus = false
	end
	for i = 3, self.width do
		if self.stamps[i][rowIndex] and self.stamps[i][rowIndex].cost and x+dir == self.stamps[i][rowIndex].cost then
			x = x + dir
		else
			sequenceBonus = false
		end
		colorBonus = ColorsMatch(colorBonus, self.stamps[i][rowIndex])
	end
	
	if not (colorBonus or sequenceBonus) then
		return 1
	end
	
	-- Get average quality
	local quality = 0
	for i = 1, self.width do
		if self.stamps[i][rowIndex] and self.stamps[i][rowIndex].quality  then
			quality = quality + self.stamps[i][rowIndex].quality
		end
	end
	quality = quality / self.width
	local mult = 1 + math.max(1, math.floor(quality*2)/2)*self.rowColumnGlobalMult
	
	if bonusDisplayTable then
		local posList = {}
		for i = 1, self.width do
			posList[#posList + 1] = {i, rowIndex}
		end
		if sequenceBonus then
			TrackMultiplier(
				self, mult, posList, "Row ♥ + " .. (mult - 1)*100 .. "%",
				"Row multiplier for sequential stamp prices, improves with better quality stamps. Requires a sequence of at least three.",
				rowIndex, bonusDisplayTable, "rowcombo")
		end
		if colorBonus then
			TrackMultiplier(
				self, mult, posList, "Row ♥ + " .. (mult - 1)*100 .. "%",
				"Row multiplier for matching stamp colours, improves with better quality stamps.",
				rowIndex, bonusDisplayTable, "rowcolor")
		end
	end
	
	if colorBonus and sequenceBonus then
		mult = mult*2 - 1
	end
	return mult
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
		local mult = api.GetColScoreMultiplier(self, i, bonusDisplayTable)
		score = score + basic_scores_col[i] * (mult - 1)
	end
	
	-- Evaluate the score on each row.
	for j = 1, self.height do
		local mult = api.GetRowScoreMultiplier(self, j, bonusDisplayTable)
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
		EffectsHandler.SpawnEffect("popup", {ex, by}, {text = "+" .. ((colMult - 1)*100) .. "%", velocity = {0, -5}})
		EffectsHandler.SpawnEffect("popup", {ex, by + bh}, {text = "+" .. ((colMult - 1)*100) .. "%", velocity = {0, 5}})
	end
	if rowMult > 1 then
		local ey = by + bh * (placePos.y - 0.5) / self.height
		EffectsHandler.SpawnEffect("popup", {bx, ey}, {text = "+" .. ((rowMult - 1)*100) .. "%", velocity = {-5, 0}})
		EffectsHandler.SpawnEffect("popup", {bx + bw, ey}, {text = "+" .. ((rowMult - 1)*100) .. "%", velocity = {5, 0}})
	end
end

function api.SpawnAllMultiplierEffects(self, bx, by, bw, bh)
	for i = 1, self.width do
		local colMult = api.GetColScoreMultiplier(self, i)
		if colMult > 1 then
			local ex = bx + bw * (i - 0.5) / self.width
			EffectsHandler.SpawnEffect("popup", {ex, by}, {text = "+" .. ((colMult - 1)*100) .. "%", velocity = {0, -5}})
			EffectsHandler.SpawnEffect("popup", {ex, by + bh}, {text = "+" .. ((colMult - 1)*100) .. "%", velocity = {0, 5}})
		end
	end
	for j = 1, self.height do
		local rowMult = api.GetRowScoreMultiplier(self, j)
		if rowMult > 1 then
			local ey = by + bh * (j - 0.5) / self.height
			EffectsHandler.SpawnEffect("popup", {bx, ey}, {text = "+" .. ((rowMult - 1)*100) .. "%", velocity = {-5, 0}})
			EffectsHandler.SpawnEffect("popup", {bx + bw, ey}, {text = "+" .. ((rowMult - 1)*100) .. "%", velocity = {5, 0}})
		end
	end
end

local function SelectRandomStamp(self, stampTypeCounts)
	local name, def
	local tries = 20
	while (not def) or (def.shopLimitCategory and (stampTypeCounts[def.shopLimitCategory] or 0) >= def.shopLimit and tries > 0) do
		name = util.SampleListWeighted(self.stampDist).stamp
		def = StampDefs[name]
		tries = tries - 1
	end
	if def.shopLimitCategory then
		stampTypeCounts[def.shopLimitCategory] = (stampTypeCounts[def.shopLimitCategory] or 0) + 1
	end
	return name
end

local function ForceBasicFlush(self, stampTypeCounts)
	i = 1 + math.floor(math.random() * self.width)
	c = 1 + math.floor(math.random() * 8)
	for j = 1, self.height do
		self.stamps[i][j] = NewStamp({
			name = SelectRandomStamp(self, stampTypeCounts),
			quality = util.SampleListWeighted(self.qualityDist).qual,
		})
		if not (self.stamps[i][j].def.noColor or self.stamps[i][j].def.isWildColor) then
			self.stamps[i][j].color = c
		end
	end
end

local function ForceBasicSequence(self, stampTypeCounts)
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
			name = SelectRandomStamp(self, stampTypeCounts),
			quality = util.SampleListWeighted(self.qualityDist).qual,
		})
		if not self.stamps[i][j].def.fixedCost and self.stamps[i][j].cost >= 1 and self.stamps[i][j].cost <= StampConst.COST_RANGE then
			self.stamps[i][j].cost = seqstart + jumpsize*(i-1)
		end
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
		quality = util.SampleListWeighted(self.qualityDist).qual,
	})
	self.stamps[i2][j2] = NewStamp({
		name = stamp2,
		quality = util.SampleListWeighted(self.qualityDist).qual,
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

local function RegenerateStamps(self)
	local stampTypeCounts = {}
	for i = 1, self.width do
		self.stamps[i] = {}
		for j = 1, self.height do
			local name = SelectRandomStamp(self, stampTypeCounts)
			self.stamps[i][j] = NewStamp({
				name = name,
				quality = util.SampleListWeighted(self.qualityDist).qual,
			})
		end
	end
	if self.earlyForceDist then
		forcing = util.SampleListWeighted(self.earlyForceDist).forcing
		if forcing == "force_none" then
			-- do nothing
		elseif forcing == "force_sequence" then
			ForceBasicSequence(self, stampTypeCounts)
		elseif forcing == "force_flush" then
			ForceBasicFlush(self, stampTypeCounts)
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

function api.GetBook(defName, qualityDist)
	local self = util.CopyTable(BookDefs[defName])
	self.qualityDist = qualityDist or {
		{probability = 1, qual = 1},
		{probability = 0, qual = 2},
		{probability = 0, qual = 3},
	}
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
