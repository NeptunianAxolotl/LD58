
local def = {
	width = 4,
	height = 4,
	scoreRange = {-200, 1000},
	minQuality = 1,
	maxQuality = 5,
	stampDist = util.NormaliseWeightedList({
		-- Basic stamps
		{probability = 1, stamp = "bird_stamp"},
		{probability = 1, stamp = "tree_stamp"},
		{probability = 1, stamp = "kangaroo_stamp"},
		{probability = 1, stamp = "emu_stamp"},
		{probability = 1, stamp = "rocket_stamp"},
		{probability = 1, stamp = "planet_stamp"},
		{probability = 1, stamp = "pair_stamp"},
		{probability = 1, stamp = "sword_stamp"},
		{probability = 1, stamp = "bridge_stamp"},
		{probability = 1, stamp = "snake_stamp"},
		{probability = 10, stamp = "flower_stamp"},
		
		-- Weird stamps
		{probability = 1, stamp = "blank_stamp"},
		{probability = 1, stamp = "misprint_stamp"},
		{probability = 1, stamp = "money_stamp"},
		{probability = 1, stamp = "wild_stamp"},
		{probability = 1, stamp = "negative_stamp"},
		
		-- Assemble
		{probability = 1, stamp = "huge_nw"},
		{probability = 1, stamp = "huge_ne"},
		{probability = 1, stamp = "huge_se"},
		{probability = 1, stamp = "huge_sw"},
		
		-- Abilities
		{probability = 1, stamp = "sell_stamp"},
		{probability = 1, stamp = "clone_stamp"},
		{probability = 1, stamp = "quality_stamp"},
		{probability = 1, stamp = "paint_stamp"},
		{probability = 1, stamp = "renumber_stamp"},
	}),
	earlyForceDist = util.NormaliseWeightedList({
		{probability = 0.4, forcing = "force_rocket"},
		{probability = 0.2, forcing = "force_flush"},
		{probability = 0.2, forcing = "force_sequence"},
		{probability = 0.2, forcing = "force_none"},
	}),
}

return def
