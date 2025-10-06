
local shop = require("defs/shopLevelDefs")

local def = {
	width = 3,
	height = 2,
	scoreRange = shop.scoreRange[1],
	stampDist = shop.stampDist[1],
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
