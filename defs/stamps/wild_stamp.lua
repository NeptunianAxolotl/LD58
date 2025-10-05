
local function GetAdjacencyScore(self, left, right, top, bottom)
	return 0
end

local function GetSoloScore(self)
	local score = self.quality
	return math.ceil(score)
end

local function GetSellValue(self)
	return math.max(1, (self.quality - 1)*2)
end

local function InitRandomStamp(self)
	self.cost = 20
	self.color = 100
	self.custom = {}
	self.custom["wild_color"] = true
end

local def = {
	GetAdjacencyScore = GetAdjacencyScore,
	GetSoloScore = GetSoloScore,
	GetSellValue = GetSellValue,
	InitRandomStamp = InitRandomStamp,
	image = "wild_stamp",
	humanName = "Rainbow",
	desc = "Low value but a single one can complete a flush.",
}

return def
