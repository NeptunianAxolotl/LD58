
local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	local score = -10
	return math.ceil(score)
end

local function GetSellValue(self)
	return 1
end

local function InitRandomStamp(self)
	self.cost = 1 + math.floor(math.random()*10)
	self.color = 1 + math.floor(math.random()*8)
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
	image = "renumber_stamp",
	humanName = "Recost Stamp",
	desc = "Place this stamp on another to copy the cost across. Consumes the recost stamp.",
}

return def
