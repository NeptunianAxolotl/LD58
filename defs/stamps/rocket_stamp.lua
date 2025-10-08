

local function ScorePair(self, other, sx, sy, ox, oy, bonusDisplayTable)
	if not other then
		return 0
	end
	if other.name == "planet_stamp" then
		local bonus = other.quality + self.quality + 5
		if bonusDisplayTable then
			local key = "rocket_" .. sx .. "_" .. sy
			if not IterableMap.Get(bonusDisplayTable, key) then
				IterableMap.Add(bonusDisplayTable, key, {
					posList = {{sx, sy}, {ox, oy}},
					image = "saturn_ship",
					humanName = "Rocket Bonus",
					desc = string.format("With an adjacent planet Rocket gains %d to base ♥, based on quality of both.", bonus),
				})
			end
		end
		return bonus
	end
	return 0
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	local score = 0
	
	score = ScorePair(self, left,    x, y, x - 1, y, bonusDisplayTable)
	
	if score == 0 then
		score = ScorePair(self, right,   x, y, x + 1, y, bonusDisplayTable)
	end
	if score == 0 then
		score = ScorePair(self, top,     x, y, x, y - 1, bonusDisplayTable)
	end
	if score == 0 then
		score = ScorePair(self, bottom,  x, y, x, y + 1, bonusDisplayTable)
	end
	return score
end

local function GetSoloScore(self)
	return BookHelper.BaseStampScore(self)
end

local function GetSellValue(self)
	return StampConst.BASIC_SELL_VALUE
end

local function InitRandomStamp(self, def)
	self.cost = def.cost or util.RandomIntegerInRange(1, StampConst.COST_RANGE)
	self.color = def.color or util.RandomIntegerInRange(1, StampConst.COLOR_RANGE)
	self.rarity = def.rarity or util.RandomIntegerInRange(1, StampConst.RAIRTY_RANGE)
end


local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "rocket_stamp",
	humanName = "Rocket Stamp",
	desc = "Bonus points if adjacent to a Planet.",
}

return def
