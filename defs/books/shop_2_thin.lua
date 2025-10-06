
local shop = require("defs/shopLevelDefs")

local def = {
	width = 2,
	height = 3,
	scoreRange = shop.scoreRange[2],
	stampDist = shop.stampDist[2],
	earlyForceDist = util.NormaliseWeightedList({
		{probability = 0.05, forcing = "force_flush"},
		{probability = 0.05, forcing = "force_sequence"},
		{probability = 0.05, forcing = "force_rocket"},
		{probability = 0.05, forcing = "force_pair"},
		{probability = 0.05, forcing = "force_roo"},
		{probability = 1.0, forcing = "force_none"},
	}),
	scramble = util.NormaliseWeightedList({
		{probability = 0.4, target = 0, attempts = 30,},
		{probability = 0.4, target = 0.25, attempts = 30,},
		{probability = 0.2, target = 0.5, attempts = 30,}, -- dont scramble
	}),
}

return def
