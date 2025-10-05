
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
	self.cost = 1 + math.floor(math.random()*10)
	self.color = 1 + math.floor(math.random()*8)
end

local function PlaceAbilityCheck(self, other, book, px, py)
	return true
end

local function DoPlaceAbility(self, other, book)
	self.def = other.def
	self.color = other.color
	self.cost = other.cost
	-- Leave quality as-is?
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	PlaceAbilityCheck = PlaceAbilityCheck,
	DoPlaceAbility = DoPlaceAbility,
	image = "clone_stamp",
	humanName = "Clone Stamp",
	desc = "Place this stamp on another to copy it. Only quality is preserved.",
}

return def
