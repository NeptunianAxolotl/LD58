
local stamps = util.LoadDefDirectory("defs/stamps")
local newStamps = {}

for name, def in pairs(stamps) do
	def.name = name
	newStamps[name] = def
end

local data = {
	defs = newStamps,
	COST_RANGE = 9,
	COLOR_RANGE = 8,
	RAIRTY_RANGE = 3,
	ABILITY_RAITY = 4,
	QUALITY_RANGE = 3,
	BASIC_SELL_VALUE = 2,
	ADV_SELL_VALUE = 3,
	QUALITY_CONSUMED_PER_ABILITY = 2,
	colorMap = {
		[1] = {{1, 0.6, 0.1}, {1, 0.6, 0.1}},
		[2] = {{0.2, 0.6, 1}, {0.2, 0.6, 1}},
		[3] = {{0.9, 0.9,   0}, {0.9, 0.9,   0}},
		[4] = {{0, 1,   0}, {0, 1,   0}},
		[5] = {{1, 0,   0}, {1, 0,   0}},
		[6] = {{1, 0,   1}, {1, 0,   1}},
		[7] = {{0, 0.8, 0.8  }, {0, 0.8, 0.8  }},
		[8] = {{0.97, 0.97, 0.96  }, {0.97, 0.97, 0.96  }},
		[100] = {{0, 0, 0}, {1, 1, 1}},
	},
	colorBlindMap = {
		[1] = "A",
		[2] = "B",
		[3] = "C",
		[4] = "D",
		[5] = "E",
		[6] = "F",
		[7] = "G",
		[8] = "H",
	},
	qualityMap = {
		"Poor",
		"Good",
		"Excellent",
	},
	rarityColorMap = {
		{0.7, 0.48, 0.3},
		{0.92, 0.86, 0.78},
		{0.9, 0.8, 0.4},
		{0.9, 0, 0.7},
	},
}

return data
