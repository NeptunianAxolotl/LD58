

local function ScorePair(self, other)
	if not other then
		return 0
	end
	local colorBonus = util.Dot(self.color, other.color) > 0.5 and 2 or 1
	local numberFactor = util.GreatestCommonDivisor(self.cost, other.cost) 
	return math.ceil(numberFactor * colorBonus / 2)
end

local function GetScore(self, left, right, top, bottom)
	local score = self.cost
	score = score + ScorePair(self, left)
	score = score + ScorePair(self, right)
	score = score + ScorePair(self, top)
	score = score + ScorePair(self, bottom)
	return math.ceil(score)
end

local def = {
	GetScore = GetScore,
	image = "stamp",
}

return def
