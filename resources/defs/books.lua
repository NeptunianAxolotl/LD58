
local names = util.GetDefDirList("resources/images/book_backs", "png")
local data = {}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/book_backs/" .. names[i] .. ".png",
		form = "image",
		xScale = 0.45,
		yScale = 0.45,
		xOffset = 0,
		yOffset = 0,
	}
end

return data
