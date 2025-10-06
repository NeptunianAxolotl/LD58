
local function ScorePair(self, other, sx, sy, ox, oy, bonusDisplayTable)
	if not other then
		return 0
	end
	if other.name == "tree_stamp" or other.name == "flower_stamp" then
		local bonus = other.quality + self.quality + 5
		if bonusDisplayTable then
			local key = "pair_" .. math.min(sx, ox) .. "_" .. math.min(sy, oy) .. "_" .. math.max(sx, ox) .. "_" .. math.max(sy, oy)
			if not IterableMap.Get(bonusDisplayTable, key) then
				IterableMap.Add(bonusDisplayTable, key, {
					posList = {{sx, sy}, {ox, oy}},
					image = other.name == "flower_stamp" and "bird_flower" or "bird_tree",
					humanName = "Nesting Bonus",
					desc = string.format("This bird %s gains %d to base ♥, based on quality of both.", (other.name == "flower_stamp" and "perched on a flower" or "nesting in a tree"), bonus),
				})
			end
		end
		return bonus
	end
	return 0
end

local function GetSoloScore(self)
	return BookHelper.BaseStampScore(self)
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	if BookHelper.IsNextToSnake(self, x, y, bonusDisplayTable, left, right, top, bottom, "snake_kill_bird") then
		return -1*GetSoloScore(self)
	end
	score = ScorePair(self, bottom, x, y, x, y + 1, bonusDisplayTable)
	return score
end

local function GetSellValue(self)
	return StampConst.BASIC_SELL_VALUE
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
	image = "bird",
	humanName = "Bird Stamp",
	desc = "A stamp with a picture of a bird.",
}

return def
