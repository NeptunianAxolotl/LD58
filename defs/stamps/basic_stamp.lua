

local function ScorePair(self, other)
	if not other then
		return 0
	end
	local colorBonus = self.color == other.color and 5 or 1
	local numberFactor = util.GreatestCommonDivisor(self.cost, other.cost) 
	return math.ceil(numberFactor * colorBonus)
end

local function GetScore(self, left, right, top, bottom)
	--local score = self.cost
	--score = score + ScorePair(self, left)
	--score = score + ScorePair(self, right)
	--score = score + ScorePair(self, top)
	--score = score + ScorePair(self, bottom)
	return math.ceil(0)
end

local function GetSoloScore(self)
	local score = math.ceil(self.cost / 3) * self.quality
	return math.ceil(score)
end

local def = {
	GetScore = GetScore,
	GetSoloScore = GetSoloScore,
	image = "stamp",
}

return def
