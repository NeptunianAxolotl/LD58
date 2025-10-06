
local shop = require("defs/shopLevelDefs")

local def = {
	width = 2,
	height = 4,
	scoreRange = {120, 260},
	stampDist = shop.stampDist[3],
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
