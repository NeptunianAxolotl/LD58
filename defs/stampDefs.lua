
local stamps = util.LoadDefDirectory("defs/stamps")
local newStamps = {}

for name, def in pairs(stamps) do
	def.name = name
	newStamps[name] = def
end

local data = {
	defs = newStamps,
	colorMap = {
		{1, 0.5, 0},
		{0, 0.5, 1},
		{1, 1,   0},
		{0, 1,   0},
		{1, 0,   0},
		{1, 0,   1},
		{0, 1, 1},
		{1, 1, 1},
	}
}

return data
