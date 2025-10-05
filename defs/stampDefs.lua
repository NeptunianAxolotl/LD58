
local stamps = util.LoadDefDirectory("defs/stamps")
local newStamps = {}

for name, def in pairs(stamps) do
	def.name = name
	newStamps[name] = def
end

local data = {
	defs = newStamps,
	colorMap = {
		[1] = {{1, 0.5, 0}, {1, 0.5, 0}},
		[2] = {{0, 0.5, 1}, {0, 0.5, 1}},
		[3] = {{1, 1,   0}, {1, 1,   0}},
		[4] = {{0, 1,   0}, {0, 1,   0}},
		[5] = {{1, 0,   0}, {1, 0,   0}},
		[6] = {{1, 0,   1}, {1, 0,   1}},
		[7] = {{0, 1, 1  }, {0, 1, 1  }},
		[8] = {{1, 1, 1  }, {1, 1, 1  }},
		[200] = {{1, 1, 1}, {1, 1, 1}},
	},
	qualityMap = {
		"Terrible",
		"Poor",
		"Good",
		"Excellent",
		"Pristine",
	},
	rarityColorMap = {
		{0.52, 0.38, 0.25},
		{0.92, 0.86, 0.78},
		{0.9, 0.8, 0.4},
	},
}

return data
