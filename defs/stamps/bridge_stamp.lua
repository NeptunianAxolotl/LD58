
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
	local score = 0
	score = score + math.ceil(ScorePair(self, left) / 2)
	score = score + math.ceil(ScorePair(self, right) / 2)
	if score > 0 then
		score = score + math.ceil(self.quality / 2)
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
