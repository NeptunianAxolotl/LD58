
local function GetAdjacencyScore(self, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	local score = 15
	return math.ceil(score)
end

local function GetSellValue(self)
	return math.max(1, (self.quality - 1)*2)
end

local function InitRandomStamp(self)
	self.cost = 26
	self.color = 1 + math.floor(math.random()*8)
	self.custom = {}
end

local function PlaceAbilityCheck(self, other)
	return other.quality < 4
end

local function DoPlaceAbility(self, other)
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
	desc = "Place this stamp on another to upgrade it by one quality level.",
}

return def
