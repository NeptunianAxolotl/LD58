
local names = util.GetDefDirList("resources/images/stamps", "png")
local data = {}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/stamps/" .. names[i] .. ".png",
		form = "image",
		xScale = 0.003,
		yScale = 0.003,
		xOffset = 0.5,
		yOffset = 0.5,
	}
end

return data
