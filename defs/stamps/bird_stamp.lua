

local function ScorePair(self, other, sx, sy, ox, oy, bonusDisplayTable)
	if not other then
		return 0
	end
	if other.name == "tree_stamp" then
		local bonus = 2 * (self.quality + other.quality + 1)
		if bonusDisplayTable then
			local key = "pair_" .. math.min(sx, ox) .. "_" .. math.min(sy, oy) .. "_" .. math.max(sx, ox) .. "_" .. math.max(sy, oy)
			if not IterableMap.Get(bonusDisplayTable, key) then
				IterableMap.Add(bonusDisplayTable, key, {
					posList = {{sx, sy}, {ox, oy}},
					image = "bird_tree",
					humanName = "Nesting Bonus",
					desc = string.format("This bird nesting in a tree gains %d to base ♥, based on quality of both.", bonus),
				})
			end
		end
		return bonus
	end
	return 0
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	score = ScorePair(self, bottom, x, y, x, y + 1, bonusDisplayTable)
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
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "bird",
	humanName = "Bird Stamp",
	desc = "A stamp with a picture of a bird.",
}

return def
