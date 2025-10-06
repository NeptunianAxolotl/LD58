
local def = {
	width = 3,
	height = 3,
	scoreRange = {0, 80},
	stampDist = util.NormaliseWeightedList({
		{probability = 0.10, stamp = "money_stamp"},
		{probability = 0.10, stamp = "wild_stamp"},
		{probability = 0.02, stamp = "negative_stamp"},
		{probability = 0.08, stamp = "snake_stamp"},
		{probability = 0.15, stamp = "kangaroo_stamp"},
		{probability = 0.15, stamp = "emu_stamp"},
		{probability = 0.05, stamp = "bird_stamp"},
		{probability = 0.05, stamp = "tree_stamp"},
		{probability = 0.10, stamp = "rocket_stamp"},
		{probability = 0.05, stamp = "planet_stamp"},
		{probability = 0.05, stamp = "misprint_stamp"},
		{probability = 0.16, stamp = "blank_stamp"},
	}),
	earlyForceDist = util.NormaliseWeightedList({
		{probability = 0.2, forcing = "force_flush"},
		{probability = 0.2, forcing = "force_sequence"},
		{probability = 0.1, forcing = "force_rocket"},
		{probability = 0.1, forcing = "force_pair"},
		{probability = 0.1, forcing = "force_roo"},
		{probability = 0.3, forcing = "force_none"},
	}),
	scramble = util.NormaliseWeightedList({
		{probability = 0.99, target = 0, attempts = 30,},
		{probability = 0.01, attempts = 0}, -- dont scramble
	}),
}

return def
