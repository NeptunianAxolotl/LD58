

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	return -100
end

local function GetSellValue(self)
	return 0
end

local function InitRandomStamp(self, def)
	self.cost = 0
	self.color = 200
	self.rarity = 2
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "censored_stamp",
	humanName = "CENSORED",
	desc = "Why would that be on a stamp???",
	maxQuality = 1,
	minQuality = 1,
	noColor = true,
	shopLimitCategory = "negative",
	shopLimit = 1,
}

return def
