
local def = {
	width = 2,
	height = 3,
	scoreRange = {0, 70},
	minQuality = 1,
	maxQuality = 2,
	stampDist = util.NormaliseWeightedList({
		{probability = 0.01, stamp = "wild_stamp"},
		{probability = 0.02, stamp = "money_stamp"},
		{probability = 1, stamp = "basic_stamp"},
	}),
}

return def
