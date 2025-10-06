
local def = {
	width = 4,
	height = 2,
	scoreRange = {120, 260},
	stampDist = util.NormaliseWeightedList({
		{probability = 2*0.10, stamp = "money_stamp"},
		{probability = 2*0.10, stamp = "wild_stamp"},
		{probability = 2*0.05, stamp = "pair_stamp"},
		{probability = 2*0.15, stamp = "kangaroo_stamp"},
		{probability = 2*0.15, stamp = "emu_stamp"},
		{probability = 2*0.05, stamp = "bird_stamp"},
		{probability = 2*0.05, stamp = "tree_stamp"},
		{probability = 2*0.10, stamp = "rocket_stamp"},
		{probability = 2*0.05, stamp = "planet_stamp"},
		{probability = 2*0.10, stamp = "snake_stamp"},
		{probability = 2*0.10, stamp = "bee_stamp"},
		{probability = 2*0.10, stamp = "flower_stamp"},
		{probability = 2*0.10, stamp = "sword_stamp"},
		{probability = 2*0.10, stamp = "bridge_stamp"},
		{probability = 0.1, stamp = "misprint_stamp"},
		{probability = 0.1, stamp = "clone_stamp"},
		{probability = 0.1, stamp = "sell_stamp"},
		{probability = 0.1, stamp = "renumber_stamp"},
		{probability = 0.1, stamp = "renumber_down_stamp"},
		{probability = 0.1, stamp = "paint_stamp"},
		{probability = 0.1, stamp = "quality_stamp"},
		{probability = 0.16, stamp = "blank_stamp"},
	}),
	earlyForceDist = util.NormaliseWeightedList({
		{probability = 0.01, forcing = "force_flush"},
		{probability = 0.01, forcing = "force_sequence"},
		{probability = 0.01, forcing = "force_rocket"},
		{probability = 0.01, forcing = "force_pair"},
		{probability = 0.01, forcing = "force_roo"},
		{probability = 1.0, forcing = "force_none"},
	}),
	scramble = util.NormaliseWeightedList({
		{probability = 0.2, target = 0, attempts = 30,},
		{probability = 0.5, target = 0.5, attempts = 30,},
		{probability = 0.3, target = 1, attempts = 30,}, -- should take the initial forced solution if no better is found
	}),
}

return def
