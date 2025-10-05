

local function ScorePair(self, other)
	if not other then
		return 0
	end
	if other.name == "money_stamp" then
		return -5 * self.quality
	end
	return 0
end

local function GetAdjacencyScore(self, x, y, bonusDisplayTable, left, right, top, bottom)
	local score = 0
	score = score + ScorePair(self, left)
	score = score + ScorePair(self, right)
	score = score + ScorePair(self, top)
	score = score + ScorePair(self, bottom)
	return score
end

local function GetSoloScore(self)
	local score = math.ceil(self.cost / 3) * self.quality
	return math.ceil(score)
end

local function GetSellValue(self)
	return self.cost
end

local function InitRandomStamp(self)
	self.cost = 1 + math.floor(math.random()*9)
	self.color = 1 + math.floor(math.random()*8)
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "money_stamp",
	humanName = "Money Stamp",
	desc = "Contains gold dust that is of no value to true collectors.",
}

return def
