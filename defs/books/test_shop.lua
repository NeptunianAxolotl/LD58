
local def = {
	width = 3,
	height = 3,
	scoreRange = {1, 120},
	minQuality = 1,
	maxQuality = 3,
	stampDist = util.NormaliseWeightedList({
		{probability = 0.2, stamp = "wild_stamp"},
		{probability = 0.2, stamp = "money_stamp"},
		{probability = 0.2, stamp = "quality_stamp"},
		{probability = 0.2, stamp = "paint_stamp"},
		{probability = 0.2, stamp = "renumber_stamp"},
		{probability = 0.2, stamp = "sell_stamp"},
		{probability = 0.2, stamp = "clone_stamp"},
		{probability = 1, stamp = "basic_stamp"},
	}),
	forcingDist = util.NormaliseWeightedList({
		{probability = 0.4, forcing = "force_rocket"},
		{probability = 0.2, forcing = "force_flush"},
		{probability = 0.2, forcing = "force_sequence"},
		{probability = 0.2, forcing = "force_none"},
	}),
}

return def
