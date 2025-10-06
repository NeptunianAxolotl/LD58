
local stamps = util.LoadDefDirectory("defs/stamps")
local newStamps = {}

for name, def in pairs(stamps) do
	def.name = name
	newStamps[name] = def
end

local data = {
	defs = newStamps,
	COST_RANGE = 7,
	COLOR_RANGE = 8,
	RAIRTY_RANGE = 3,
	ABILITY_RAITY = 4,
	HUGE_RARITY = 5,
	QUALITY_RANGE = 3,
	BASIC_SELL_VALUE = 2,
	ADV_SELL_VALUE = 3,
	QUALITY_CONSUMED_PER_ABILITY = 1,
	colorMap = {
		[1] = {{1, 0.6, 0.12}, {1, 0.6, 0.12}},
		[2] = {{0.22, 0.62, 1}, {0.22, 0.62, 1}},
		[3] = {{0.9, 0.9,   0}, {0.9, 0.9,   0}},
		[4] = {{0, 0.92,   0}, {0, 0.92,   0}},
		[5] = {{1, 0,   0}, {1, 0,   0}},
		[6] = {{0.85, 0,   0.85}, {0.85, 0,   0.85}},
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
		{0.92, 0.7, 0.5},
		{0.92, 0.8, 0.68},
		{0.8, 0.72, 0.45},
		{0.9, 0, 0.7},
		{0.91, 0.83, 0.42},
	},
}

return data
