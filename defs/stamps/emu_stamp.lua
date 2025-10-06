
local function OtherMatches(other, name)
	return (other and other.name == name)
end


local function ScorePair(self, other, sx, sy, ox, oy, bonusDisplayTable)
	if not other then
		return 0
	end
	if other.name == "emu_stamp" then
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
			local key = "emu_herd"
			local data = IterableMap.Get(bonusDisplayTable, key)
			if not data then
				data = {
					posList = {},
					image = "emu",
					humanName = "Emu Herd",
					score = 0,
				}
				IterableMap.Add(bonusDisplayTable, key, data)
			end
			data.score = data.score + score
			data.posList[#data.posList + 1] = {x, y}
			data.desc = "♥ " .. data.score .. " for emus with one or two neighbours. Improved by quality."
		end
	end
	if OtherMatches(left, "kangaroo_stamp") then
		score = score + self.quality + 1
		-- Kangaroo adds the bonus icon
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
	image = "emu",
	humanName = "Emu Stamp",
	desc = "Likes other emus.",
}

return def
