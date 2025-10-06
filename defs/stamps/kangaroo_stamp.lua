
local function OtherMatches(other, name)
	return (other and other.name == name)
end


local function ScorePair(self, other, sx, sy, ox, oy, bonusDisplayTable)
	if not other then
		return 0
	end
	if other.name == "kangaroo_stamp" and not other.spookedBySnake then
		return 1
	end
	return 0
end

local function GetSoloScore(self)
	return BookHelper.BaseStampScore(self)
end

local function UpdateAdjacencyData(self, x, y, bookSelf, bonusDisplayTable, left, right, top, bottom)
	self.spookedBySnake = BookHelper.IsNextToSnake(self, x, y, bonusDisplayTable, left, right, top, bottom, "snake_kill_kangaroo")
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	if self.spookedBySnake then
		return -1*GetSoloScore(self)
	end
	local score = 0
	score = score + ScorePair(self, left,    x, y, x - 1, y, bonusDisplayTable)
	score = score + ScorePair(self, right,   x, y, x + 1, y, bonusDisplayTable)
	score = score + ScorePair(self, top,     x, y, x, y - 1, bonusDisplayTable)
	score = score + ScorePair(self, bottom,  x, y, x, y + 1, bonusDisplayTable)
	if score == 1 or score == 2 then
		score = self.quality
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
			data.desc = "♥ " .. data.score .. " for kangaroos with one or two neighbours, based on quality."
		end
	end
	if OtherMatches(right, "emu_stamp") and not right.spookedBySnake then
		score = score + 1 + right.quality
		if bonusDisplayTable then
			local coatOfArmsScore = 2 + self.quality + right.quality
			local key = "coat_of_arms_" .. x .. "_" .. y
			IterableMap.Add(bonusDisplayTable, key, {
				posList = {{x, y}, {x + 1, y}},
				image = "coat_of_arms",
				humanName = "Coat of Arms",
				desc = string.format("Gaining %d ♥, based on quality of both.", coatOfArmsScore),
			})
		end
	end
	return score
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
	UpdateAdjacencyData = UpdateAdjacencyData,
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "kangaroo",
	humanName = "Kangaroo Stamp",
	desc = "Likes other kangaroos.",
}

return def
