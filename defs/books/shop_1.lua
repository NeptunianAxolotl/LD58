
local def = {
	width = 3,
	height = 3,
	scoreRange = {0, 70},
	minQuality = 1,
	maxQuality = 2,
	stampDist = util.NormaliseWeightedList({
		{probability = 0.10, stamp = "wild_stamp"},
		{probability = 0.02, stamp = "money_stamp"},
		{probability = 0.4, stamp = "pair_stamp"},
		{probability = 1, stamp = "blank_stamp"},
	}),
	earlyForceDist = util.NormaliseWeightedList({
		{probability = 0.4, forcing = "force_flush"},
		{probability = 0.2, forcing = "force_sequence"},
		{probability = 0.1, forcing = "force_rocket"},
		{probability = 0.3, forcing = "force_none"},
	}),
	scramble = { doWithProb = 1.0, target = 0, attempts = 30 
	},
}

return def
