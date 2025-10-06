
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
	self.cost = def.cost or (5 + math.floor(math.random()*3))
	self.color = def.color or util.RandomIntegerInRange(1, StampConst.COLOR_RANGE)
	self.rarity = StampConst.ABILITY_RAITY
end

local function PlaceAbilityMoneyGain(self, other, book, px, py)
	local multiplier = other.GetStampMultiplier(book, px, py)
	return math.ceil(multiplier * (other.GetSoloScore() + ((book and BookHelper.GetStampAdjacencyScore(book.GetSelfData(), px, py)) or 0)))
end

local function PlaceAbilityCheck(self, other, book, px, py)
	return PlaceAbilityMoneyGain(self, other, book, px, py) > 0
end

local function DoPlaceAbility(self, other, book, px, py)
	TableHandler.AddMoney(PlaceAbilityMoneyGain(self, other, book, px, py))
	other.wantDestroy = true
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	PlaceAbilityCheck = PlaceAbilityCheck,
	DoPlaceAbility = DoPlaceAbility,
	PlaceAbilityMoneyGain = PlaceAbilityMoneyGain, -- For tooltips
	placeConsumes = true,
	drawDollar = true,
	image = "bank",
	humanName = "Bank Stamp",
	desc = "Place this on another stamp to sell it for its ♥ value. Consumes the bank stamp.",
}

return def
