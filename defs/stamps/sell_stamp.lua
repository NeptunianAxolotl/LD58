
local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	local score = 10
	return math.ceil(score)
end

local function GetSellValue(self)
	return 1
end

local function InitRandomStamp(self, def)
	self.cost = def.cost or (5 + math.floor(math.random()*3))
	self.color = def.color or (1 + math.floor(math.random()*8))
	self.rarity = def.rarity or (1 + math.floor(math.random()*3))
end

local function PlaceAbilityMoneyGain(self, other, book, px, py)
	local multiplier = other.GetStampMultiplier(book, px, py)
	return math.ceil(multiplier * other.GetSoloScore())
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
	image = "sell_stamp",
	humanName = "Sell Stamp",
	desc = "Place this on another stamp to sell it for its ♥ value. Consumes the sell stamp.",
}

return def
