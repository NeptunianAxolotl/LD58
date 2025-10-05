local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	local score = (self.rarity + 1) * self.quality / 2 + self.rarity / 2
	return math.ceil(score)
end

local function GetSellValue(self)
	return 1
end

local function InitRandomStamp(self, def)
	self.cost = def.cost or 0
	self.color = def.color or (1 + math.floor(math.random()*8))
	self.rarity = def.rarity or (1 + math.floor(math.random()*3))
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "emu",
	humanName = "Misprinted Stamp",
	desc = "What good is a stamp with no postage value?",
}

return def
