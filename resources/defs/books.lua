
local names = util.GetDefDirList("resources/images/book_backs", "png")
local data = {}

local offset = {
	money_bag = 0.5,
}
local scale = {
	["table"] = 1,
}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/book_backs/" .. names[i] .. ".png",
		form = "image",
		xScale = scale[names[i]] or 0.45,
		yScale = scale[names[i]] or 0.45,
		xOffset = offset[names[i]] or 0,
		yOffset = offset[names[i]] or 0,
	}
end

return data
