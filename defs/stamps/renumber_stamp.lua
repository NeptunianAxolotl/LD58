
local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	return BookHelper.BaseStampScore(self)
end

local function GetSellValue(self)
	return StampConst.ADV_SELL_VALUE
end

local function InitRandomStamp(self, def)
	self.cost = 1
	self.color = def.color or util.RandomIntegerInRange(1, StampConst.COLOR_RANGE)
	self.rarity = StampConst.ABILITY_RAITY
end

local function PlaceAbilityCheck(self, other, book, px, py)
	return not other.def.fixedCost
end

local function DoPlaceAbility(self, other, book)
	other.cost = other.cost + 1
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	PlaceAbilityCheck = PlaceAbilityCheck,
	DoPlaceAbility = DoPlaceAbility,
	fixedCost = true,
	placeConsumes = true,
	costDrawAppend = "+",
	image = "pen_reverse",
	humanName = "Addition Stamp",
	desc = "Increases the cost of a stamp by 1¢.",
}

return def
