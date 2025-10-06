
local def = {
	width = 4,
	height = 4,
	scoreRange = {0, 70},
	minQuality = 1,
	maxQuality = 2,
	stampDist = util.NormaliseWeightedList({
		{probability = 0.10, stamp = "wild_stamp"},
		{probability = 0.02, stamp = "money_stamp"},
		{probability = 0.4, stamp = "pair_stamp"},
		{probability = 1, stamp = "blank_stamp"},
	}),
	forcingDist = util.NormaliseWeightedList({
		{probability = 1.0, forcing = "force_none"},
	}),
}

return def
