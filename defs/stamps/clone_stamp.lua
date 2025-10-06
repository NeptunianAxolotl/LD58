
local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	return 18
end

local function GetSellValue(self)
	return 1
end

local function InitRandomStamp(self, def)
	self.cost = def.cost or util.RandomIntegerInRange(1, StampConst.COST_RANGE)
	self.color = def.color or util.RandomIntegerInRange(1, StampConst.COLOR_RANGE)
	self.rarity = def.rarity or util.RandomIntegerInRange(1, StampConst.RAIRTY_RANGE)
end

local function PlaceAbilityCheck(self, other, book, px, py)
	return true
end

local function DoPlaceAbility(self, other, book)
	self.def = other.def
	self.name = other.name
	self.color = other.color
	self.cost = other.cost
	self.rarity = other.rarity
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
