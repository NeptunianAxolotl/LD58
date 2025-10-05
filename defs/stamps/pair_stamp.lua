

local function ScorePair(self, other, sx, sy, ox, oy, bonusDisplayTable)
	if not other then
		return 0
	end
	if other.name == "pair_stamp" then
		local bonus = 2 * (self.quality + 3)
		local otherBonus = 2 * (other.quality + 3)
		if bonusDisplayTable then
			local key = "pair_" .. math.min(sx, ox) .. "_" .. math.min(sy, oy) .. "_" .. math.max(sx, ox) .. "_" .. math.max(sy, oy)
			if not IterableMap.Get(bonusDisplayTable, key) then
				IterableMap.Add(bonusDisplayTable, key, {
					posList = {{sx, sy}, {ox, oy}},
					image = "pair",
					humanName = "Pair Bonus",
					desc = string.format("Paired stamps gaining %d and %d to base ♥, varies with quality.", bonus, otherBonus),
				})
			end
		end
		return bonus
	end
	return 0
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	local score = 0
	score = score + ScorePair(self, left,    x, y, x - 1, y, bonusDisplayTable)
	score = score + ScorePair(self, right,   x, y, x + 1, y, bonusDisplayTable)
	score = score + ScorePair(self, top,     x, y, x, y - 1, bonusDisplayTable)
	score = score + ScorePair(self, bottom,  x, y, x, y + 1, bonusDisplayTable)
	return score
end

local function GetSoloScore(self)
	local score = math.ceil(self.cost / 3) * self.quality
	return math.ceil(score)
end

local function GetSellValue(self)
	return 1
end

local function InitRandomStamp(self)
	self.cost = 1 + math.floor(math.random()*8)
	self.color = 1 + math.floor(math.random()*8)
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "pair",
	humanName = "Pair Stamp",
	desc = "Bonus points per adjacent pair stamp",
}

return def
