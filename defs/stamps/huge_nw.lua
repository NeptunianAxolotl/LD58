
local function OtherMatches(other, name)
	return (other and other.name == name)
end

local function UpdateAdjacencyData(self, x, y, bookSelf, bonusDisplayTable, left, right, top, bottom, ne, nw, sw, se)
	if (OtherMatches(right, "huge_ne") and OtherMatches(se, "huge_se") and OtherMatches(bottom, "huge_sw")) then
		bookSelf.rowColumnGlobalMult = 2
		if bonusDisplayTable then
			IterableMap.Add(bonusDisplayTable, "huge_multiplier", {
				posList = {{x, y}, {x + 1, y}, {x, y + 1}, {x + 1, y + 1}},
				image = "big_ne",
				humanName = "Cog Multiplier",
				desc = string.format("Double row and column multipliers. Only one per book.", bonus, otherBonus),
			})
		end
	end
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	local score = 0
	return score
end

local function GetSoloScore(self)
	return math.ceil(BookHelper.BaseStampScore(self) * 1.5)
end

local function GetSellValue(self)
	return StampConst.ADV_SELL_VALUE
end

local function InitRandomStamp(self, def)
	self.cost = def.cost or util.RandomIntegerInRange(1, StampConst.COST_RANGE)
	self.color = def.color or util.RandomIntegerInRange(1, StampConst.COLOR_RANGE)
	self.rarity = def.rarity or util.RandomIntegerInRange(1, StampConst.RAIRTY_RANGE)
end

local def = {
	UpdateAdjacencyData = UpdateAdjacencyData,
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "big_nw",
	humanName = "Cog Segment",
	shopLimitCategory = "huge_stamp",
	shopLimit = 1,
	desc = "Part of something larger?",
}

return def
