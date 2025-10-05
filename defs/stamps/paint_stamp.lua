
local function GetAdjacencyScore(self, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	local score = -10
	return math.ceil(score)
end

local function GetSellValue(self)
	return math.max(1, (self.quality - 1)*2)
end

local function InitRandomStamp(self)
	self.cost = 1 + math.floor(math.random()*3)
	self.color = 1 + math.floor(math.random()*8)
end

local function PlaceAbilityCheck(self, other, book, px, py)
	return not other.def.isWildColor
end

local function DoPlaceAbility(self, other, book)
	other.color = self.color
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	PlaceAbilityCheck = PlaceAbilityCheck,
	DoPlaceAbility = DoPlaceAbility,
	placeConsumes = true,
	image = "paint_stamp",
	humanName = "Paint Stamp",
	desc = "Place this stamp on another to paint it a new colour. Consumes the paint stamp.",
}

return def
