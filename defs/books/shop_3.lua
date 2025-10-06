
local def = {
	width = 3,
	height = 3,
	scoreRange = {120, 300},
	minQuality = 2,
	maxQuality = 4,
	stampDist = util.NormaliseWeightedList({
		{probability = 0.01, stamp = "wild_stamp"},
		{probability = 0.03, stamp = "money_stamp"},
		{probability = 1, stamp = "blank_stamp"},
	}),
}

return def
