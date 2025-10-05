

local function ScorePair(self, other, sx, sy, ox, oy, bonusDisplayTable)
	if not other then
		return 0
	end
	if other.name == "herd_stamp" then
		return 1
	end
	return 0
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	local score = 0
	score = score + ScorePair(self, left,    x, y, x - 1, y, bonusDisplayTable)
	score = score + ScorePair(self, right,   x, y, x + 1, y, bonusDisplayTable)
	score = score + ScorePair(self, top,     x, y, x, y - 1, bonusDisplayTable)
	score = score + ScorePair(self, bottom,  x, y, x, y + 1, bonusDisplayTable)
	if score == 1 or score == 2 then
		score = math.ceil(self.quality / 2)
		if bonusDisplayTable then
			local key = "herd"
			local data = IterableMap.Get(bonusDisplayTable, key)
			if not data then
				data = {
					posList = {},
					image = "kangaroo",
					humanName = "Kangaroo Herd",
					score = 0,
				}
				IterableMap.Add(bonusDisplayTable, key, data)
			end
			data.score = data.score + score
			data.posList[#data.posList + 1] = {x, y}
			data.desc = "♥ " .. data.score .. " for kangaroos with one or two neighbours. Improved by quality."
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
	self.cost = def.cost or (1 + math.floor(math.random()*8))
	self.color = def.color or (1 + math.floor(math.random()*8))
	self.rarity = def.rarity or (1 + math.floor(math.random()*3))
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "kangaroo",
	humanName = "Kangaroo",
	desc = "Likes other kangaroos.",
}

return def
