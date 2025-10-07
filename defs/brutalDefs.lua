
local def = {
	scoreRange = {
		[1] = {10, 80},
		[2] = {50, 200},
		[3] = {120, 300},
		[4] = {160, 500},
		[5] = {220, 800},
	},
	scoreRangeRandomOffset = {
		[1] = 20,
		[2] = 50,
		[3] = 60,
		[4] = 80,
		[5] = 120,
	},
	keepBest = true,
	scramble = {
		[1] = util.NormaliseWeightedList({
			{probability = 0.5, target = 0.1, attempts = 60,},
			{probability = 0.3, target = 0.5, attempts = 60,},
			{probability = 0.2, target = 1,   attempts = 60,},
		}),
		[2] = util.NormaliseWeightedList({
			{probability = 0.4, target = 0.2, attempts = 60,},
			{probability = 0.4, target = 0.6, attempts = 60,},
			{probability = 0.2, target = 1,   attempts = 60,},
		}),
		[3] = util.NormaliseWeightedList({
			{probability = 0.6, target = 0.8, attempts = 60,},
			{probability = 0.4, target = 1, attempts = 60,},
		}),
		[4] = util.NormaliseWeightedList({
			{probability = 0.4, target = 0.9, attempts = 60,},
			{probability = 0.6, target = 1, attempts = 60,},
		}),
		[5] = util.NormaliseWeightedList({
			{probability = 0.2, target = 0.9, attempts = 60,},
			{probability = 0.8, target = 1, attempts = 60,},
		}),
	},
}

return def
