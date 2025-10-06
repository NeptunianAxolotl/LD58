
local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	return BookHelper.BaseStampScore(self)
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
	return other.quality < StampConst.QUALITY_RANGE
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
