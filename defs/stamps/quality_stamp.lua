
local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	return 15
end

local function GetSellValue(self)
	return 1
end

local function InitRandomStamp(self, def)
	self.cost = 26
	self.color = 1 + math.floor(math.random()*8)
	self.rarity = def.rarity or (1 + math.floor(math.random()*3))
end

local function PlaceAbilityCheck(self, other, book, px, py)
	return other.quality < 4
end

local function DoPlaceAbility(self, other, book)
	other.quality = other.quality + 1
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	PlaceAbilityCheck = PlaceAbilityCheck,
	DoPlaceAbility = DoPlaceAbility,
	placeConsumes = true,
	image = "quality_stamp",
	humanName = "Quality Stamp",
	desc = "Place this stamp on another to upgrade it by one quality level. Consumes the quality stamp.",
}

return def
