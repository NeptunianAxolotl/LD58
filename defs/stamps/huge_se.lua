
local function OtherMatches(other, name)
	return (other and other.name == name) and 1 or 0
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	local score = 0
	return score
end

local function GetSoloScore(self)
	local score = (self.rarity + 4) * self.quality + self.rarity + 4
	return math.ceil(score)
end

local function GetSellValue(self)
	return 10
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
	image = "big_se",
	humanName = "Cog Segment",
	desc = "Part of something larger?",
}

return def
