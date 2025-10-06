
local function GetSoloScore(self)
	return BookHelper.BaseStampScore(self)
end

local function ScorePair(self, x, y, posList, other)
	if (not other) or other.name == "blank_stamp" then
		posList[#posList + 1] = {x, y}
		return 1
	end
	return 0
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	if BookHelper.IsNextToSnake(self, x, y, bonusDisplayTable, left, right, top, bottom, "snake_kill_snake") then
		return -1*GetSoloScore(self)
	end
	local posList = {}
	local empty = 0
	empty = empty + ScorePair(self, x - 1, y, posList, left)
	empty = empty + ScorePair(self, x + 1, y, posList, right)
	empty = empty + ScorePair(self, x, y - 1, posList, top)
	empty = empty + ScorePair(self, x, y + 1, posList, bottom)
	if empty >= 3 then
		local score = 8 + self.quality
		if bonusDisplayTable then
			local key = "snake_" .. x .. "_" .. y
			posList[#posList + 1] = {x, y}
			local data = {
				posList = posList,
				image = "snake",
				humanName = "Solitary Snake",
				desc = "♥ " .. score .. " for a snake with nothing on at least three sides.",
			}
			IterableMap.Add(bonusDisplayTable, key, data)
		end
		return score
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
	image = "snake",
	humanName = "Snake Stamp",
	desc = "Spooks animals and prefers to be alone.",
}

return def
