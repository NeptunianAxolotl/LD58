
local function ScorePair(self, other)
	if not other then
		return 0
	end
	if other.name == "bridge_stamp" then
		return other.quality
	end
	return 0
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	local quality = 0
	quality = quality + ScorePair(self, left)
	quality = quality + ScorePair(self, right)
	if quality > 0 then
		score = math.ceil(self.quality / 2) + 1
		if bonusDisplayTable then
			local key = "bridge_row_" .. y
			local data = IterableMap.Get(bonusDisplayTable, key)
			if not data then
				data = {
					posList = {},
					image = "bridge",
					humanName = "Bridge Bonus",
					score = 0,
				}
				IterableMap.Add(bonusDisplayTable, key, data)
			end
			data.score = data.score + score
			data.posList[#data.posList + 1] = {x, y}
			data.desc = "♥ " .. data.score .. " for a row of bridges. Improved by quality."
		end
	end
	return score
end

local function GetSoloScore(self)
	local score = self.rarity * self.quality / 2 + self.rarity / 2
	return math.ceil(score)
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
	image = "bridge",
	humanName = "Bridge Stamp",
	desc = "Build a long bridge.",
}

return def
