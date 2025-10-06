

local function ScorePair(self, other, sx, sy, ox, oy, bonusDisplayTable)
	if not other then
		return 0
	end
	if self.adjacencyDisabled or other.adjacencyDisabled then
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
					desc = string.format("Paired stamps gaining %d and %d to base ♥, improves with quality.", bonus, otherBonus),
				})
			end
		end
		return bonus
	end
	return 0
end

local function CountPair(other)
	return (other and other.name == "pair_stamp") and 1 or 0
end

local function UpdateAdjacencyData(self, x, y, bookSelf, bonusDisplayTable, left, right, top, bottom)
	local count = CountPair(left) + CountPair(right) + CountPair(top) + CountPair(bottom)
	self.adjacencyDisabled = (count ~= 1)
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
	local score = (self.rarity + 1) * self.quality / 2 + self.rarity / 2
	return math.ceil(score)
end

local function GetSellValue(self)
	return 1
end

local function InitRandomStamp(self, def)
	self.cost = def.cost or util.RandomIntegerInRange(1, StampConst.COST_RANGE)
	self.color = def.color or util.RandomIntegerInRange(1, StampConst.COLOR_RANGE)
	self.rarity = def.rarity or util.RandomIntegerInRange(1, StampConst.RAIRTY_RANGE)
end

local def = {
	UpdateAdjacencyData = UpdateAdjacencyData,
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "pair",
	humanName = "Pair Stamp",
	desc = "Bonus points when next to one pair stamp",
}

return def
