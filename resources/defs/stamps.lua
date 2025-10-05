
local names = util.GetDefDirList("resources/images/stamps", "png")
local data = {}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/stamps/" .. names[i] .. ".png",
		form = "image",
		xScale = 96 / 800,
		yScale = 72 / 600,
		xOffset = 0.5,
		yOffset = 0.5,
	}
end

return data
