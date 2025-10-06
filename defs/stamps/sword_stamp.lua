

local function ScorePair(self, other, sx, sy, ox, oy, bonusDisplayTable)
	if not other then
		return 0
	end
	if other.name == "sword_stamp" then
		if bonusDisplayTable then
			local key = "swords_" .. math.min(sx, ox) .. "_" .. math.min(sy, oy) .. "_" .. math.max(sx, ox) .. "_" .. math.max(sy, oy)
			if not IterableMap.Get(bonusDisplayTable, key) then
				IterableMap.Add(bonusDisplayTable, key, {
					posList = {{sx, sy}, {ox, oy}},
					image = "clash_sword",
					humanName = "Clashing Swords",
					desc = "Swords score nothing when adjacent.",
				})
			end
		end
		return 1
	end
	return 0
end

local function GetSoloScore(self)
	local score = (self.rarity + 1) * self.quality / 2 + self.rarity / 2 + 8
	return math.ceil(score)
end


local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	local score = 0
	score = score + ScorePair(self, left,    x, y, x - 1, y, bonusDisplayTable, score)
	score = score + ScorePair(self, right,   x, y, x + 1, y, bonusDisplayTable, score)
	score = score + ScorePair(self, top,     x, y, x, y - 1, bonusDisplayTable, score)
	score = score + ScorePair(self, bottom,  x, y, x, y + 1, bonusDisplayTable, score)
	if score > 0 then
		return -1*GetSoloScore(self)
	end
	return 0
end

local function GetSellValue(self)
	return 1
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
	image = "sword",
	humanName = "Sword Stamp",
	desc = "Clashes with other swords.",
}

return def
