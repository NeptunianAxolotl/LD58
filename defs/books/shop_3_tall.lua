
local def = {
	width = 3,
	height = 4,
	scoreRange = {120, 300},
	minQuality = 2,
	maxQuality = 4,
	stampDist = util.NormaliseWeightedList({
		{probability = 0.02, stamp = "money_stamp"},
		{probability = 1, stamp = "basic_stamp"},
	}),
}

return def
