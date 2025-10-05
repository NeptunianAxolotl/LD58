
local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	return 5
end

local function GetSellValue(self)
	return 1
end

local function InitRandomStamp(self, def)
	self.cost = def.cost or (1 + math.floor(math.random()*8))
	self.color = def.color or (1 + math.floor(math.random()*8))
	self.rarity = def.rarity or (1 + math.floor(math.random()*3))
end

local function PlaceAbilityCheck(self, other, book, px, py)
	return true
end

local function DoPlaceAbility(self, other, book)
	other.cost = self.cost
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	PlaceAbilityCheck = PlaceAbilityCheck,
	DoPlaceAbility = DoPlaceAbility,
	placeConsumes = true,
	image = "pen",
	humanName = "Pen Stamp (Single Use)",
	desc = "Overrides the cost of the stamp it is placed on. Consumes pen stamp.",
}

return def
