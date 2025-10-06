
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
	QUALITY_RANGE = 5,
	BASIC_SELL_VALUE = 2,
	ADV_SELL_VALUE = 3,
	QUALITY_CONSUMED_PER_ABILITY = 2,
	colorMap = {
		[1] = {{1, 0.5, 0}, {1, 0.5, 0}},
		[2] = {{0, 0.5, 1}, {0, 0.5, 1}},
		[3] = {{1, 1,   0}, {1, 1,   0}},
		[4] = {{0, 1,   0}, {0, 1,   0}},
		[5] = {{1, 0,   0}, {1, 0,   0}},
		[6] = {{1, 0,   1}, {1, 0,   1}},
		[7] = {{0, 1, 1  }, {0, 1, 1  }},
		[8] = {{1, 1, 1  }, {1, 1, 1  }},
		[100] = {{0, 0, 0}, {1, 1, 1}},
	},
	qualityMap = {
		"Terrible",
		"Poor",
		"Good",
		"Excellent",
		"Pristine",
	},
	rarityColorMap = {
		{0.7, 0.48, 0.3},
		{0.92, 0.86, 0.78},
		{0.9, 0.8, 0.4},
		{0.9, 0, 0.7},
	},
}

return data
