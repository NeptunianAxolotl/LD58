
local function GetAdjacencyScore(self, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	local score = math.ceil(self.cost / 3) * self.quality
	return math.ceil(score)
end

local function GetSellValue(self)
	return math.max(1, (self.quality - 1)*2)
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	image = "stamp",
}

return def
