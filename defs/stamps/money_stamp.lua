


local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	local score = (self.rarity + 1) * self.quality / 2 + self.rarity / 2 + 5
	return math.ceil(score)
end

local function GetSellValue(self)
	return self.cost
end

local function InitRandomStamp(self, def)
	self.cost = def.cost or (1 + math.floor(math.random()*8))
	self.color = def.color or (1 + math.floor(math.random()*8))
	self.rarity = def.rarity or (1 + math.floor(math.random()*3))
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "money_stamp",
	humanName = "Money Stamp",
	desc = "Contains gold dust that is of no value to true collectors.",
}

return def
