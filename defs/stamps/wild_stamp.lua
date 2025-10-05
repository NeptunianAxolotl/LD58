
local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	local score = (self.rarity / 2 + 1) * self.quality / 2
	return math.ceil(score)
end

local function GetSellValue(self)
	return 1
end

local function InitRandomStamp(self, def)
	self.cost = def.cost or 20
	self.rarity = def.rarity or (1 + math.floor(math.random()*3))
	self.color = 100
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	isWildColor = true,
	image = "wild_stamp",
	humanName = "Rainbow Stamp",
	desc = "Low value, but a single one can complete a column.",
}

return def
