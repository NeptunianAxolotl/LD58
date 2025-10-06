
local names = util.GetDefDirList("resources/images/stamps", "png")
local data = {}

local scales = {
	quality_1 = 1/5,
	quality_2 = 1/5,
	quality_3 = 1/5,
	quality_4 = 1/5,
	quality_5 = 1/5,
}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/stamps/" .. names[i] .. ".png",
		form = "image",
		xScale = 94 / 160 * (scales[names[i]] or 1), -- 96 is full
		yScale = 70 / 120 * (scales[names[i]] or 1), -- 72 is full
		xOffset = 0.5,
		yOffset = 0.5,
	}
end

return data
