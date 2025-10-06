
local function ScorePair(self, other, sx, sy, ox, oy, bonusDisplayTable)
	if not other then
		return 0
	end
	if other.name == "flower_stamp" then
		local bonus = other.quality
		return bonus
	end
	return 0
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	local score = 0
	score = score + ScorePair(self, left,    x, y, x - 1, y, bonusDisplayTable)
	score = score + ScorePair(self, right,   x, y, x + 1, y, bonusDisplayTable)
	score = score + ScorePair(self, top,     x, y, x, y - 1, bonusDisplayTable)
	score = score + ScorePair(self, bottom,  x, y, x, y + 1, bonusDisplayTable)
	if score > 0 then
		score = self.quality
		if bonusDisplayTable then
			local key = "bees_like_flowers"
			local data = IterableMap.Get(bonusDisplayTable, key)
			if not data then
				data = {
					posList = {},
					image = "bee_flower",
					humanName = "Bees and Flowers",
					score = 0,
				}
				IterableMap.Add(bonusDisplayTable, key, data)
			end
			data.score = data.score + score
			data.posList[#data.posList + 1] = {x, y}
			data.desc = "♥ " .. data.score .. " total for bees neighbouring flowers. Improved by quality."
		end
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
	image = "bee",
	humanName = "Bee Stamp",
	desc = "Bees like flowers and flowers like bees.",
}

return def
