
local def = {
	width = 3,
	height = 3,
	scoreRange = {80, 120},
	minQuality = 1,
	maxQuality = 3,
	stampDist = util.NormaliseWeightedList({
		{probability = 0.01, stamp = "wild_stamp"},
		{probability = 0.03, stamp = "money_stamp"},
		{probability = 1, stamp = "basic_stamp"},
	}),
}

return def
