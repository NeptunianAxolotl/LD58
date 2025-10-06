
local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	return BookHelper.BaseStampScore(self)
end

local function GetSellValue(self)
	return self.cost
end

local function InitRandomStamp(self, def)
	self.cost = def.cost or (3 + math.floor(math.random()*6))
	self.color = def.color or util.RandomIntegerInRange(1, StampConst.COLOR_RANGE)
	self.rarity = def.rarity or util.RandomIntegerInRange(1, StampConst.RAIRTY_RANGE)
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "gold",
	drawDollar = true,
	humanName = "Money Stamp",
	desc = "Contains gold dust that is of no value to true collectors.",
}

return def
