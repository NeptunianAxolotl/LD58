
local shop = require("defs/shopLevelDefs")

local def = {
	width = 4,
	height = 4,
	scoreRange = {320, 520},
	scoreRange = shop.scoreRange[5],
	stampDist = shop.stampDist[5],
	scramble = util.NormaliseWeightedList({
		{probability = 0.1, target = 0, attempts = 30,},
		{probability = 0.6, target = 0.75, attempts = 30,},
		{probability = 0.3, target = 1, attempts = 30,}, -- should take the initial forced solution if no better is found
	}),
}

return def
